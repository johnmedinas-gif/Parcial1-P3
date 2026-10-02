# Principal.exs
# -------------
# No es un proyecto mix: cada módulo se carga con
# Code.require_file/2, en el orden en que cada uno depende del anterior.

Code.require_file("datos.exs", __DIR__)
Code.require_file("entrada_salida.exs", __DIR__)
Code.require_file("validaciones.exs", __DIR__)
Code.require_file("calculos.exs", __DIR__)
Code.require_file("ranking.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)
Code.require_file("investigacion.exs", __DIR__)

defmodule Principal do
  def main do
    productores = Datos.productores()
    tanques = Datos.tanques()
    entregas = Datos.entregas()

    # Se transforman las listas de códigos a MapSet una sola vez: las
    # validaciones de "productor existe" y "tanque existe" se ejecutan por
    # cada entrega, así que conviene tener la pertenencia en una estructura
    # de acceso directo en lugar de recorrer la lista original cada vez.
    codigos_productores = MapSet.new(productores, & &1.codigo)
    codigos_tanques = MapSet.new(tanques, & &1.id)

    {validas_iniciales, rechazadas_iniciales} =
      clasificar_entregas(entregas, codigos_productores, codigos_tanques)

    EntradaSalida.mostrar("Datos cargados: #{length(entregas)} entregas iniciales " <>
      "(#{length(validas_iniciales)} válidas, #{length(rechazadas_iniciales)} rechazadas).")

    {validas, rechazadas} =
      atender_entrega_adicional(validas_iniciales, rechazadas_iniciales, codigos_productores, codigos_tanques)

    # Medición con :timer.tc/1: se mide el tiempo de cómputo y de impresión
    # de los ocho reportes sobre el conjunto final de entregas (el que ya
    # incluye la entrega adicional, si fue válida).
    {tiempo_microsegundos, _resultado} =
      :timer.tc(fn -> generar_reportes(productores, tanques, validas, rechazadas) end)

    EntradaSalida.mostrar("\n(Los 8 reportes se generaron en #{tiempo_microsegundos} microsegundos.)")

    mostrar_investigacion(validas)

    codigo = EntradaSalida.leer_codigo_productor()
    Reportes.mostrar_comprobante(productores, validas, codigo)
  end

  defp clasificar_entregas(entregas, codigos_productores, codigos_tanques) do
    {validas, rechazadas} =
      Enum.reduce(entregas, {[], []}, fn entrega, {validas_acum, rechazadas_acum} ->
        case Validaciones.validar_entrega(entrega, codigos_productores, codigos_tanques) do
          {:ok, entrega_valida} -> {[entrega_valida | validas_acum], rechazadas_acum}
          {:error, motivo} -> {validas_acum, [{entrega, motivo} | rechazadas_acum]}
        end
      end)

    {Enum.reverse(validas), Enum.reverse(rechazadas)}
  end

  defp atender_entrega_adicional(validas, rechazadas, codigos_productores, codigos_tanques) do
    case EntradaSalida.leer_entrega_adicional() do
      {:ok, :omitido} ->
        EntradaSalida.mostrar("No se ingresó ninguna entrega adicional.")
        {validas, rechazadas}

      {:error, :formato_invalido} ->
        EntradaSalida.mostrar_error("Formato inválido. La entrega adicional no se tuvo en cuenta.")
        {validas, rechazadas}

      {:ok, entrega} ->
        case Validaciones.validar_entrega(entrega, codigos_productores, codigos_tanques) do
          {:ok, entrega_valida} ->
            EntradaSalida.mostrar("Entrega adicional válida: se incorporó a todos los reportes.")
            {validas ++ [entrega_valida], rechazadas}

          {:error, motivo} ->
            EntradaSalida.mostrar_error(
              "La entrega adicional fue rechazada (#{Validaciones.texto_motivo(motivo)}) " <>
                "y no se tuvo en cuenta en los cálculos."
            )

            # Se agrega también a "rechazadas" para que R1 quede completo y
            # consistente con el resto de entregas descartadas de la semana.
            {validas, rechazadas ++ [{entrega, motivo}]}
        end
    end
  end

  defp generar_reportes(productores, tanques, validas, rechazadas) do
    Reportes.mostrar_r1(rechazadas)
    Reportes.mostrar_r2(tanques, validas)
    Reportes.mostrar_r3(validas)
    Reportes.mostrar_r4(productores, validas)
    Reportes.mostrar_r5(validas, productores)
    Reportes.mostrar_r6(validas, productores)
    Reportes.mostrar_r7(productores, validas)
    Reportes.mostrar_r8(productores, tanques, validas)
    :ok
  end

  defp mostrar_investigacion(validas) do
    EntradaSalida.mostrar("")
    EntradaSalida.separador("=")
    EntradaSalida.mostrar("Investigación: combinación con centro vecino (Map.merge/3)")
    EntradaSalida.separador("=")

    litros_propios = Reportes.r3_mapa_litros_por_dia(validas)
    litros_vecino = Investigacion.centro_vecino_ejemplo()
    combinado = Investigacion.combinar_litros_diarios(litros_propios, litros_vecino)

    # Solo para mostrar en pantalla se redondea a 1 decimal; el mapa que
    # entra a Map.merge/3 conserva los valores originales sin perder
    # precisión en el cálculo.
    EntradaSalida.mostrar("Litros propios por día: #{inspect(redondear_mapa(litros_propios))}")
    EntradaSalida.mostrar("Litros del centro vecino: #{inspect(litros_vecino)}")
    EntradaSalida.mostrar("Litros combinados (Map.merge/3): #{inspect(redondear_mapa(combinado))}")
  end

  defp redondear_mapa(mapa) do
    Map.new(mapa, fn {dia, litros} -> {dia, Float.round(litros * 1.0, 1)} end)
  end
end

Principal.main()
