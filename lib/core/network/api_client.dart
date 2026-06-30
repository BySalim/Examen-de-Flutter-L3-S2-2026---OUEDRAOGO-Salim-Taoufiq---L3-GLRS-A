import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  final http.Client _http;

  ApiClient([http.Client? client]) : _http = client ?? http.Client();

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String _serviceDown =
      "Service indisponible : vérifiez que l'API BadWallet est démarrée.";

  Future<dynamic> get(String url) {
    return _send(() => _http.get(Uri.parse(url), headers: _jsonHeaders));
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) {
    return _send(() => _http.post(
          Uri.parse(url),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        ));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request().timeout(const Duration(seconds: 15));
    } on SocketException {
      throw ApiException(_serviceDown);
    } on http.ClientException {
      throw ApiException(_serviceDown);
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre.');
    }
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final status = response.statusCode;
    final body = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));

    if (status >= 200 && status < 300) return body;

    final serverMessage =
        (body is Map && body['message'] is String) ? body['message'] as String : null;
    throw ApiException(serverMessage ?? _messageForStatus(status),
        statusCode: status);
  }

  String _messageForStatus(int status) {
    switch (status) {
      case 400:
        return 'Requête invalide.';
      case 404:
        return 'Ressource introuvable.';
      case 409:
        return 'Conflit : la ressource existe déjà.';
      case 422:
        return 'Opération impossible : fonds insuffisants ou données invalides.';
      default:
        return 'Une erreur est survenue.';
    }
  }

  void close() => _http.close();
}
