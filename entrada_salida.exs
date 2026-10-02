# Módulo EntradaSalida
# ---------------------
# Concentra todas las funciones impuras de interacción con el usuario
# (lectura de teclado, impresión en pantalla). Mantenerlas separadas de
# Validaciones, Calculos y Reportes permite que esos otros módulos sean
# 100% puros: reciben datos y devuelven datos, sin tocar IO.puts ni
# IO.gets.
defmodule EntradaSalida do
  @doc "Imprime un mensaje normal en pantalla (Util2)."
  def mostrar(mensaje), do: Util2.mostrar(mensaje, :mensaje)

  @doc "Imprime un mensaje de error por la salida estándar de error (Util2)."
  def mostrar_error(mensaje), do: Util2.mostrar(mensaje, :error)

  @doc "Imprime una línea en blanco o un separador; útil para formatear reportes."
  def separador(caracter \\ "-", longitud \\ 60) do
    IO.puts(String.duplicate(caracter, longitud))
  end

  @doc "Lee una línea de texto del usuario, mostrando antes una pregunta, y la retorna sin saltos de línea."
  def leer_texto(pregunta) do
    pregunta
    |> IO.gets()
    |> tratar_entrada()
  end

  # IO.gets/1 devuelve :eof cuando no hay más entrada disponible (por ejemplo
  # al redirigir un archivo vacío). Se contempla ese caso para que el
  # programa no falle con un error de coincidencia de patrones.
  defp tratar_entrada(:eof), do: ""
  defp tratar_entrada(texto), do: String.trim(texto)

  @doc """
  Solicita al usuario el renglón de una entrega adicional en el formato
  "productor;tanque;dia;litros;grasa" y lo convierte en un mapa de entrega.

  Devuelve:
    * `{:ok, :omitido}` si el usuario presionó Enter sin escribir nada.
    * `{:ok, entrega}` si el formato es válido.
    * `{:error, :formato_invalido}` si no se cumple el formato esperado.
  """
  def leer_entrega_adicional do
    "\nIngrese una entrega adicional\n(productor;tanque;dia;litros;grasa)\no Enter para omitir: "
    |> leer_texto()
    |> interpretar_linea_entrega()
  end

  defp interpretar_linea_entrega("") do
    {:ok, :omitido}
  end

  defp interpretar_linea_entrega(linea) do
    campos = String.split(linea, ";")

    with [productor, tanque, dia_txt, litros_txt, grasa_txt] <- campos,
         {:ok, dia} <- convertir_entero(dia_txt),
         {:ok, litros} <- convertir_numero(litros_txt),
         {:ok, grasa} <- convertir_numero(grasa_txt) do
      {:ok,
       %{
         productor: String.trim(productor),
         tanque: String.trim(tanque),
         dia: dia,
         litros: litros,
         grasa: grasa
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  # Un número entero solo es válido si, tras convertirlo, no sobra texto.
  defp convertir_entero(texto) do
    case Integer.parse(String.trim(texto)) do
      {valor, ""} -> {:ok, valor}
      _ -> {:error, :formato_invalido}
    end
  end

  # litros y grasa pueden llegar como enteros o decimales; Float.parse
  # acepta ambos formatos ("320" y "320.5")
  defp convertir_numero(texto) do
    case Float.parse(String.trim(texto)) do
      {valor, ""} -> {:ok, valor}
      _ -> {:error, :formato_invalido}
    end
  end

  @doc "Solicita el código de un productor para mostrar su comprobante."
  def leer_codigo_productor do
    leer_texto("\nIngrese el código del productor para su comprobante: ")
  end
end
