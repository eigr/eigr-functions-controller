defmodule Eigr.FunctionsController.K8S.ClusterIPService do
  @behaviour Eigr.FunctionsController.K8S.Manifest

  @http_port 9001
  @proxy_port 9000

  import Eigr.FunctionsController.EasterEggs

  @impl true
  def manifest(ns, name, _params) do
    my_place_in_the_universe = get_space_travel_destiny()
    distance = calculate_distance_from_earth(my_place_in_the_universe)

    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "labels" => %{
          "functions.eigr.io/controller.version" =>
            "#{to_string(Application.spec(:eigr_functions_controller, :vsn))}",
          "functions.eigr.io/wormhole.gate.#{my_place_in_the_universe}.status" => "open",
          "functions.eigr.io/wormhole.gate.#{my_place_in_the_universe}.distance-from-earth" =>
            "#{distance}"
        },
        "name" => "#{name}-svc",
        "namespace" => ns
      },
      "spec" => %{
        "type" => "ClusterIP",
        "selector" => %{"app" => name},
        "ports" => [
          %{"name" => "proxy", "port" => @proxy_port, "targetPort" => @proxy_port},
          %{"name" => "http", "port" => @http_port, "targetPort" => @http_port}
        ]
      }
    }
  end
end
