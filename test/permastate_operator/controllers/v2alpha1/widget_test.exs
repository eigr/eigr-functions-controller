defmodule PermastateOperator.Controller.V2alpha1.WidgetTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias PermastateOperator.Controller.V2alpha1.Widget

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = Widget.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = Widget.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    test "returns :ok" do
      event = %{}
      result = Widget.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = Widget.reconcile(event)
      assert result == :ok
    end
  end
end
