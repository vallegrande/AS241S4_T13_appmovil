// lib/core/services/sales/sale_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:as241s4_t13_appmovil/config/environment.dart';
import 'package:as241s4_t13_appmovil/core/models/sales/sale_model.dart';
import 'package:as241s4_t13_appmovil/core/services/auth/auth_service.dart';

class SaleService {
  static final String _baseUrl = Environment.apiUrl;
  static const String _apiPath = '/v1/api/sales';

  // Headers con autenticación
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = AuthService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // ==========================================
  // MÉTODOS DE CONSULTA (GET)
  // ==========================================

  // Obtener todas las ventas
  static Future<List<Sale>> getAllSales() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath'), headers: _headers);
      return _processListResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener por rango de fechas
  static Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      // Formato simple YYYY-MM-DD para coincidir con el string que espera Angular
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final params = {
        'startDate': startStr,
        'endDate': endStr,
      };

      final uri = Uri.parse('$_baseUrl$_apiPath').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);
      return _processListResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener por ID
  static Future<Sale> getSaleById(int idSale) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath/$idSale'), headers: _headers);
      if (response.statusCode == 200) {
        return Sale.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar venta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener por Usuario (Nuevo)
  static Future<List<Sale>> getSalesByUser(int idUser) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath/user/$idUser'), headers: _headers);
      return _processListResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener por Cliente (Nuevo)
  static Future<List<Sale>> getSalesByCustomer(int idCustomer) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath/customer/$idCustomer'), headers: _headers);
      return _processListResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener Resumen del Día (Nuevo - Retorna Map dinámico por falta de modelo)
  static Future<Map<String, dynamic>> getTodaySummary() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath/today'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar resumen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener Más Vendidos (Nuevo - Retorna List dinámica)
  static Future<List<dynamic>> getMostSold() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$_apiPath/mas-vendidos'), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar más vendidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==========================================
  // MÉTODOS DE CREACIÓN Y MODIFICACIÓN
  // ==========================================

  // Crear Venta (CON CORRECCIÓN DE PARSEO)
  static Future<Sale> createSale(CreateSaleRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_apiPath'),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        
        // Extraer datos reales (Angular hace esto automáticamente, en Flutter es manual)
        Map<String, dynamic> saleData;
        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('sale')) {
          saleData = decodedResponse['sale'];
        } else {
          saleData = decodedResponse;
        }

        // --- FIX CRÍTICO: Rellenar datos faltantes ---
        if (saleData['customerName'] == null) {
          saleData['customerName'] = 'Cliente Procesado'; 
        }
        if (saleData['userName'] == null) {
          saleData['userName'] = 'Usuario Actual';
        }
        // ---------------------------------------------

        return Sale.fromJson(saleData);
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear ventas.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear venta');
      }
    } catch (e) {
      throw Exception('Error al crear venta: $e');
    }
  }

  // Eliminar Venta (Nuevo)
  static Future<void> deleteSale(int idSale) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl$_apiPath/$idSale'), headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar venta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar Estado (CORREGIDO: Usa Query Param como Angular)
  static Future<void> updateSaleState(int idSale, int state) async {
    try {
      // Angular: const params = new HttpParams().set('state', state.toString());
      final uri = Uri.parse('$_baseUrl$_apiPath/$idSale/state')
          .replace(queryParameters: {'state': state.toString()});

      final response = await http.patch(
        uri,
        headers: _headers,
        body: json.encode({}), // Body vacío pero existente
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==========================================
  // ARCHIVOS Y COMPROBANTES
  // ==========================================

  // Subir comprobante
  static Future<void> uploadPaymentProof(int idSale, List<int> fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$_apiPath/$idSale/upload-proof'));
      request.headers['Authorization'] = _headers['Authorization']!;
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', // Nombre del campo en backend
        fileBytes,
        filename: fileName,
      ));

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Error al subir comprobante');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Generar Recibo (PDF)
  static Future<List<int>> generateReceipt(int idSale) async {
    return _downloadBlob('$_baseUrl$_apiPath/$idSale/receipt');
  }

  // Generar Voucher (Nuevo - Ticketera)
  static Future<List<int>> getPaymentVoucher(int idSale) async {
    return _downloadBlob('$_baseUrl$_apiPath/$idSale/voucher');
  }

  // Helper para descargar archivos binarios
  static Future<List<int>> _downloadBlob(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al descargar documento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Helper para procesar listas de ventas
  static List<Sale> _processListResponse(http.Response response) {
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    
    print('=' * 50);
    print('🔍 DIAGNÓSTICO DETALLADO DE PRODUCTOS');
    print('=' * 50);
    
    if (jsonData.isNotEmpty) {
      // Revisar solo las primeras 3 ventas para no saturar
      for (var i = 0; i < jsonData.length && i < 3; i++) {
        final saleJson = jsonData[i];
        print('\n📋 Venta #${saleJson['idSale']}:');
        
        if (saleJson.containsKey('details') && saleJson['details'] is List) {
          final details = saleJson['details'] as List;
          if (details.isNotEmpty) {
            for (var j = 0; j < details.length && j < 3; j++) {
              final detail = details[j];
              print('   Producto ${j + 1}:');
              
              // Imprimir TODAS las claves disponibles
              print('     Claves disponibles: ${detail.keys.toList()}');
              
              // Buscar específicamente el nombre
              String? presentationName;
              if (detail['presentationName'] != null) {
                presentationName = detail['presentationName'].toString();
              } else if (detail.containsKey('presentation') && detail['presentation'] != null) {
                if (detail['presentation'] is Map && detail['presentation']['name'] != null) {
                  presentationName = detail['presentation']['name'].toString();
                }
              }
              
              print('     Nombre encontrado: "${presentationName ?? 'NULO'}"');
              print('     idPresentation: ${detail['idPresentation']}');
            }
          } else {
            print('   ❌ No tiene detalles');
          }
        } else {
          print('   ❌ No tiene campo "details" o no es lista');
        }
      }
    }
    
    print('=' * 50);
    
    // Parsear las ventas
    final sales = jsonData.map((json) => Sale.fromJson(json)).toList();
    
    return sales;
  } else if (response.statusCode == 403) {
    throw Exception('Acceso denegado.');
  } else {
    print('❌ Error del servidor: ${response.statusCode}');
    print('❌ Response body: ${response.body}');
    throw Exception('Error del servidor: ${response.statusCode}');
  }
}

static Future<void> _diagnosePresentationNames() async {
  try {
    final response = await http.get(Uri.parse('$_baseUrl$_apiPath'), headers: _headers);
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        print('\n🔍 DIAGNÓSTICO DE NOMBRES DE PRODUCTOS');
        print('=' * 50);
        
        for (var i = 0; i < jsonData.length && i < 3; i++) {
          final sale = jsonData[i];
          print('\n📋 Venta #${sale['idSale']}');
          
          if (sale['details'] != null && sale['details'] is List) {
            final details = sale['details'] as List;
            for (var j = 0; j < details.length && j < 3; j++) {
              final detail = details[j];
              print('  Producto ${j + 1}:');
              print('    - idPresentation: ${detail['idPresentation']}');
              print('    - presentationName: "${detail['presentationName']}"');
              print('    - ¿Tiene presentation?: ${detail.containsKey('presentation')}');
              if (detail.containsKey('presentation') && detail['presentation'] != null) {
                print('    - presentation.name: "${detail['presentation']['name']}"');
              }
            }
          } else {
            print('  ❌ No tiene detalles o details es null');
          }
        }
      }
    }
  } catch (e) {
    print('❌ Error en diagnóstico: $e');
  }
}

}