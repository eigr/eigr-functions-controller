defmodule PermastateOperator.Controller.V1alpha1.StatefulServices1Test do
  @moduledoc false
  use ExUnit.Case, async: false
  alias PermastateOperator.Controller.V1alpha1.StatefulServices1

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices1.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices1.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices1.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices1.reconcile(event)
      assert result == :ok
    end
  end
end
