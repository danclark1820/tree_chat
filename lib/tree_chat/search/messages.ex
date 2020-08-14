defmodule TreeChat.Search.Messages do
  import Ecto.Query

  @spec run(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def run(query, search_term) do
    where(
      query,
      fragment(
        "to_tsvector('english', body) @@
        to_tsquery(?)",
        ^prefix_search(search_term)
      )
    )
  end

  defp prefix_search(term), do
    String.replace(term, ~r/[^a-zA-Z ]/, "")
    |> String.replace( ~r/^\s+|\s+$|\s+(?=\s)/, "")
    |> String.replace(~r/\W/u, " | ")
  end
end
