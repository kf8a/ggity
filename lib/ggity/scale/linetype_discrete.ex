defmodule GGity.Scale.Linetype.Discrete do
  @moduledoc false

  alias GGity.{Draw, Labels}
  alias GGity.Scale.Linetype

  #  solid: "",
  #  dashed: "4",
  #  dotted: "1",
  #  longdash: "6 2",
  #  dotdash: "1 2 3 2",
  #  twodash: "2 2 6 2"

  @palette_values [
    "",
    "4",
    "1",
    "6 2",
    "1 2 3 2",
    "2 2 6 2"
  ]

  defstruct transform: nil,
            levels: nil,
            labels: :waivers,
            guide: :legend

  @type t() :: %__MODULE__{}

  @spec new(keyword()) :: Linetype.Discrete.t()
  def new(options \\ []), do: struct(Linetype.Discrete, options)

  @spec train(Linetype.Discrete.t(), list(binary())) :: Linetype.Discrete.t()
  def train(scale, [level | _other_levels] = levels) when is_list(levels) and is_binary(level) do
    transform = GGity.Scale.Discrete.transform(levels, palette(levels))
    struct(scale, levels: levels, transform: transform)
  end

  defp palette(levels) do
    @palette_values
    |> Stream.cycle()
    |> Enum.take(length(levels))
  end

  @spec draw_legend(Linetype.Discrete.t(), binary(), atom(), number(), keyword()) :: iolist()
  def draw_legend(
        %Linetype.Discrete{guide: :none},
        _label,
        _key_glyph,
        _key_height,
        _fixed_aesthetics
      ),
      do: []

  def draw_legend(
        %Linetype.Discrete{levels: [_]},
        _label,
        _key_glyph,
        _key_height,
        _fixed_aesthetics
      ),
      do: []

  def draw_legend(
        %Linetype.Discrete{levels: levels} = scale,
        label,
        key_glyph,
        key_height,
        fixed_aesthetics
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
        draw_legend_item(scale, {level, index}, key_glyph, key_height, fixed_aesthetics)
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

  defp draw_key_glyph(scale, level, index, :path, key_height, fixed_aesthetics) do
    Draw.line(
      x1: 1,
      y1: key_height / 2 + key_height * index,
      x2: key_height - 1,
      y2: key_height / 2 + key_height * index,
      stroke: fixed_aesthetics[:color],
      stroke_dasharray: "#{scale.transform.(level)}",
      stroke_opacity: fixed_aesthetics[:alpha]
    )
  end

  defp draw_key_glyph(scale, level, index, :timeseries, key_height, fixed_aesthetics) do
    offset = key_height * index

    Draw.polyline(
      [
        {1, key_height - 1 + offset},
        {key_height / 5 * 2, key_height / 5 * 2 + offset},
        {key_height / 5 * 3, key_height / 5 * 3 + offset},
        {key_height - 1, 1 + offset}
      ],
      fixed_aesthetics[:color],
      fixed_aesthetics[:size],
      fixed_aesthetics[:linetype],
      scale.transform.(level)
    )
  end
end
