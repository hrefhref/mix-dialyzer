# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.GuardFailPattern do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :guard_fail_pat
  def warning(), do: :guard_fail_pat

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Clause guard cannot succeed because of a pattern mismatch."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_type = Erlex.pretty_print_type(type)
    pretty_pattern = Erlex.pretty_print_pattern(pattern)

    """
    The guard describes a condition of literals that fails the pattern
    given in function head.

    The pattern #{pretty_pattern} was matched against the type #{pretty_type}
    """
  end
end
