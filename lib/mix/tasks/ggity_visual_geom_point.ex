defmodule Mix.Tasks.Ggity.Visual.Geom.Point do
  @shortdoc "Launch a browser and draw sample point geom plots."
  @moduledoc @shortdoc

  use Mix.Task

  alias GGity.{Examples, Plot}

  @default_browser "firefox"

  @doc false
  @spec run(list(any)) :: any()
  def run([]), do: run([@default_browser])

  def run(argv) do
    plots =
      Enum.join(
        [
          basic(),
          add_color_aesthetic(),
          add_shape_fixed(),
          add_shape_manual(),
          add_discrete_alpha(),
          add_size_aesthetic(),
          fixed_aesthetics(),
          diamonds_alpha_tenth(),
          two_legends(),
          discrete_scale()
        ],
        "\n"
      )

    test_file = "test/visual/visual_test.html"

    browser =
      case argv do
        ["--wsl"] ->
          "/mnt/c/Program Files/Mozilla Firefox/firefox.exe"

        [browser] ->
          browser
      end

    File.write!(test_file, "<html><body #{grid_style()}>\n#{plots}\n</body></html>")
    open_html_file(browser, test_file)
    Process.sleep(1000)
    File.rm(test_file)
  end

  defp open_html_file(browser, file) do
    System.cmd(browser, [file])
  end

  defp grid_style do
    "style='display: grid;grid-template-columns: repeat(3, 1fr)'"
  end

  defp basic do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.labs(title: "Basic Plot")
    |> Plot.geom_point(
      custom_attributes: fn plot, row ->
        [onclick: "alert('#{plot.labels.y}: #{row.mpg}')"]
      end
    )
    |> Plot.xlab("Weight (lbs)")
    |> Plot.ylab("Miles Per Gallon")
    |> Plot.plot()
  end

  defp add_color_aesthetic do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.labs(title: "Discrete Color", x: "Weight (lbs)", y: "Miles Per Gallon")
    |> Plot.geom_point(%{color: :cyl})
    |> Plot.labs(color: "Cylinders")
    |> Plot.plot()
  end

  defp add_shape_fixed do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point(%{shape: :cyl}, size: 5, color: "blue")
    |> Plot.labs(title: "Shape Aesthetic", shape: "Cylinders")
    |> Plot.plot()
  end

  defp add_shape_manual do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point(%{shape: :cyl}, size: 7)
    |> Plot.scale_shape_manual(values: ["🐌", "🤷", "💪"])
    |> Plot.labs(title: "Emoji Support", shape: "Cylinders")
    |> Plot.plot()
  end

  defp add_discrete_alpha do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point(%{alpha: :cyl}, color: "blue")
    |> Plot.labs(title: "Discrete Alpha")
    |> Plot.scale_alpha_discrete()
    |> Plot.plot()
  end

  defp add_size_aesthetic do
    Examples.mtcars()
    |> Plot.new(%{x: :qsec, y: :mpg})
    |> Plot.geom_point(%{size: :cyl}, alpha: 0.3, color: "blue", shape: :circle)
    |> Plot.geom_point(%{size: :wt}, color: "red", shape: :triangle)
    |> Plot.labs(title: "Size")
    |> Plot.scale_size(range: {1, 10})
    |> Plot.plot()
  end

  defp fixed_aesthetics do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point(color: "red", size: 6)
    |> Plot.labs(title: "Fixed, color: \"red\"")
    |> Plot.plot()
  end

  defp diamonds_alpha_tenth do
    Examples.diamonds()
    |> Plot.new(%{x: "carat", y: "price"})
    |> Plot.geom_point(alpha: 1 / 20)
    |> Plot.labs(title: "Fixed, alpha: 1 / 20")
    |> Plot.plot()
  end

  defp two_legends do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_point(%{color: :cyl, shape: :vs})
    |> Plot.labs(title: "Two Category Scales")
    |> Plot.plot()
  end

  defp discrete_scale do
    Examples.mpg()
    |> Plot.new(%{x: "manufacturer", y: "cty"})
    |> Plot.geom_point()
    |> Plot.labs(title: "Discrete X")
    |> Plot.plot()
  end
end
