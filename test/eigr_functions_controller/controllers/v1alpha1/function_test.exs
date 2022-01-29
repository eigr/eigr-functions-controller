defmodule Eigr.FunctionsController.Controllers.V1.FunctionTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias Eigr.FunctionsController.Controllers.V1.Function

  describe "add/1" do
    @tag :skip
    test "returns :ok" do
      event = %{}
      result = Function.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    @tag :skip
    test "returns :ok" do
      event = %{}
      result = Function.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    @tag :skip
    test "returns :ok" do
      event = %{}
      result = Function.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    @tag :skip
    test "returns :ok" do
      event = %{}
      result = Function.reconcile(event)
      assert result == :ok
    end
  end
end
