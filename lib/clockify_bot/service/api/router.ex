# MIT License

# Copyright (c) 2020 Matheus Ciaramella Vieira

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

defmodule ClockifyBot.Router do
  alias ClockifyBot.RouteParser, as: Parser
  alias ClockifyBot, as: Bot
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  plug(:dispatch)

  post "/config" do
    case Parser.get_config(conn.body_params) do
      {:error, message} -> {:error, message}
      {slack_id, api_key} -> Bot.command(:config, slack_id, api_key)
    end
    |> send_response(conn)
  end

  post "/add_hours" do
    info = Parser.point_self(conn.body_params)

    case info.error do
      nil -> Bot.command(:point_self, info.slack_id, info)
      error_string -> {:error, error_string}
    end
    |> send_response(conn)
  end

  post "/help" do
    message = "
    I'm Clockify bot, a bot designed to help you with your Clockify hours!\n
    How do I work:\n
    - Before anything, you must generate your API_KEY inside your Clockify account as we are set on Free Clockify version!\n
    - After that, you must configure your profile with /config API_KEY\n
    - Now you can use the command /add_hours to add your worked time information inside your projects following the pattern:\n
      > {project_name} [client] {date as DD-MM-YYYY} {init as HH:MM} {end as HH:MM}\n
      (Note that client is the only not required option!)\n
      You must be aware of whitespaces and bad formats, I'm are not prepared to read bad formated strings!\n

    And that's all folks!\n
    Bot developed in Elixir with Plug/Ecto by Matheus Ciaramella
    "
    send_resp(conn, 200, message)
  end

  match _ do
    send_resp(conn, 404, "Nothing to do around here (:")
  end

  def send_response({_, message}, conn) do
    send_resp(conn, 200, message)
  end
end
