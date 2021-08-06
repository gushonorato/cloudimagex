defmodule Cloudimagex.Client do
  defp endpoint() do
    Application.get_env(:cloudimagex, :endpoint, "https://api.cloudimage.com/")
  end

  def invalidate_originals(urls, api_key) when is_list(urls) do
    post("/invalidate", %{scope: "original", urls: urls}, api_key)
  end

  defp post(path, body, api_key) do
    url =
      endpoint()
      |> Path.join(path)
      |> URI.parse()

    {:ok, json} = Jason.encode(body)

    :post
    |> Finch.build(url, [{"X-Client-Key", api_key}, {"Content-Type", "application/json"}], json)
    |> Finch.request(Cloudimagex.Finch)
    |> case do
      {:ok, response} -> {:ok, response.status, response.headers, response.body}
      {:error, cause} -> {:error, cause}
    end
  end
end
