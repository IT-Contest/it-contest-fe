// core/network/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080',
    // baseUrl: 'http://192.168.123.111:8080',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));

  Dio get dio => _dio;
}