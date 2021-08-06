defmodule Cloudimagex.CDNTest do
  use ExUnit.Case, async: true
  alias Cloudimagex.CDN

  setup do
    token = "globaltoken"
    Application.put_env(:cloudimagex, :token, token)

    bypass = Bypass.open()
    Application.put_env(:cloudimagex, :endpoint, endpoint_url(bypass))

    {:ok, token: token, base: "https://#{token}.cloudimg.io/v7", bypass: bypass}
  end

  defp endpoint_url(bypass), do: "http://localhost:#{bypass.port}/"

  describe ".img_url" do
    test "no params with global config", %{base: base} do
      assert CDN.img_url("/assets/image.jpg") == "#{base}/assets/image.jpg"
    end

    test "no params with local config" do
      assert CDN.img_url("/assets/image.jpg", [], token: "localtoken") ==
               "https://localtoken.cloudimg.io/v7/assets/image.jpg"
    end

    test "path without leading forward slash", %{base: base} do
      assert CDN.img_url("assets/image.jpg") == "#{base}/assets/image.jpg"
    end

    test "with params", %{base: base} do
      assert CDN.img_url("assets/image.jpg", %{width: 100, height: 100}) ==
               "#{base}/assets/image.jpg?height=100&width=100"
    end

    test "with params extra params", %{base: base} do
      assert CDN.img_url("assets/image.jpg?width=100&height=100") ==
               "#{base}/assets/image.jpg?width=100&height=100"
    end

    test "merge params with extra params", %{base: base} do
      assert CDN.img_url("assets/image.jpg?gravity=south", %{width: 100, height: 100}) ==
               "#{base}/assets/image.jpg?height=100&width=100&gravity=south"
    end

    @tag :pending
    test "handles filter concatenation with param encoding"

    @tag :pending
    test "alias handles prefix"

    @tag :pending
    test "supports multiple aliases"

    @tag :pending
    test "handles cnames"
  end

  describe ".invalidate_originals" do

    test "raises error when API key is not given" do
      assert_raise RuntimeError, fn ->
        CDN.invalidate_originals(["sample.li/birds.jpg", "sample.li/boat.jpg"])
      end
    end

    test "send invalidate request when API is given", %{bypass: bypass} do
      urls = ["sample.li/birds.jpg", "sample.li/boat.jpg"]
      {:ok, body} = Jason.encode(%{ scope: "original", urls: urls})

      Bypass.expect(bypass, fn conn ->
        assert conn.path_info == ["invalidate"]

        headers = Enum.into(conn.req_headers, %{})
        assert %{"x-client-key" => "api_key_value", "content-type" => "application/json"} = headers

        Plug.Conn.send_resp(conn, 200, body)
      end)

      assert {:ok, 200, _headers, ^body} = CDN.invalidate_originals(urls, api_key: "api_key_value")
    end
  end
end
