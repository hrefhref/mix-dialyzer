defmodule Dialyzer.Warnings.CallbackInfoMissing do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :callback_info_missing
  def warning(), do: :callback_info_missing

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined behaviour"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)

    "Callback info about the #{pretty_behaviour} behaviour is not available."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([behaviour]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)

    """
    The module is using a behaviour that does not exist or is not a
    behaviour.

    Undefined: #{pretty_behaviour}
    """
  end
end