# Módulo Calculos
# ----------------
# Funciones puras (sin IO) para todo el cálculo financiero: valor de una
# entrega según el ajuste por grasa, bonificación por volumen diario,
# descuento de transporte y liquidación final por productor.
#
# Los parámetros del negocio están definidos como atributos de módulo,
# para que estén centralizados y sea claro de dónde sale cada cifra
# usada en los cálculos.
defmodule Calculos do
  @tarifa_base 1800
  @meta_diaria 2000
  @litros_bonificacion 450
  @valor_bonificacion 25000
  @costo_transporte 18000

  def tarifa_base, do: @tarifa_base
  def meta_diaria, do: @meta_diaria
  def litros_bonificacion, do: @litros_bonificacion
  def valor_bonificacion, do: @valor_bonificacion
  def costo_transporte, do: @costo_transporte

  @doc """
  Factor multiplicador según el porcentaje de grasa de la muestra:
    * 3.5% o más          -> 1.06 (bonificación del 6%)
    * 3.0% (incl.) a 3.5%  -> 1.00 (sin ajuste)
    * 2.5% (incl.) a 3.0%  -> 0.92 (descuento del 8%)
    * menos de 2.5%        -> 0.80 (descuento del 20%)
  """
  def ajuste_por_grasa(grasa) when grasa >= 3.5, do: 1.06
  def ajuste_por_grasa(grasa) when grasa >= 3.0, do: 1.00
  def ajuste_por_grasa(grasa) when grasa >= 2.5, do: 0.92
  def ajuste_por_grasa(_grasa), do: 0.80

  @doc "Valor pagado por una entrega válida: litros x tarifa base x ajuste por grasa."
  def valor_entrega(%{litros: litros, grasa: grasa}) do
    litros * @tarifa_base * ajuste_por_grasa(grasa)
  end

  @doc """
  Agrupa las entregas válidas de un productor por día y suma los litros
  de cada día. Devuelve un mapa `%{dia => litros_totales_del_dia}`.
  """
  def litros_por_dia(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.group_by(& &1.dia, & &1.litros)
    |> Enum.map(fn {dia, lista_litros} -> {dia, Enum.sum(lista_litros)} end)
    |> Map.new()
  end

  @doc """
  Bonificación total por volumen del productor: $25.000 por cada día en
  que sumó 450 litros o más en entregas válidas.
  """
  def bonificacion_volumen(entregas_validas, codigo_productor) do
    entregas_validas
    |> litros_por_dia(codigo_productor)
    |> Map.values()
    |> Enum.count(&(&1 >= @litros_bonificacion))
    |> Kernel.*(@valor_bonificacion)
  end

  @doc "Días (sin repetir) en que el productor tuvo al menos una entrega válida."
  def dias_con_entrega(entregas_validas, codigo_productor) do
    entregas_validas
    |> Enum.filter(&(&1.productor == codigo_productor))
    |> Enum.map(& &1.dia)
    |> Enum.uniq()
  end

  @doc "Descuento de transporte: $18.000 por cada día de entrega, solo si el productor usa el servicio."
  def descuento_transporte(entregas_validas, %{codigo: codigo, transporte: true}) do
    length(dias_con_entrega(entregas_validas, codigo)) * @costo_transporte
  end

  def descuento_transporte(_entregas_validas, %{transporte: false}), do: 0

  @doc """
  Liquidación de un único productor. Si no tiene entregas válidas, todos
  los valores quedan en cero pero igual aparece en el resultado.
  """
  def liquidar_productor(productor, entregas_validas) do
    entregas_del_productor = Enum.filter(entregas_validas, &(&1.productor == productor.codigo))

    litros = entregas_del_productor |> Enum.map(& &1.litros) |> Enum.sum()
    valor_entregas = entregas_del_productor |> Enum.map(&valor_entrega/1) |> Enum.sum()
    bonificaciones = bonificacion_volumen(entregas_validas, productor.codigo)
    transporte = descuento_transporte(entregas_validas, productor)
    neto = valor_entregas + bonificaciones - transporte

    %{
      codigo: productor.codigo,
      nombre: productor.nombre,
      litros: litros,
      valor_entregas: valor_entregas,
      bonificaciones: bonificaciones,
      transporte: transporte,
      neto: neto
    }
  end

  @doc "Liquidación de todos los productores (incluye los que no entregaron)."
  def liquidar_todos(productores, entregas_validas) do
    Enum.map(productores, &liquidar_productor(&1, entregas_validas))
  end
end
