# Util2.ex
# --------
# Versión adaptada del Util2 visto en clase. Se conservan únicamente las
# funciones que NO se llaman a sí mismas (sin recursión).
#
# Se excluyeron a propósito, respecto al Util2 original de clase:
#   - `ingresar_coleccion/2` (privada): usaba recursión para repetir la
#     pregunta "¿Hay más datos?" hasta que el usuario dijera "n".
#   - la cláusula privada `ingresar/3` con parser: usaba recursión para
#     reintentar la pregunta hasta recibir un valor numérico válido.
#   - por dependencia de las dos anteriores, también se excluyeron
#     `ingresar(pregunta, :entero)`, `ingresar(pregunta, :real)`,
#     `ingresar(pregunta, :boolean)` y las variantes
#     `ingresar(pregunta, :coleccion_*)`.
#
# Para compilar este archivo junto con el resto del proyecto:
#   elixirc Util2.ex
# (genera Elixir.Util2.beam en la misma carpeta).

defmodule Util2 do
  @doc "Imprime un mensaje normal (:mensaje) o de error (:error)."
  def mostrar(mensaje, :mensaje), do: IO.puts(mensaje)
  def mostrar(mensaje, :error), do: IO.puts(:standard_error, mensaje)

  @doc "Ordena una colección; envoltorio directo sobre Enum.sort_by/3."
  def ordenar(coleccion, sentido \\ :asc, obtener_campo \\ & &1) do
    Enum.sort_by(coleccion, obtener_campo, sentido)
  end

  @doc "Filtra una colección de strings dejando solo los de longitud <= longitud dada."
  def aplicar_filtro_longitud(coleccion, longitud) do
    Enum.filter(coleccion, &(String.length(&1) <= longitud))
  end

  @doc "Filtra una colección de strings dejando solo los que empiezan por `inicio`."
  def aplicar_filtro_inicial(coleccion, inicio) do
    coleccion
    |> Enum.filter(&String.starts_with?(&1, inicio))
  end

  @doc "Convierte cada elemento de una colección a un mensaje formateado."
  def convertir_coleccion_mensaje(
        coleccion,
        formato \\ fn elemento -> " - #{elemento}\n " end
      ) do
    Enum.map(coleccion, formato)
  end

  @doc "Lee una línea de texto (sin reintentos ni validación de tipo)."
  def ingresar(pregunta, :texto) do
    case IO.gets(pregunta) do
      :eof -> ""
      texto -> String.trim(texto)
    end
  end
end
