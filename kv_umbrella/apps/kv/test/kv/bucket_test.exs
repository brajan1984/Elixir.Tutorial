defmodule KV.Bucket.Test do
    use ExUnit.Case, async: true

    test "stores values by key" do
        {:ok, bucket} = KV.Bucket.start_link
        assert KV.Bucket.get(bucket, "milk") == nil

        KV.Bucket.put(bucket, "milk", 3)
        assert KV.Bucket.get(bucket, "milk") == 3
    end

    test "deletes value by key" do
        key = "someval"
        val = 2

        {:ok, bucket} = KV.Bucket.start_link
        KV.Bucket.put(bucket, key, val)
        assert KV.Bucket.get(bucket, key) == val
        KV.Bucket.delete(bucket, key)
        valueAquired = KV.Bucket.get(bucket, key)

        assert valueAquired == nil
    end
end