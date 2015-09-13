defmodule CarrotPatch.Killer do
  @carrot_life_span 35

  def age_existing_and_kill_carrots(state) do
    state
    |> age_existing_carrots
    |> old_carrots_die
  end

  defp age_existing_carrots(state = %{has_carrots: false}), do: state

  defp age_existing_carrots(state = %{has_carrots: true, carrot_age: carrot_age}) do
    %{state | carrot_age: carrot_age + 1}
  end

  defp old_carrots_die(state = %{has_carrots: false}), do: state

  defp old_carrots_die(state = %{carrot_age: carrot_age, has_carrots: true}) do
    cond do
      carrot_age > @carrot_life_span ->
        %{state | has_carrots: false, carrot_growth_points: 0, carrot_age: 0}
      :else ->
        state
    end    
  end

end