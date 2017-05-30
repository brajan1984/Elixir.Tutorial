defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed # == @tag distributed: true
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) ==
           :"foo@l-poz-blapie"
    assert KV.Router.route("world", Kernel, :node, []) ==
           :"bar@l-poz-blapie"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end