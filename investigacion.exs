# Módulo Investigacion
# ---------------------------------------------
# Combina el mapa de litros diarios del centro (obtenido en R3) con el
# mapa de litros diarios de un centro vecino, sumando los valores cuando
# la clave (el día) aparece en ambos mapas. Se usa Map.merge/3, que recibe
# una función de conflicto que solo se invoca cuando la clave existe en
# los dos mapas; si la clave está en uno solo, ese valor se conserva tal
# cual, sin pasar por la función.
defmodule Investigacion do
  @doc """
  Combina `litros_propios` (mapa `%{dia => litros}` del propio centro,
  como el que arma R3) con `litros_vecino` (mismo formato), sumando los
  litros de los días que aparecen en ambos mapas.
  """
  def combinar_litros_diarios(litros_propios, litros_vecino) do
    Map.merge(litros_propios, litros_vecino, fn _dia, litros_propio, litros_ajeno ->
      litros_propio + litros_ajeno
    end)
  end

  @doc "Mapa de ejemplo del centro vecino."
  def centro_vecino_ejemplo do
    %{
      1 => 1850.5,
      2 => 2100,
      3 => 1640,
      5 => 2350,
      7 => 800
    }
  end

  # -----------------------------------------------------------------
  # Respuestas a las preguntas de la investigación:
  #
  # 1) ¿Qué habría pasado con Map.merge/2?
  #    Map.merge(propios, vecino) NO admite una función de resolución de
  #    conflictos: cuando una clave (día) existe en ambos mapas, se
  #    queda simplemente con el valor del segundo mapa (el vecino) y
  #    descarta por completo el valor del primero (el propio centro).
  #
  # 2) ¿Por qué ese resultado no es adecuado?
  #    Porque el objetivo es sumar los litros recibidos por los dos
  #    centros en un mismo día, no reemplazar un dato por otro. Con
  #    Map.merge/2 se perdería la información propia de cada día en que
  #    ambos centros tuvieron recepción, lo cual haría el reporte
  #    incorrecto (subestimaría los litros reales de esos días).
  #
  # 3) ¿Qué sucede con el día 7?
  #    El día 7 solo aparece en el mapa del centro vecino (el propio
  #    centro solo recibe leche los días 1 a 6). Como la función de
  #    conflicto de Map.merge/3 únicamente se ejecuta cuando la clave
  #    está en los dos mapas, para el día 7 no hay conflicto: su valor
  #    (800) se copia tal cual al mapa combinado, sin sumarle nada.
  # -----------------------------------------------------------------
end
