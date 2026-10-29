import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../repositories/pasien_repository.dart';
import 'token_store.dart';

/// Klien HTTP. Token otomatis dipasang di setiap permintaan bila ada.
class ApiClient {
  ApiClient(this._token) {
    dio = Dio(
      BaseOptions(
        baseUrl: Konstanta.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _token.baca();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final TokenStore _token;
  late final Dio dio;
}

/// Mengubah kesalahan jaringan/server menjadi pesan yang aman dan mudah dipahami pengguna.
///
/// JaringanException = sementara, aman dicoba lagi nanti (tidak ada sinyal, server sibuk).
/// SesiBerakhirException = token ditolak. AppException biasa = permintaan ditolak server.
AppException petakanError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const JaringanException();
    case DioExceptionType.badResponse:
      final kode = e.response?.statusCode ?? 0;
      final data = e.response?.data;

      String? pesan;
      if (data is Map) {
        if (data['pesan'] is String) {
          pesan = data['pesan'] as String;
        } else if (data['message'] is String) {
          pesan = data['message'] as String;
        }
      }

      if (kode == 401) return const SesiBerakhirException();
      if (kode == 429) {
        return const JaringanException(
          'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
        );
      }
      if (kode >= 500) {
        return const JaringanException(
          'Server sedang bermasalah. Coba lagi nanti.',
        );
      }
      if (kode == 422 && data is Map && data['errors'] != null && data['pesan'] == null) {
        return const AppException('Isian belum benar. Periksa kembali.');
      }
      return AppException(pesan ?? 'Permintaan ditolak (kode $kode).');
    default:
      return const JaringanException('Terjadi kesalahan jaringan. Coba lagi.');
  }
}
