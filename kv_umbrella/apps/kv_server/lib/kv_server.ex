defmodule KVServer do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)

    #This makes the child process the “controlling process” of the client socket. 
    #If we didn’t do this, the acceptor would bring down all the clients if it crashed
    #because sockets would be tied to the process that accepted them (which is the default behaviour).
    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor(socket)
  end

  defp serve(socket) do
    msg = 
      with {:ok, data} <- read_line(socket),
        {:ok, command} <- KVServer.Command.parse(data),
        do: KVServer.Command.run(command)

      # Above code is equivalent to
      # case read_line(socket) do
      #   {:ok, data} ->
      #     case KVServer.Command.parse(data) do
      #       {:ok, command} -> 
      #         KVServer.Command.run(command)
      #       {:error, _} = err ->
      #         err
      #     end
      #   {:error, _} = err ->
      #         err
      # end

    write_line(socket, msg)
    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMAMND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    # Unknown error. Write to the client and exit.
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end

  defp write_line(socket, {:error, :not_found}) do
    # Unknown error. Write to the client and exit.
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end
end
