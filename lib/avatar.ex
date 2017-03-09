defmodule Avatar do
  @moduledoc """
  `Avatar.generate` - generate avatar
  """

  @fullsize 240
  @fill_color "rgba(255, 255, 255, 0.65)"
  # @font_filename Path.join(__DIR__, "data/OpenSans-Semibold.ttf")
  @font_filename Path.join(__DIR__, "data/ARIALUNI.TTF")

  @doc """
  ## Examples
      Avatar.generate 'ksz2k', 200
      Avatar.generate 'ksz2k', 200, cache: false
  if set cache to false, it will generate avatar whenever file exist or not
  """
  def generate(username, size, opts \\ []) do
    cache = Keyword.get(opts, :cache, true)
    identity = identity(username)
    a_size = [size, @fullsize] |> Enum.min
    do_generate(identity, a_size, cache)
  end

  def intitials(name, size, opts \\ []) do
    cache = Keyword.get(opts, :cache, true)
    initial = initial(name)
    a_size = [size, @fullsize] |> Enum.min
    do_generate(initial, a_size, cache)        
  end  

  defp do_generate(identity, size, true) do
    filename = filename(identity, size)
    fullsize = filename(identity, @fullsize)

    if File.exists?(filename) do
      filename
    else
      generate_file(identity, filename, fullsize, size)
    end
  end

  defp do_generate(identity, size, false) do
    filename = filename(identity, size)
    fullsize = filename(identity, @fullsize)

    generate_file(identity, filename, fullsize, size)
  end

  defp generate_file(identity, filename, fullsize, size) do
    convert_fullsize(identity)

    resize(fullsize, filename, size, size)
    filename
  end

  defp initial(name) do
    initials = 
    Enum.map(String.split(name, " "), fn(t) -> 
      [h|t] = String.codepoints(t)
      String.upcase(h)
    end)    
    |> to_string
    |> String.slice(0..1)
    color =  [170, 164, 182]
    %{color: color, letter: initials}
  end

  defp identity(<<char, _rest::binary>> = username) do
    color = Avatar.Color.from_name(username)
    letter = <<char>>
    %{color: color, letter: letter}
  end

  defp cache_path do
    "#{Avatar.Config.cache_base_path}/avatar"
  end

  defp dir_path(identity) do
    path = "#{cache_path}/#{identity.letter}/#{identity.color |> Enum.join("_")}"
    :code.priv_dir(Avatar.Config.app_name) |> Path.join(path)
  end

  defp filename(identity, size) do
    "#{dir_path(identity)}/#{size}.png"
  end

  defp mk_path(path) do
    unless File.exists?(path) do
      File.mkdir_p path
    end
    :ok
  end

  defp convert_file(identity, size) do
    mk_path dir_path(identity)
    filename = filename(identity, size)
    System.cmd "convert", [
      "-size", "#{size}x#{size}",
      "xc:#{to_rgb(identity.color)}",
      # "-pointsize", "140",
      "-pointsize", "120",
      "-font", "#{@font_filename}",
      "-weight", "#{Avatar.Config.weight}",
      "-fill", "#{@fill_color}",
      "-gravity", "Center",
      "-annotate", "#{Avatar.Config.annotate_position}", "#{identity.letter}",
      "#{filename}"
    ]
    filename
  end

  defp resize(from, to, width, height) do
    System.cmd "convert", [
      "#{from}",
      "-background", "transparent",
      "-gravity", "center",
      "-thumbnail", "#{width}x#{height}^",
      "-extent", "#{width}x#{height}",
      "-interpolate", "catrom",
      "-unsharp", "2x0.5+0.7+0",
      "-quality", "40",
      "#{to}"
    ]
  end

  defp convert_fullsize(identity) do
    convert_file(identity, @fullsize)
  end

  defp to_rgb(color) do
    [r, g, b ] = color
    "rgb(#{r},#{g},#{b})"
  end
end
