defmodule Mix.Tasks.Ggity.Visual.Geom.Text do
  @shortdoc "Launch a browser and draw sample text geom plots."
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
          bar_labels(),
          geom_col(),
          stack()
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

    File.write!(test_file, "<html>\n#{plots}\n</html>")
    open_html_file(browser, test_file)
    Process.sleep(1000)
    File.rm(test_file)
  end

  defp open_html_file(browser, file) do
    System.cmd(browser, [file])
  end

  defp basic do
    Examples.mtcars()
    |> Enum.filter(fn record ->
      String.contains?(record[:model], "Merc")
    end)
    |> Plot.new(%{x: :wt, y: :mpg, label: :model})
    |> Plot.geom_point()
    |> Plot.geom_text(nudge_x: 5, hjust: :left, size: 6)
    |> Plot.xlab("Weight (tons)")
    |> Plot.ylab("Miles Per Gallon")
    |> Plot.plot()
  end

  defp bar_labels do
    Examples.mpg()
    |> Enum.filter(fn record ->
      record["manufacturer"] in ["chevrolet", "audi", "ford", "nissan", "subaru"]
    end)
    |> Plot.new(%{x: "manufacturer"})
    |> Plot.geom_bar()
    |> Plot.geom_text(%{label: :count},
      position: :dodge,
      family: "Courier New",
      fontface: "bold",
      color: "cornflowerblue",
      stat: :count,
      size: 8,
      nudge_y: -5
    )
    |> Plot.plot()
  end

  defp stack do
    [
      %{salesperson: "Joe", week: "Week 1", units: 10},
      %{salesperson: "Jane", week: "Week 1", units: 15},
      %{salesperson: "Paul", week: "Week 1", units: 5},
      %{salesperson: "Joe", week: "Week 2", units: 4},
      %{salesperson: "Jane", week: "Week 2", units: 10},
      %{salesperson: "Paul", week: "Week 2", units: 8},
      %{salesperson: "Joe", week: "Week 3", units: 14},
      %{salesperson: "Paul", week: "Week 3", units: 8},
      %{salesperson: "Jane", week: "Week 3", units: 9},
      %{salesperson: "Joe", week: "Week 4", units: 14},
      %{salesperson: "Jane", week: "Week 4", units: 9}
    ]
    |> Plot.new(%{x: :week, y: :units, label: :units, group: :salesperson})
    |> Plot.geom_col(%{fill: :salesperson}, position: :stack)
    |> Plot.geom_text(
      color: "#BAAC6F",
      position: :stack,
      position_vjust: 0.5,
      fontface: "bold",
      size: 6
    )
    |> Plot.scale_fill_viridis(option: :cividis)
    |> Plot.plot()
  end

  defp geom_col do
    [
      %{salesperson: "Joe", week: "Week 1", units: 10},
      %{salesperson: "Jane", week: "Week 1", units: 15},
      %{salesperson: "Paul", week: "Week 1", units: 5},
      %{salesperson: "Joe", week: "Week 2", units: 4},
      %{salesperson: "Jane", week: "Week 2", units: 10},
      %{salesperson: "Paul", week: "Week 2", units: 8},
      %{salesperson: "Joe", week: "Week 3", units: 14},
      %{salesperson: "Paul", week: "Week 3", units: 8},
      %{salesperson: "Jane", week: "Week 3", units: 9},
      %{salesperson: "Joe", week: "Week 4", units: 14},
      %{salesperson: "Jane", week: "Week 4", units: 9}
    ]
    |> Enum.map(fn row -> Map.put(row, :label_y_pos, row.units / 2) end)
    |> Plot.new(%{x: :week, y: :units, label: :units, group: :salesperson})
    |> Plot.geom_col(%{fill: :salesperson}, position: :dodge)
    |> Plot.geom_text(%{y: :label_y_pos},
      color: "#BAAC6F",
      position: :dodge,
      fontface: "bold",
      size: 6
    )
    |> Plot.scale_fill_viridis(option: :cividis)
    |> Plot.plot()
  end
end