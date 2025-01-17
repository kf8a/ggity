defmodule Mix.Tasks.Ggity.Visual.Annotate do
  @shortdoc "Launch a browser and draw plots with annotations."
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
          text(),
          rect(),
          segment()
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

  defp text do
    p()
    |> Plot.annotate(:text,
      x: 4,
      y: 25,
      label: "Some text",
      color: "red",
      custom_attributes: fn _plot, _row -> [onclick: "alert('I am a text annotation.')"] end
    )
    |> Plot.geom_point()
    |> Plot.plot()
  end

  defp rect do
    p()
    |> Plot.annotate(:rect,
      xmin: 3,
      xmax: 4.2,
      ymin: 12,
      ymax: 21,
      alpha: 0.2,
      custom_attributes: fn _plot, row ->
        [onclick: "alert('I am #{row.xmax - row.xmin} wide.')"]
      end
    )
    |> Plot.geom_point()
    |> Plot.plot()
  end

  defp segment do
    p()
    |> Plot.annotate(:segment,
      x: 2.5,
      xend: 4,
      y: 15,
      yend: 26.25,
      color: "blue",
      custom_attributes: fn plot, _row ->
        [
          onclick:
            "alert('I am a line on a plot with #{length(plot.layers) - 1} non-blank layers.')"
        ]
      end
    )
    |> Plot.geom_point()
    |> Plot.plot()
  end

  defp p do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
  end
end
