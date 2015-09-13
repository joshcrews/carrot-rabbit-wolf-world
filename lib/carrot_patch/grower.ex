defmodule CarrotPatch.Grower do

  @carrot_growth_points_required 100
  @carrot_growth_point_speed 10

  def grow_and_recognize_new_carrots(state) do
    state
    |> add_carrot_growth_points
    |> recognize_new_carrots
  end

  defp add_carrot_growth_points(state = %{has_carrots: true}), do: state

  defp add_carrot_growth_points(state = %{carrot_growth_points: carrot_growth_points, has_carrots: false}) do
    additional_carrot_growth_points = build_additional_carrot_growth_points
    new_carrot_growth_points = additional_carrot_growth_points + carrot_growth_points
    %{state | carrot_growth_points: new_carrot_growth_points}
  end

  defp recognize_new_carrots(state = %{has_carrots: true}), do: state
    
  defp recognize_new_carrots(state = %{has_carrots: false, carrot_growth_points: carrot_growth_points}) do
    cond do
      carrot_growth_points > 100 ->
        %{state | has_carrots: true, carrot_growth_points: 0, carrot_age: 0}
      :else ->
        state
    end    
  end

  defp build_additional_carrot_growth_points do
    :random.uniform(@carrot_growth_point_speed)
  end

end