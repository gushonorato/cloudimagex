defmodule Cloudimagex.CDN do

  alias Cloudimagex.Client

  def img_url(path, params \\ [], opts \\ []) do
    opts
    |> base_url()
    |> Path.join(path)
    |> URI.parse()
    |> maybe_encode_query(params)
    |> URI.to_string()
  end

  def invalidate_original(url, opts \\ []) do
    api_key = get_opt!(opts, :api_key)
    Client.invalidate_originals([url], api_key)
  end

  def invalidate_originals(urls, opts \\ []) do
    api_key = get_opt!(opts, :api_key)
    Client.invalidate_originals(urls, api_key)
  end

  defp maybe_encode_query(uri, []), do: uri
  defp maybe_encode_query(uri, params) do
    query = merge_query_and_params(uri.query, params)
    Map.put(uri, :query, query)
  end

  defp merge_query_and_params(nil, params) do
    URI.encode_query(params)
  end

  defp merge_query_and_params(query, params) do
    query
    |> URI.decode_query()
    |> Map.merge(Enum.into(params, %{}))
    |> URI.encode_query()
  end

  defp base_url(opts) do
    token = get_opt!(opts, :token)
    "https://#{token}.cloudimg.io/v7"
  end

  defp get_opt(opts, key) do
    :cloudimagex
    |> Application.get_all_env()
    |> Keyword.merge(opts)
    |> Keyword.get(key)
  end

  defp get_opt!(opts, key) do
    option = get_opt(opts, key)

    if is_nil(option) do
      raise RuntimeError, ":#{key} is missing in config"
    else
      option
    end
  end
end
