defmodule Cashier.Gateways.DummySupervisor do
  use ConsumerSupervisor

  def start_link(_opts) do
    children = [
      worker(Cashier.Gateways.Dummy, [], restart: :temporary)
    ]

    ConsumerSupervisor.start_link(
      children,
      strategy: :one_for_one,
      name: __MODULE__,
      subscribe_to: [{
        Cashier.Pipeline.GatewayRouter,
        max_demand: 50, # todo: max_demand needs to be a config option
        selector: &dispatch_selector/1
      }],
    )
  end

  defp dispatch_selector({_, _, opts}),
    do: Keyword.get(opts, :gateway) == :dummy
  defp dispatch_selector(_), do: false
end