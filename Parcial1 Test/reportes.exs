# Módulo Reportes
# ----------------
# Genera los 8 reportes exigidos, exactamente en el orden del enunciado.
# Cada reporte se separa en:
#   * una función "pura" que calcula el resultado, y
#   * una función que solo se encarga de imprimirlo con EntradaSalida.
# Así, si mañana se necesita el dato de un reporte para otra cosa (como
# ya ocurre con R3, cuyo mapa de litros por día se reutiliza en la
# investigación de Map.merge/3), no hay que volver a calcularlo.
defmodule Reportes do
  # ------------------------------------------------------------------
  # R1. Entregas rechazadas con su motivo y cantidad de rechazos por motivo
  # ------------------------------------------------------------------
  @doc "rechazadas: lista de tuplas {entrega, motivo}"
  def r1_conteo_por_motivo(rechazadas) do
    rechazadas
    |> Enum.map(fn {_entrega, motivo} -> motivo end)
    |> Enum.frequencies()
  end

  def mostrar_r1(rechazadas) do
    titulo("R1. Entregas rechazadas")

    if rechazadas == [] do
      EntradaSalida.mostrar("No hubo entregas rechazadas.")
    else
      for {entrega, motivo} <- rechazadas do
        EntradaSalida.mostrar(
          "- Productor: #{entrega.productor}, Tanque: #{entrega.tanque}, " <>
            "Día: #{inspect(entrega.dia)}, Litros: #{inspect(entrega.litros)}, " <>
            "Grasa: #{inspect(entrega.grasa)} -> #{Validaciones.texto_motivo(motivo)}"
        )
      end

      EntradaSalida.mostrar("\nCantidad de rechazos por motivo:")

      for {motivo, cantidad} <- r1_conteo_por_motivo(rechazadas) do
        EntradaSalida.mostrar("  #{Validaciones.texto_motivo(motivo)}: #{cantidad}")
      end
    end
  end

  # ------------------------------------------------------------------
  # R2. Litros por tanque y porcentaje de ocupación, de mayor a menor
  # ------------------------------------------------------------------
  def r2_ocupacion_tanques(tanques, entregas_validas) do
    litros_por_tanque =
      entregas_validas
      |> Enum.group_by(& &1.tanque, & &1.litros)
      |> Enum.map(fn {tanque, lista} -> {tanque, Enum.sum(lista)} end)
      |> Map.new()

    tanques
    |> Enum.map(fn tanque ->
      litros = Map.get(litros_por_tanque, tanque.id, 0)
      porcentaje = litros / tanque.capacidad * 100

      %{id: tanque.id, nombre: tanque.nombre, litros: litros, porcentaje: porcentaje}
    end)
    |> Enum.sort_by(& &1.porcentaje, :desc)
  end

  def mostrar_r2(tanques, entregas_validas) do
    titulo("R2. Ocupación de tanques")

    for tanque <- r2_ocupacion_tanques(tanques, entregas_validas) do
      EntradaSalida.mostrar(
        "- #{tanque.nombre} (#{tanque.id}): #{formatear_numero(tanque.litros)} litros, " <>
          "#{formatear_porcentaje(tanque.porcentaje)} de ocupación"
      )
    end
  end

  # ------------------------------------------------------------------
  # R3. Litros recibidos por día y cumplimiento de la meta diaria
  # ------------------------------------------------------------------
  def r3_litros_por_dia(entregas_validas) do
    for dia <- 1..6 do
      litros =
        entregas_validas
        |> Enum.filter(&(&1.dia == dia))
        |> Enum.map(& &1.litros)
        |> Enum.sum()

      %{dia: dia, litros: litros, meta_cumplida: litros >= Calculos.meta_diaria()}
    end
  end

  @doc "Mapa %{dia => litros} listo para combinarlo con Map.merge/3 (ver Investigacion)."
  def r3_mapa_litros_por_dia(entregas_validas) do
    entregas_validas
    |> r3_litros_por_dia()
    |> Enum.map(fn %{dia: dia, litros: litros} -> {dia, litros} end)
    |> Map.new()
  end

  def mostrar_r3(entregas_validas) do
    titulo("R3. Litros recibidos por día")

    resultados = r3_litros_por_dia(entregas_validas)

    for %{dia: dia, litros: litros, meta_cumplida: cumplida} <- resultados do
      estado = if cumplida, do: "sí cumplió la meta", else: "no cumplió la meta"
      EntradaSalida.mostrar("- Día #{dia}: #{formatear_numero(litros)} litros (#{estado})")
    end

    todos = Enum.all?(resultados, & &1.meta_cumplida)
    alguno = Enum.any?(resultados, & &1.meta_cumplida)

    EntradaSalida.mostrar("\n¿Se cumplió la meta todos los días? #{si_no(todos)}")
    EntradaSalida.mostrar("¿Se cumplió la meta al menos un día? #{si_no(alguno)}")
  end

  # ------------------------------------------------------------------
  # R4. Liquidación de todos los productores, numerada, de mayor a menor neto
  # ------------------------------------------------------------------
  def r4_liquidacion_numerada(productores, entregas_validas) do
    productores
    |> Calculos.liquidar_todos(entregas_validas)
    |> Ranking.ranking(por: & &1.neto, orden: :desc)
  end

  def mostrar_r4(productores, entregas_validas) do
    titulo("R4. Liquidación de productores")

    for {posicion, liquidacion} <- r4_liquidacion_numerada(productores, entregas_validas) do
      EntradaSalida.mostrar(
        "#{posicion}. #{liquidacion.nombre} (#{liquidacion.codigo}) - " <>
          "Litros: #{formatear_numero(liquidacion.litros)}, " <>
          "Entregas: #{formatear_moneda(liquidacion.valor_entregas)}, " <>
          "Bonificación: #{formatear_moneda(liquidacion.bonificaciones)}, " <>
          "Transporte: #{formatear_moneda(liquidacion.transporte)}, " <>
          "Neto: #{formatear_moneda(liquidacion.neto)}"
      )
    end
  end

  # ------------------------------------------------------------------
  # R5. Productor con más litros entregados cada día (empates: todos)
  # ------------------------------------------------------------------
  def r5_top_diario(entregas_validas) do
    for dia <- 1..6 do
      litros_por_productor =
        entregas_validas
        |> Enum.filter(&(&1.dia == dia))
        |> Enum.group_by(& &1.productor, & &1.litros)
        |> Enum.map(fn {productor, lista} -> {productor, Enum.sum(lista)} end)

      case litros_por_productor do
        [] ->
          %{dia: dia, maximo: 0, productores: []}

        lista ->
          maximo = lista |> Enum.map(fn {_p, litros} -> litros end) |> Enum.max()
          top = lista |> Enum.filter(fn {_p, litros} -> litros == maximo end) |> Enum.map(&elem(&1, 0))
          %{dia: dia, maximo: maximo, productores: top}
      end
    end
  end

  @doc "Productor(es) que ocuparon el primer lugar en más días (empates: todos)."
  def r5_lider_de_la_semana(top_diario) do
    conteo =
      top_diario
      |> Enum.flat_map(& &1.productores)
      |> Enum.frequencies()

    if conteo == %{} do
      []
    else
      maximo = conteo |> Map.values() |> Enum.max()
      conteo |> Enum.filter(fn {_p, veces} -> veces == maximo end) |> Enum.map(&elem(&1, 0))
    end
  end

  def mostrar_r5(entregas_validas, productores) do
    titulo("R5. Productor con más litros entregados cada día")

    top_diario = r5_top_diario(entregas_validas)
    nombres = mapa_nombres(productores)

    for %{dia: dia, maximo: maximo, productores: lista} <- top_diario do
      case lista do
        [] ->
          EntradaSalida.mostrar("- Día #{dia}: sin entregas válidas")

        lista ->
          nombres_lista = Enum.map_join(lista, ", ", &Map.get(nombres, &1, &1))
          EntradaSalida.mostrar("- Día #{dia}: #{nombres_lista} (#{formatear_numero(maximo)} litros)")
      end
    end

    lideres = r5_lider_de_la_semana(top_diario)
    nombres_lideres = Enum.map_join(lideres, ", ", &Map.get(nombres, &1, &1))
    EntradaSalida.mostrar("\nPrimer lugar en más días: #{nombres_lideres}")
  end

  # ------------------------------------------------------------------
  # R6. Productor con mejor calidad (grasa ponderada por litros), con
  #     al menos 3 entregas válidas
  # ------------------------------------------------------------------
  def r6_calidad_ponderada(entregas_validas) do
    entregas_validas
    |> Enum.group_by(& &1.productor)
    |> Enum.filter(fn {_productor, lista} -> length(lista) >= 3 end)
    |> Enum.map(fn {productor, lista} ->
      litros_totales = lista |> Enum.map(& &1.litros) |> Enum.sum()
      suma_ponderada = lista |> Enum.map(&(&1.litros * &1.grasa)) |> Enum.sum()

      %{
        productor: productor,
        entregas: length(lista),
        grasa_ponderada: suma_ponderada / litros_totales,
        grasa_simple: (lista |> Enum.map(& &1.grasa) |> Enum.sum()) / length(lista)
      }
    end)
  end

  def mostrar_r6(entregas_validas, productores) do
    titulo("R6. Productor con mejor calidad (grasa ponderada por litros)")

    candidatos = r6_calidad_ponderada(entregas_validas)
    nombres = mapa_nombres(productores)

    if candidatos == [] do
      EntradaSalida.mostrar("Ningún productor tiene al menos 3 entregas válidas.")
    else
      mejor = Enum.max_by(candidatos, & &1.grasa_ponderada)

      ganadores = Enum.filter(candidatos, &(&1.grasa_ponderada == mejor.grasa_ponderada))

      for candidato <- ganadores do
        nombre = Map.get(nombres, candidato.productor, candidato.productor)

        EntradaSalida.mostrar(
          "- #{nombre} (#{candidato.productor}): grasa ponderada #{formatear_porcentaje(candidato.grasa_ponderada)} " <>
            "sobre #{candidato.entregas} entregas (promedio simple: #{formatear_porcentaje(candidato.grasa_simple)})"
        )
      end
    end
  end

  # ------------------------------------------------------------------
  # R7. Total pagado por el centro y costo promedio pagado por litro
  # ------------------------------------------------------------------
  def r7_total_y_promedio(productores, entregas_validas) do
    liquidaciones = Calculos.liquidar_todos(productores, entregas_validas)
    total_pagado = liquidaciones |> Enum.map(& &1.neto) |> Enum.sum()
    total_litros = entregas_validas |> Enum.map(& &1.litros) |> Enum.sum()

    costo_promedio = if total_litros > 0, do: total_pagado / total_litros, else: 0

    %{total_pagado: total_pagado, total_litros: total_litros, costo_promedio: costo_promedio}
  end

  def mostrar_r7(productores, entregas_validas) do
    titulo("R7. Total pagado y costo promedio por litro")

    resultado = r7_total_y_promedio(productores, entregas_validas)

    EntradaSalida.mostrar("Total pagado por el centro: #{formatear_moneda(resultado.total_pagado)}")
    EntradaSalida.mostrar("Litros válidos recibidos en la semana: #{formatear_numero(resultado.total_litros)}")
    EntradaSalida.mostrar("Costo promedio pagado por litro: #{formatear_moneda(resultado.costo_promedio)}")
  end

  # ------------------------------------------------------------------
  # R8. Productores con al menos una entrega válida en todos los tanques
  # ------------------------------------------------------------------
  def r8_productores_en_todos_los_tanques(productores, tanques, entregas_validas) do
    tanques_ids = MapSet.new(tanques, & &1.id)

    tanques_por_productor =
      entregas_validas
      |> Enum.group_by(& &1.productor, & &1.tanque)
      |> Enum.map(fn {productor, lista} -> {productor, MapSet.new(lista)} end)
      |> Map.new()

    Enum.filter(productores, fn productor ->
      tanques_del_productor = Map.get(tanques_por_productor, productor.codigo, MapSet.new())
      MapSet.subset?(tanques_ids, tanques_del_productor)
    end)
  end

  def mostrar_r8(productores, tanques, entregas_validas) do
    titulo("R8. Productores con entregas válidas en todos los tanques")

    resultado = r8_productores_en_todos_los_tanques(productores, tanques, entregas_validas)

    if resultado == [] do
      EntradaSalida.mostrar("Ningún productor entregó en todos los tanques.")
    else
      for productor <- resultado do
        EntradaSalida.mostrar("- #{productor.nombre} (#{productor.codigo})")
      end
    end
  end

  # ------------------------------------------------------------------
  # Comprobante individual de un productor (interacción final con el usuario)
  # ------------------------------------------------------------------
  @doc "Busca al productor por código; `nil` si no existe."
  def buscar_productor(productores, codigo) do
    Enum.find(productores, &(&1.codigo == codigo))
  end

  @doc "Arma el comprobante detallado de un productor, día por día."
  def comprobante_productor(productor, entregas_validas) do
    entregas_del_productor = Enum.filter(entregas_validas, &(&1.productor == productor.codigo))

    dias = entregas_del_productor |> Enum.map(& &1.dia) |> Enum.uniq() |> Enum.sort()

    detalle =
      for dia <- dias do
        entregas_del_dia = Enum.filter(entregas_del_productor, &(&1.dia == dia))
        litros_dia = entregas_del_dia |> Enum.map(& &1.litros) |> Enum.sum()
        valor_dia = entregas_del_dia |> Enum.map(&Calculos.valor_entrega/1) |> Enum.sum()
        bonificacion_dia = if litros_dia >= Calculos.litros_bonificacion(), do: Calculos.valor_bonificacion(), else: 0

        %{dia: dia, litros: litros_dia, valor: valor_dia, bonificacion: bonificacion_dia}
      end

    total_entregas = detalle |> Enum.map(& &1.valor) |> Enum.sum()
    total_bonificaciones = detalle |> Enum.map(& &1.bonificacion) |> Enum.sum()
    transporte = Calculos.descuento_transporte(entregas_validas, productor)
    neto = total_entregas + total_bonificaciones - transporte

    %{
      productor: productor,
      detalle: detalle,
      total_entregas: total_entregas,
      total_bonificaciones: total_bonificaciones,
      transporte: transporte,
      neto: neto
    }
  end

  def mostrar_comprobante(productores, entregas_validas, codigo) do
    titulo("Comprobante de productor")

    case buscar_productor(productores, codigo) do
      nil ->
        EntradaSalida.mostrar("No existe un productor con el código \"#{codigo}\".")

      productor ->
        comprobante = comprobante_productor(productor, entregas_validas)

        EntradaSalida.mostrar("Productor: #{productor.nombre} (#{productor.codigo})")

        if comprobante.detalle == [] do
          EntradaSalida.mostrar("No registra entregas válidas en la semana.")
        else
          for %{dia: dia, litros: litros, valor: valor, bonificacion: bonificacion} <- comprobante.detalle do
            EntradaSalida.mostrar(
              "  Día #{dia}: #{formatear_numero(litros)} litros, " <>
                "valor entregas #{formatear_moneda(valor)}, bonificación #{formatear_moneda(bonificacion)}"
            )
          end
        end

        EntradaSalida.mostrar("\nTotal entregas: #{formatear_moneda(comprobante.total_entregas)}")
        EntradaSalida.mostrar("Total bonificaciones: #{formatear_moneda(comprobante.total_bonificaciones)}")
        EntradaSalida.mostrar("Descuento transporte: #{formatear_moneda(comprobante.transporte)}")
        EntradaSalida.mostrar("Neto a pagar: #{formatear_moneda(comprobante.neto)}")
    end
  end

  # ------------------------------------------------------------------
  # Utilidades de formato e impresión, compartidas por todos los reportes
  # ------------------------------------------------------------------
  defp titulo(texto) do
    EntradaSalida.mostrar("")
    EntradaSalida.separador("=")
    EntradaSalida.mostrar(texto)
    EntradaSalida.separador("=")
  end

  defp mapa_nombres(productores) do
    productores |> Enum.map(&{&1.codigo, &1.nombre}) |> Map.new()
  end

  defp si_no(true), do: "Sí"
  defp si_no(false), do: "No"

  @doc "Formatea un número con separador de miles con punto, sin decimales."
  def formatear_numero(valor) do
    entero = valor |> to_float() |> Float.round(0) |> trunc()
    signo = if entero < 0, do: "-", else: ""

    cifras =
      entero
      |> abs()
      |> Integer.to_string()
      |> String.reverse()
      |> String.graphemes()
      |> Enum.chunk_every(3)
      |> Enum.map_join(".", &Enum.join/1)
      |> String.reverse()

    "#{signo}#{cifras}"
  end

  @doc "Formatea un valor monetario en pesos colombianos, redondeado al peso."
  def formatear_moneda(valor), do: "$#{formatear_numero(valor)}"

  @doc "Formatea un porcentaje con un decimal."
  def formatear_porcentaje(valor) do
    "#{Float.round(to_float(valor), 1)}%"
  end

  defp to_float(valor) when is_integer(valor), do: valor * 1.0
  defp to_float(valor), do: valor
end
