# Módulo Validaciones
# --------------------
# Valida una entrega contra las 5 reglas de negocio, reportando solo el
# primer motivo derechazo encontrado. Se usa `with` para encadenar las
# verificaciones, cada cláusula solo continúa a la
# siguiente si la anterior fue exitosa (patrón `:ok <- ...`); en cuanto
# una falla, `with` salta directo a la rama `else` con el motivo
# correspondiente, sin evaluar las reglas restantes.
#
# Los conjuntos de productores válidos y tanques válidos se reciben ya
# transformados a MapSet (ver Principal), porque la pertenencia a un
# conjunto (`MapSet.member?/2`) es O(1) frente a recorrer la lista con
# `Enum.any?/2` en cada una de las validaciones; con pocas decenas de
# productores no es indispensable, pero es la estructura correcta para
# esta operación.
defmodule Validaciones do
  @doc """
  Valida una entrega. `productores_validos` y `tanques_validos` deben ser
  MapSet con los códigos de productor y de tanque existentes.

  Devuelve `{:ok, entrega}` o `{:error, motivo}`.
  """
  def validar_entrega(entrega, productores_validos, tanques_validos) do
    with :ok <- validar_productor(entrega, productores_validos),
         :ok <- validar_tanque(entrega, tanques_validos),
         :ok <- validar_dia(entrega),
         :ok <- validar_litros(entrega),
         :ok <- validar_grasa(entrega) do
      {:ok, entrega}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp validar_productor(%{productor: productor}, productores_validos) do
    if MapSet.member?(productores_validos, productor) do
      :ok
    else
      {:error, :productor_desconocido}
    end
  end

  defp validar_tanque(%{tanque: tanque}, tanques_validos) do
    if MapSet.member?(tanques_validos, tanque) do
      :ok
    else
      {:error, :tanque_desconocido}
    end
  end

  defp validar_dia(%{dia: dia}) do
    if is_integer(dia) and dia in 1..6 do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  defp validar_litros(%{litros: litros}) do
    if is_number(litros) and litros > 0 and litros <= 800 do
      :ok
    else
      {:error, :litros_fuera_de_rango}
    end
  end

  defp validar_grasa(%{grasa: grasa}) do
    if is_number(grasa) and grasa >= 0 and grasa <= 15 do
      :ok
    else
      {:error, :porcentaje_invalido}
    end
  end

  @doc "Texto legible para cada motivo de rechazo, usado en los reportes."
  def texto_motivo(:productor_desconocido), do: "Productor desconocido"
  def texto_motivo(:tanque_desconocido), do: "Tanque desconocido"
  def texto_motivo(:dia_invalido), do: "Día inválido"
  def texto_motivo(:litros_fuera_de_rango), do: "Litros fuera de rango"
  def texto_motivo(:porcentaje_invalido), do: "Porcentaje de grasa inválido"
  def texto_motivo(:formato_invalido), do: "Formato de entrada inválido"
end
