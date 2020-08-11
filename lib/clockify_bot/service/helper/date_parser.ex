defmodule DateParser do
  defstruct error: [], p_name: nil, client: "", date: nil, h_init: nil, h_end: nil, slack_id: nil

  @hour_pattern_error "Hour format must respect the following pattern: 08:08"
  @date_pattern_error "Date format must respect the following pattern: 30-02-2020 or 30/02/2020"

  def get_date_info(body_params) do
    {slack_id, text} = PointselfParser.parse_body_params(body_params)

    parse_text(text)
    |> transform_splited_info(slack_id)
    |> Map.from_struct()
  end

  defp parse_text(text) do
    String.split(text, " ")
  end

  defp transform_splited_info([p_name, client, date, h_init, h_end], slack_id) do
    transform_date_info(date, h_init, h_end)
    |> set_others(p_name, client, slack_id)
  end

  defp transform_splited_info([p_name, date, h_init, h_end], slack_id) do
    transform_date_info(date, h_init, h_end)
    |> set_others(p_name, slack_id)
  end

  defp transform_splited_info(_, _slack_id) do
    %DateParser{error: [@date_pattern_error]}
  end

  defp set_others(info, p_name, slack_id) do
    %DateParser{info | p_name: p_name, slack_id: slack_id}
  end

  defp set_others(info, p_name, client, slack_id) do
    %DateParser{info | p_name: p_name, client: client, slack_id: slack_id}
  end

  defp transform_date_info(date, h_init, h_end) do
    transform_date(date)
    |> tansform_hours(:h_init, h_init)
    |> tansform_hours(:h_end, h_end)
    |> validate_hour_input
    |> format_errors
  end

  defp transform_date(date) do
    String.splitter(date, ["-", "/"], trim: true)
    |> Enum.take(3)
    |> IntParser.to_int_values()
    |> ParserTimex.is_valid_year()
    |> update_date_info
  end

  defp update_date_info({year, month, day}) do
    %DateParser{date: {year, month, day}}
  end

  defp update_date_info(_) do
    add_error_struct(%DateParser{}, @date_pattern_error)
  end

  defp add_error_struct(info, message) do
    %DateParser{info | error: [message | info.error]}
  end

  ########## HOUR PARSER ##########

  defp tansform_hours(info, type, hours) do
    String.split(hours, ":")
    |> IntParser.to_int_values()
    |> ParserTimex.is_valid_time()
    |> create_hour_string(info)
    |> update_time_info(info, type)
  end

  defp create_hour_string(:error, _info) do
    {:error, @hour_pattern_error}
  end

  defp create_hour_string(time, info) do
    case ParserTimex.gen_hour_string(info.date, time) do
      {:ok, string} -> string
      {:error, :invalid_date} -> {:error, @hour_pattern_error}
    end
  end

  defp update_time_info({:error, message}, info, _type) do
    add_error_struct(info, message)
  end

  defp update_time_info(hour_string, info, type) do
    case type do
      :h_init -> %DateParser{info | h_init: hour_string}
      :h_end -> %DateParser{info | h_end: hour_string}
    end
  end

  defp validate_hour_input(%DateParser{h_end: h_end, h_init: h_init} = info) do
    if(h_init != nil and h_end != nil) do
      case ParserTimex.init_is_lesser_than_end?(info.h_init, info.h_end) do
        true -> info
        false -> add_error_struct(info, "Inital hour must be lesser than the end one.")
      end
    else
      info
    end
  end

  ########## error format #########

  defp format_errors(info) do
    case info.error do
      [] -> %DateParser{info | error: nil}
      error_list -> transfor_error_string(info, error_list)
    end
  end

  defp transfor_error_string(info, error_list) do
    error_string = Enum.reduce(error_list, "", &(&2 <> "#{&1}\n"))
    %DateParser{info | error: error_string}
  end
end
