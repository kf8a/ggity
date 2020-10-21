defprotocol GGity.Legend do
  @moduledoc false

  @fallback_to_any true

  @spec draw_legend(GGity.Legend.t(), binary(), atom(), number()) :: iolist()
  def draw_legend(scale, label, key_glyph, key_height)
end

defimpl GGity.Legend,
  for: [
    GGity.Scale.Alpha.Discrete,
    GGity.Scale.Color.Viridis,
    GGity.Scale.Fill.Viridis,
    GGity.Scale.Linetype.Discrete,
    GGity.Scale.Size.Discrete
  ] do
  def draw_legend(%scale_type{} = scale, label, key_glyph, key_height),
    do: apply(scale_type, :draw_legend, [scale, label, key_glyph, key_height])
end

defimpl GGity.Legend, for: [GGity.Scale.Shape, GGity.Scale.Shape.Manual] do
  def draw_legend(%scale_type{} = scale, label, _key_glyph, key_height) do
    apply(scale_type, :draw_legend, [scale, label, key_height])
  end
end

defimpl GGity.Legend, for: Any do
  def draw_legend(_scale, _label, _key_glyph, _key_height), do: []
end
