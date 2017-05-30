defmodule KV.Router do
    @doc """
    Dispatch the given `mod`, `fun`, `args` request
    to the appropriate node based on the `bucket`
    """
    def route(bucket, mod, fun, args) do
        first = :binary.first(bucket)
        
        # Try to find an entry in the table() or raise
        entry = Enum.find(table(), fn {enum, _node} -> 
            first in enum
        end) || no_entry_error(bucket)

        # If the entry node is the current node
        # elem(entry, 1) where entry = {?a..?b, aaa@comp} will return aaa@comp
        if elem(entry, 1) == node() do
            apply(mod, fun, args)
        else
            {KV.RouterTasks, elem(entry, 1)}
            |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
            |> Task.await
        end
    end

    defp no_entry_error(bucket) do
        raise "could not find entry for #{inspect bucket} in table #{inspect table()}"
    end

    @doc """
    Routing table.
    """
    def table do
        [{?a..?m, :"foo@l-poz-blapie"},
         {?n..?z, :"bar@l-poz-blapie"}]
    end

end