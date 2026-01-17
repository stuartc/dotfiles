#! /usr/bin/env elixir

Mix.install([:req])

defmodule Portainer do
  @portainer_url System.get_env("PORTAINER_URL") || raise "PORTAINER_URL not set"
  @username System.get_env("PORTAINER_USERNAME") || raise "PORTAINER_USERNAME not set"
  @password System.get_env("PORTAINER_PASSWORD") || raise "PORTAINER_PASSWORD not set"

  defp build_client() do
    Req.new(base_url: @portainer_url, connect_options: [transport_opts: [verify: :verify_none]])
  end

  def get_auth_token(client) do
    response =
      Req.post!(client,
        url: "/api/auth",
        json: %{"username" => @username, "password" => @password}
      )

    case response.status do
      200 -> response.body["jwt"]
      _ -> raise "Authentication failed: #{response.body}"
    end
  end

  def get_stacks(client) do
    response =
      Req.get!(client, url: "/api/stacks")

    case response.status do
      200 -> response.body
      _ -> raise "Failed to retrieve stacks: #{response.body}"
    end
  end

  def get_compose_file(client, stack_id) do
    response =
      Req.get!(client, url: "/api/stacks/#{stack_id}/file")

    case response.status do
      200 -> response.body["StackFileContent"]
      _ -> raise "Failed to retrieve compose file for stack #{stack_id}: #{response.body}"
    end
  end

  def main do
    client = build_client()
    token = get_auth_token(client)
    client = client |> Req.Request.put_header("Authorization", "Bearer #{token}")

    stacks = get_stacks(client)

    Enum.each(stacks, fn stack ->
      stack_id = stack["Id"]
      stack_name = stack["Name"]
      compose_file = get_compose_file(client, stack_id)

      IO.puts("Stack ID: #{stack_id}")
      IO.puts("Stack Name: #{stack_name}")
      IO.puts("Compose File:")
      IO.puts(compose_file)
      IO.puts("----------------------------------------")
    end)
  end
end

Portainer.main()
