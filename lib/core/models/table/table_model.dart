// lib/core/models/tables/table_model.dart
import 'dart:convert';

class TableModel {
  final int? idTable;
  final String name;
  final int capacity;
  final String? location;
  final bool state;
  final bool isOccupied;
  final int currentOccupancy;

  TableModel({
    this.idTable,
    required this.name,
    required this.capacity,
    this.location,
    this.state = true,
    this.isOccupied = false,
    this.currentOccupancy = 0,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      idTable: json['idTable'],
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      location: json['location'],
      state: json['state'] ?? true,
      isOccupied: json['isOccupied'] ?? false,
      currentOccupancy: json['currentOccupancy'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'capacity': capacity,
      'state': state,
      'isOccupied': isOccupied,
      'currentOccupancy': currentOccupancy,
    };

    if (idTable != null) {
      data['idTable'] = idTable;
    }

    if (location != null && location!.isNotEmpty) {
      data['location'] = location;
    }

    return data;
  }

  static List<TableModel> listFromJson(String body) {
    final parsed = json.decode(body);
    return parsed.map<TableModel>((json) => TableModel.fromJson(json)).toList();
  }

  // Helper para obtener el porcentaje de ocupación
  double get occupancyPercentage {
    if (capacity == 0) return 0;
    return (currentOccupancy / capacity) * 100;
  }

  // Helper para verificar si está activa
  bool get isActive => state == true;

  // Helper para obtener el estado de ocupación
  String get occupancyStatus {
    if (!isOccupied) return 'Disponible';
    if (currentOccupancy >= capacity) return 'Llena';
    return 'Ocupada';
  }

  // Helper para obtener el color según el estado
  String get statusColor {
    if (!isOccupied) return 'green';
    if (currentOccupancy >= capacity) return 'red';
    return 'orange';
  }

  // Método copyWith para crear copias con modificaciones
  TableModel copyWith({
    int? idTable,
    String? name,
    int? capacity,
    String? location,
    bool? state,
    bool? isOccupied,
    int? currentOccupancy,
  }) {
    return TableModel(
      idTable: idTable ?? this.idTable,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      location: location ?? this.location,
      state: state ?? this.state,
      isOccupied: isOccupied ?? this.isOccupied,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
    );
  }
}

// Modelo para el detalle de ocupación de una mesa
class TableOccupancyDetail {
  final int idMesa;
  final String nombreMesa;
  final int capacidad;
  final int ocupacionActual;
  final double porcentajeOcupacion;
  final bool estaOcupada;
  final String ubicacion;

  TableOccupancyDetail({
    required this.idMesa,
    required this.nombreMesa,
    required this.capacidad,
    required this.ocupacionActual,
    required this.porcentajeOcupacion,
    required this.estaOcupada,
    required this.ubicacion,
  });

  factory TableOccupancyDetail.fromJson(Map<String, dynamic> json) {
    return TableOccupancyDetail(
      idMesa: json['idMesa'] ?? 0,
      nombreMesa: json['nombreMesa'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      ocupacionActual: json['ocupacionActual'] ?? 0,
      porcentajeOcupacion: (json['porcentajeOcupacion'] ?? 0).toDouble(),
      estaOcupada: json['estaOcupada'] ?? false,
      ubicacion: json['ubicacion'] ?? '',
    );
  }
}

// Modelo para el reporte de ocupación general
class OccupancyReport {
  final double porcentajeOcupacionGeneral;
  final String mensaje;
  final int totalMesas;
  final int mesasOcupadas;
  final int mesasLibres;
  final List<TableOccupancyDetail> detallesMesas;

  OccupancyReport({
    required this.porcentajeOcupacionGeneral,
    required this.mensaje,
    required this.totalMesas,
    required this.mesasOcupadas,
    required this.mesasLibres,
    required this.detallesMesas,
  });

  factory OccupancyReport.fromJson(Map<String, dynamic> json) {
    return OccupancyReport(
      porcentajeOcupacionGeneral:
          (json['porcentajeOcupacionGeneral'] ?? 0).toDouble(),
      mensaje: json['mensaje'] ?? '',
      totalMesas: json['totalMesas'] ?? 0,
      mesasOcupadas: json['mesasOcupadas'] ?? 0,
      mesasLibres: json['mesasLibres'] ?? 0,
      detallesMesas: (json['detallesMesas'] as List<dynamic>?)
              ?.map((item) => TableOccupancyDetail.fromJson(item))
              .toList() ??
          [],
    );
  }
}
