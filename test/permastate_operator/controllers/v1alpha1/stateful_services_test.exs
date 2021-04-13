defmodule PermastateOperator.Controller.V1alpha1.StatefulServicesTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias PermastateOperator.Controller.V1alpha1.StatefulServices

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = StatefulServices.reconcile(event)
      assert result == :ok
    end
  end
end
