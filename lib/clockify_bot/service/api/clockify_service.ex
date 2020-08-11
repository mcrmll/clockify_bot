defmodule ClockifyBot.Service do
  @clockify_apy_base "https://api.clockify.me/api/v1"

  def send_request(path, api_key) do
    url = @clockify_apy_base <> path

    HTTPoison.get(url, gen_header(api_key))
    |> transform_request
  end

  def send_body_request(body, path, api_key) do
    url = @clockify_apy_base <> path

    request = %HTTPoison.Request{
      method: :post,
      url: url,
      body: body,
      headers: gen_json_header(api_key)
    }

    HTTPoison.request(request)
    |> transform_request
  end

  defp transform_request({:ok, response}) do
    {:ok, info_map} = JSON.decode(response.body)
    
    case response.status_code do
      200 -> {:ok, info_map}
      201 -> {:ok, info_map}
      _ -> {:error, response.status_code}
    end
  end


  defp gen_header(api_key) do
    [Accept: "Application/json; Charset=utf-8", "X-Api-Key": api_key]
  end

  defp gen_json_header(api_key) do
    [{"Content-Type", "application/json"}, {"Accept", "application/json"}, {"X-Api-Key", api_key}]
  end
end
