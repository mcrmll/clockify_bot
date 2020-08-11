defmodule PointselfParser do
   def parse_body_params(body_params) do
      user_id = Map.get(body_params, "user_id")
      text = Map.get(body_params, "text")
      {user_id, text}
    end

end