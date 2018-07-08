# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter do
  import Dialyzer.Logger
  alias Dialyzer.Warning

  @doc """
  It gets a list of all the warnings generated by dialyzer and
  formats them into nice error messages, with ansi color support.
  """
  @spec format(list(), :short | :long) :: [String.t()]
  def format(warnings, type) do
    Enum.map(warnings, &format_warning(&1, type))
  end

  defp format_warning(warning, type) do
    relative_filepath =
      warning.file
      |> Path.relative_to_cwd()
      |> inspect(limit: :infinity, printable_limit: :infinity)

    try do
      warning_formatter = fetch_warning(warning.name)

      case type do
        :short ->
          header = case warning.line do
            0 -> relative_filepath
            _ -> "#{relative_filepath}:#{warning.line}"
          end
          message = warning_formatter.format_short(warning.args)

          "#{color(:cyan, header)} - #{message}"

        :long ->
          header = generate_warning_header(warning_formatter.name(), relative_filepath, warning.line)

          ignore_warning_tuple = Warning.to_ignore_format(warning)

          message =
            warning.args
            |> warning_formatter.format_long()
            |> String.split("\n")
            |> Enum.map(&("    " <> &1))
            |> Enum.join("\n")
            |> String.trim()

          """
          #{color(:cyan, header)}

          #{message}

          Ignore warning: #{
            inspect(ignore_warning_tuple, limit: :infinity, printable_limit: :infinity)
          }
          """
      end
    rescue
      e ->
        error("Unknown error occurred: #{inspect(e)}")
    catch
      {:error, :unknown_warning, warning_name} ->
        error("Unknown warning: #{inspect(warning_name)}")

      {:error, :lexing, warning} ->
        error("Failed to lex warning: #{inspect(warning)}")

      {:error, :parsing, failing_string} ->
        error("Failed to parse warning: #{inspect(failing_string)}")

      {:error, :pretty_printing, failing_string} ->
        error("Failed to pretty print warning: #{inspect(failing_string)}")

      {:error, :formatting, code} ->
        error("Failed to format warning: #{inspect(code)}")
    end
  end

  @spec fetch_warning(atom) :: module
  defp fetch_warning(warning_name) do
    warnings = Dialyzer.Formatter.Warnings.warnings()

    if Map.has_key?(warnings, warning_name) do
      Map.get(warnings, warning_name)
    else
      throw({:error, :unknown_warning, warning_name})
    end
  end

  defp generate_warning_header(warning_name, filepath, line_nr) do
    warning_fragment = if warning_name != "", do: " #{String.upcase(warning_name)} ", else: ""
    filepath_fragment = case line_nr do
      0 -> filepath
      _ -> " #{filepath}:#{line_nr}"
    end

    len = 80 - (String.length(warning_fragment) + String.length(filepath_fragment))
    separators = for _ <- 0..len, into: "", do: "-"

    String.slice(separators, 0..1)
    |> Kernel.<>(warning_fragment)
    |> Kernel.<>(String.slice(separators, 2..-1))
    |> Kernel.<>(filepath_fragment)
  end
end
