import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Tambahkan ini agar server tahu kita minta JSON
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ambil token terbaru dari storage
        final token = await SecureStorageService.getToken();
        
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint('🔑 [AUTH] Token ditemukan dan dikirim');
        } else {
          debugPrint('⚠️ [AUTH] Token tidak ditemukan di storage');
        }

        debugPrint('[REQUEST] ${options.method} -> ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[RESPONSE] [${response.statusCode}] -> ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final path = error.requestOptions.path;

        debugPrint('[ERROR] [$statusCode] pada $path: ${error.message}');

        if (statusCode == 401) {
          debugPrint('🚫 [UNAUTHORIZED] Token tidak valid atau sudah kadaluarsa. Menghapus storage...');
          await SecureStorageService.clearAll();
          
          // Opsional: Kamu bisa tambahkan logic di sini untuk mengarahkan user ke Login Page
          // menggunakan GlobalKey atau navigator jika diperlukan.
        }
        
        return handler.next(error);
      },
    ));

    return dio;
  }
}