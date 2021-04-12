defmodule PermastateOperator.Controller.V1alpha1.WidegetTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias PermastateOperator.Controller.V1alpha1.Wideget

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = Wideget.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = Wideget.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    test "returns :ok" do
      event = %{}
      result = Wideget.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = Wideget.reconcile(event)
      assert result == :ok
    end
  end
end
