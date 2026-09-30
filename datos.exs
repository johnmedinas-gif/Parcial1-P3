# Integrantes: <John Edward Medina>, <Daniel Felipe Montes Villán>, <Juan Pablo Londoño Cardenas>
#
# Módulo Datos
# ------------
# Contiene el conjunto de datos de prueba del grupo para el parcial del
# centro de acopio de leche. Se entregan como listas de mapas, tal como lo
# exige el enunciado, porque así llegan "desde las planillas": una lista de
# registros sin estructura adicional. La responsabilidad de transformarlos
# a otras colecciones (mapas indexados, mapas agrupados, etc.) es de los
# módulos que los consumen (Validaciones, Calculos, Reportes), no de este
# módulo, que solo debe representar fielmente el origen de la información.
#
# Se cumplen los mínimos exigidos:
#   - 10 productores (P01 a P10)
#   - 4 productores con transporte (P01, P03, P05, P07)
#   - 4 tanques (T1 a T4)
#   - entregas en los 6 días de recepción
#   - 80 entregas válidas
#   - al menos 2 entregas inválidas por cada uno de los 5 motivos de rechazo
#     (10 entregas inválidas en total, dos por motivo)
defmodule Datos do
  def productores do
    [
      %{codigo: "P01", nombre: "Marta Gómez", transporte: true},
      %{codigo: "P02", nombre: "Luis Cardona", transporte: false},
      %{codigo: "P03", nombre: "Diana Restrepo", transporte: true},
      %{codigo: "P04", nombre: "Jorge Loaiza", transporte: false},
      %{codigo: "P05", nombre: "Sandra Osorio", transporte: true},
      %{codigo: "P06", nombre: "Carlos Buitrago", transporte: false},
      %{codigo: "P07", nombre: "Paola Zapata", transporte: true},
      %{codigo: "P08", nombre: "Andrés Valencia", transporte: false},
      %{codigo: "P09", nombre: "Liliana Marín", transporte: false},
      %{codigo: "P10", nombre: "Fernando Ospina", transporte: false}
    ]
  end

  def tanques do
    [
      %{id: "T1", nombre: "Tanque Norte", capacidad: 10000},
      %{id: "T2", nombre: "Tanque Central", capacidad: 8500},
      %{id: "T3", nombre: "Tanque Sur", capacidad: 8000},
      %{id: "T4", nombre: "Tanque Oriente", capacidad: 7500}
    ]
  end

  # 80 entregas válidas + 10 entregas inválidas (2 por motivo de rechazo),
  # mezcladas para simular la llegada real de las planillas.
  #
  # Notas sobre casos especiales incluidos a propósito:
  #   - P01 tiene entregas válidas en los 4 tanques (para el reporte R8).
  #   - P02 tiene 3 entregas (700 l al 2.0%, 50 l al 5.0%, 50 l al 5.0%) que
  #     evidencian la diferencia entre el promedio simple de grasa (4.0%) y
  #     el promedio ponderado por litros (2.375%), usada en la explicación
  #     de R6 (ver documento).
  #   - Las 10 entregas inválidas cubren, dos veces cada uno, los motivos:
  #     :productor_desconocido, :tanque_desconocido, :dia_invalido,
  #     :litros_fuera_de_rango y :porcentaje_invalido; cada una viola
  #     exactamente un motivo para poder probar el orden de validación.
  def entregas do
    [
      %{productor: "P03", tanque: "T1", dia: 3, litros: 479.4, grasa: 2.2},
      %{productor: "P09", tanque: "T2", dia: 5, litros: 250.9, grasa: 4.4},
      %{productor: "P09", tanque: "T4", dia: 2, litros: 196.7, grasa: 2.4},
      %{productor: "P08", tanque: "T1", dia: 1, litros: 529.5, grasa: 3.3},
      %{productor: "P01", tanque: "T2", dia: 2, litros: 210, grasa: 3.2},
      %{productor: "P09", tanque: "T4", dia: 2, litros: 383.4, grasa: 2.6},
      %{productor: "P04", tanque: "T2", dia: 2, litros: 446.1, grasa: 2.2},
      %{productor: "P99", tanque: "T1", dia: 1, litros: 100, grasa: 3.5},
      %{productor: "P06", tanque: "T1", dia: 1, litros: 390, grasa: 4.6},
      %{productor: "P05", tanque: "T2", dia: 6, litros: 378.1, grasa: 3.8},
      %{productor: "P01", tanque: "T2", dia: 6, litros: 364.3, grasa: 2.6},
      %{productor: "P06", tanque: "T2", dia: 6, litros: 110.1, grasa: 3.7},
      %{productor: "P06", tanque: "T4", dia: 3, litros: 900, grasa: 3.2},
      %{productor: "P03", tanque: "T1", dia: 3, litros: 322.5, grasa: 4.4},
      %{productor: "P07", tanque: "T1", dia: 4, litros: 100, grasa: -2},
      %{productor: "P10", tanque: "T1", dia: 4, litros: 533.3, grasa: 3.4},
      %{productor: "P03", tanque: "T2", dia: 4, litros: 77.8, grasa: 3.9},
      %{productor: "P03", tanque: "T4", dia: 1, litros: 746.7, grasa: 4.3},
      %{productor: "P07", tanque: "T1", dia: 5, litros: 237.3, grasa: 3.5},
      %{productor: "P04", tanque: "T2", dia: 5, litros: 493.5, grasa: 3.4},
      %{productor: "P05", tanque: "T2", dia: 5, litros: 717.1, grasa: 4.2},
      %{productor: "P08", tanque: "T2", dia: 2, litros: 647.9, grasa: 3.1},
      %{productor: "P02", tanque: "T2", dia: 2, litros: 50, grasa: 5.0},
      %{productor: "P06", tanque: "T4", dia: 6, litros: 682.1, grasa: 4.1},
      %{productor: "P03", tanque: "T3", dia: 4, litros: 239.9, grasa: 4.4},
      %{productor: "P07", tanque: "T3", dia: 4, litros: 265.4, grasa: 3.8},
      %{productor: "P04", tanque: "T1", dia: 1, litros: 569.6, grasa: 2.0},
      %{productor: "P03", tanque: "T3", dia: 3, litros: 495.5, grasa: 3.8},
      %{productor: "P02", tanque: "T3", dia: 3, litros: 50, grasa: 5.0},
      %{productor: "P01", tanque: "T4", dia: 6, litros: 304.3, grasa: 4.2},
      %{productor: "P08", tanque: "T3", dia: 2, litros: 326.5, grasa: 2.4},
      %{productor: "P05", tanque: "T1", dia: 5, litros: 517.2, grasa: 3.3},
      %{productor: "P07", tanque: "T3", dia: 2, litros: 778.1, grasa: 2.2},
      %{productor: "P04", tanque: "T3", dia: 3, litros: 173.6, grasa: 4.1},
      %{productor: "P08", tanque: "T1", dia: 1, litros: 680, grasa: 2.2},
      %{productor: "P03", tanque: "T3", dia: 5, litros: 688.2, grasa: 3.0},
      %{productor: "P05", tanque: "T4", dia: 2, litros: 543.6, grasa: 2.6},
      %{productor: "P04", tanque: "T2", dia: 4, litros: 333.2, grasa: 4.6},
      %{productor: "P06", tanque: "T3", dia: 2, litros: 542.2, grasa: 2.7},
      %{productor: "P09", tanque: "T2", dia: 6, litros: 293.5, grasa: 4.0},
      %{productor: "P08", tanque: "T2", dia: 5, litros: 120, grasa: 16},
      %{productor: "P01", tanque: "T2", dia: 1, litros: 639.6, grasa: 2.9},
      %{productor: "P06", tanque: "T4", dia: 5, litros: 599.6, grasa: 4.4},
      %{productor: "P04", tanque: "T4", dia: 1, litros: 178.5, grasa: 1.8},
      %{productor: "P08", tanque: "T4", dia: 6, litros: 390.4, grasa: 2.5},
      %{productor: "P08", tanque: "T2", dia: 1, litros: 751.8, grasa: 2.0},
      %{productor: "P01", tanque: "T3", dia: 2, litros: 551.1, grasa: 3.7},
      %{productor: "P07", tanque: "T4", dia: 6, litros: 99, grasa: 3.6},
      %{productor: "P08", tanque: "T2", dia: 5, litros: 155.3, grasa: 4.4},
      %{productor: "P06", tanque: "T3", dia: 2, litros: 101.7, grasa: 4.3},
      %{productor: "P07", tanque: "T3", dia: 1, litros: 62.6, grasa: 4.0},
      %{productor: "P01", tanque: "T1", dia: 1, litros: 260, grasa: 3.8},
      %{productor: "P03", tanque: "T4", dia: 5, litros: 105.7, grasa: 2.9},
      %{productor: "P04", tanque: "T1", dia: 1, litros: 534.5, grasa: 2.8},
      %{productor: "P01", tanque: "T3", dia: 3, litros: 180, grasa: 2.6},
      %{productor: "P05", tanque: "T1", dia: 2, litros: 683.9, grasa: 2.9},
      %{productor: "P04", tanque: "T3", dia: 1, litros: 126.8, grasa: 2.1},
      %{productor: "P09", tanque: "T2", dia: 2, litros: 535, grasa: 4.5},
      %{productor: "P03", tanque: "T1", dia: 5, litros: 108.9, grasa: 4.2},
      %{productor: "P03", tanque: "T2", dia: 7, litros: 150, grasa: 3.0},
      %{productor: "P02", tanque: "T1", dia: 6, litros: 258, grasa: 2.4},
      %{productor: "P05", tanque: "T2", dia: 2, litros: 329.2, grasa: 2.3},
      %{productor: "P04", tanque: "T2", dia: 6, litros: 284.4, grasa: 4.6},
      %{productor: "P03", tanque: "T3", dia: 1, litros: 700.6, grasa: 3.9},
      %{productor: "P02", tanque: "T3", dia: 1, litros: 483.6, grasa: 2.4},
      %{productor: "P05", tanque: "T2", dia: 6, litros: 137.8, grasa: 4.2},
      %{productor: "P01", tanque: "T1", dia: 6, litros: 285.8, grasa: 1.9},
      %{productor: "P06", tanque: "T3", dia: 1, litros: 585.4, grasa: 3.3},
      %{productor: "P02", tanque: "T1", dia: 1, litros: 700, grasa: 2.0},
      %{productor: "P09", tanque: "T1", dia: 1, litros: 114.2, grasa: 4.3},
      %{productor: "P02", tanque: "T2", dia: 5, litros: 691, grasa: 2.7},
      %{productor: "P09", tanque: "T1", dia: 5, litros: 293.4, grasa: 1.9},
      %{productor: "P07", tanque: "T1", dia: 5, litros: 271.1, grasa: 3.6},
      %{productor: "P05", tanque: "T3", dia: 2, litros: -50, grasa: 3.5},
      %{productor: "P02", tanque: "T9", dia: 1, litros: 100, grasa: 3.5},
      %{productor: "P05", tanque: "T4", dia: 3, litros: 711.8, grasa: 4.2},
      %{productor: "P04", tanque: "TX", dia: 2, litros: 150, grasa: 3.0},
      %{productor: "P05", tanque: "T1", dia: 6, litros: 648.3, grasa: 2.6},
      %{productor: "P10", tanque: "T4", dia: 2, litros: 624.9, grasa: 4.1},
      %{productor: "PXX", tanque: "T2", dia: 2, litros: 120, grasa: 3.2},
      %{productor: "P02", tanque: "T1", dia: 5, litros: 363.8, grasa: 1.9},
      %{productor: "P02", tanque: "T1", dia: 6, litros: 409.9, grasa: 2.0},
      %{productor: "P02", tanque: "T1", dia: 3, litros: 111, grasa: 2.5},
      %{productor: "P01", tanque: "T1", dia: 2, litros: 179.7, grasa: 3.2},
      %{productor: "P04", tanque: "T3", dia: 6, litros: 480.9, grasa: 4.3},
      %{productor: "P01", tanque: "T1", dia: 0, litros: 100, grasa: 3.5},
      %{productor: "P01", tanque: "T4", dia: 4, litros: 150, grasa: 4.1},
      %{productor: "P08", tanque: "T3", dia: 5, litros: 679.8, grasa: 1.8},
      %{productor: "P02", tanque: "T3", dia: 6, litros: 304.9, grasa: 2.6},
      %{productor: "P06", tanque: "T4", dia: 5, litros: 385.1, grasa: 2.5}
    ]
  end
end
