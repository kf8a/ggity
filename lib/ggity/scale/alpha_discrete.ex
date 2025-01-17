defmodule GGity.Scale.Alpha.Discrete do
  @moduledoc false

  alias GGity.{Draw, Labels}
  alias GGity.Scale.Alpha

  defstruct transform: nil,
            range: {0.1, 1},
            levels: nil,
            labels: :waivers,
            guide: :legend

  @type t() :: %__MODULE__{}

  @spec new(keyword()) :: Alpha.Discrete.t()
  def new(options \\ []), do: struct(Alpha.Discrete, options)

  @spec train(Alpha.Discrete.t(), list(binary())) :: Alpha.Discrete.t()
  def train(scale, [level | _other_levels] = levels) when is_list(levels) and is_binary(level) do
    transform = GGity.Scale.Discrete.transform(levels, palette(scale, levels))
    struct(scale, levels: levels, transform: transform)
  end

  defp palette(%Alpha.Discrete{range: {min, max}}, [_single_level]) do
    [min + (max - min) / 2]
  end

  defp palette(%Alpha.Discrete{range: {min, max}}, levels) do
    number_of_levels = length(levels)
    interval = (max - min) / (number_of_levels - 1)
    for index <- 1..number_of_levels, do: min + (index - 1) * interval
  end

  @spec draw_legend(Alpha.Discrete.t(), binary(), atom(), number(), keyword()) :: iolist()
  def draw_legend(
        %Alpha.Discrete{guide: :none},
        _label,
        _key_glyph,
        _key_height,
        _fixed_aesthetics
      ),
      do: []

  def draw_legend(
        %Alpha.Discrete{levels: [_]},
        _label,
        _key_glyph,
        _key_height,
        _fixed_aethetics
      ),
      do: []

  def draw_legend(
        %Alpha.Discrete{levels: levels} = scale,
        label,
        key_glyph,
        key_height,
        fixed_aethetics
      ) do
    [
      Draw.text(
        "#{label}",
        x: "0",
        y: "-5",
        class: "gg-text gg-legend-title",
        text_anchor: "left"
      ),
      Stream.with_index(levels)
      |> Enum.map(fn {level, index} ->
        draw_legend_item(scale, {level, index}, key_glyph, key_height, fixed_aethetics)
      end)
    ]
  end

  defp draw_legend_item(scale, {level, index}, key_glyph, key_height, fixed_aesthetics) do
    [
      Draw.rect(
        x: "0",
        y: "#{key_height * index}",
        height: key_height,
        width: key_height,
        class: "gg-legend-key"
      ),
      draw_key_glyph(scale, level, index, key_glyph, key_height, fixed_aesthetics),
      Draw.text(
        "#{Labels.format(scale, level)}",
        x: "#{key_height + 5}",
        y: "#{10 + key_height * index}",
        class: "gg-text gg-legend-text",
        text_anchor: "left"
      )
    ]
  end

  defp draw_key_glyph(scale, level, index, :rect, key_height, fixed_aesthetics) do
    Draw.rect(
      x: "0",
      y: "#{key_height * index}",
      height: key_height,
      width: key_height,
      fill_opacity: "#{scale.transform.(level)}",
      fill: fixed_aesthetics[:fill]
    )
  end

  defp draw_key_glyph(scale, level, index, :a, key_height, fixed_aesthetics) do
    Draw.text(
      "a",
      x: key_height / 2,
      y: key_height / 2 + key_height * index,
      text_anchor: "middle",
      dominant_baseline: "middle",
      font_size: 10,
      font_weight: "bold",
      fill: fixed_aesthetics[:color],
      fill_opacity: "#{scale.transform.(level)}"
    )
  end

  defp draw_key_glyph(scale, level, index, :point, key_height, fixed_aesthetics) do
    GGity.Shapes.draw(
      :circle,
      {key_height / 2, key_height / 2 + key_height * index},
      :math.pow(1 + key_height / 3, 2),
      color: fixed_aesthetics[:color],
      fill: fixed_aesthetics[:fill],
      fill_opacity: "#{scale.transform.(level)}"
    )
  end
end
