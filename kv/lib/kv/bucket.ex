defmodule KV.Bucket do
    @doc """
    Start new bucket
    """
    def start_link do
        Agent.start_link(fn -> %{} end)
    end

    @doc """
    Gets value from `bucket` by `key`
    """
    def get(bucket, key) do
        Agent.get(bucket, &Map.get(&1, key))
    end

    @doc """
    Puts the `value` for given `key` into the `bucket`
    """
    def put(bucket, key, value) do
        Agent.update(bucket, &Map.put(&1, key, value))
    end

    @doc """
    Deletes value from `bucket` by `key`
    """
    def delete(bucket, key) do
        #Agent.get_and_update(bucket, &Map.pop(&1, key))
        Agent.get_and_update(bucket, fn dict -> 
            Map.pop(dict, key) 
        end)
    end
end