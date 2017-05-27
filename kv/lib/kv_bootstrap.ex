defmodule KV.Bootstrap do

    def main_registry_worker do
        Supervisor.Spec.worker(KV.Registry, [KV.Registry])
    end
end