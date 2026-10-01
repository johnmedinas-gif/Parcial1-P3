# Módulo Ranking
# ---------------
# Utilidad genérica para numerar y ordenar cualquier colección según un
# criterio configurable, usando una keyword list de opciones en vez de
# varios parámetros posicionales. Esto evita escribir una función de
# ordenamiento distinta para cada reporte: R4 (liquidación numerada por
# neto) la usa directamente, y cualquier otro reporte que necesite un
# "top N" también podría reutilizarla.
#
# El ordenamiento interno se delega en `Util2.ordenar/3` (visto en clase,
# compilado aparte con `elixirc Util2.ex`), que es un envoltorio directo
# sobre `Enum.sort_by/3`.
defmodule Ranking do
  @doc """
  Ordena `coleccion` y le asigna una posición (1, 2, 3, ...) a cada
  elemento. Devuelve una lista de tuplas `{posicion, elemento}`.

  Opciones (keyword list), todas opcionales:
    * `:por`     -> función para extraer el valor de comparación de cada
                    elemento (por defecto, el elemento mismo).
    * `:orden`   -> `:desc` (por defecto) o `:asc`.
    * `:limite`  -> número máximo de elementos a devolver (por defecto,
                    todos).

  ## Ejemplo

      iex> Ranking.ranking([%{neto: 100}, %{neto: 300}, %{neto: 200}], por: & &1.neto)
      [{1, %{neto: 300}}, {2, %{neto: 200}}, {3, %{neto: 100}}]
  """
  def ranking(coleccion, opciones \\ []) do
    criterio = Keyword.get(opciones, :por, & &1)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, :infinito)

    coleccion
    |> Util2.ordenar(orden, criterio)
    |> aplicar_limite(limite)
    |> Enum.with_index(1)
    |> Enum.map(fn {elemento, posicion} -> {posicion, elemento} end)
  end

  defp aplicar_limite(lista, :infinito), do: lista
  defp aplicar_limite(lista, limite), do: Enum.take(lista, limite)
end
