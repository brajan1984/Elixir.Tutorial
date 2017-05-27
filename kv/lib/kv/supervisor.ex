defmodule KV.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        children = [
            KV.Bootstrap.main_registry_worker,
            supervisor(KV.Bucket.Supervisor, [])
        ]
        
        supervise(children, strategy: :rest_for_one)
    end
end