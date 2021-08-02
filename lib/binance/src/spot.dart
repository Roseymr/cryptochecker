import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:crypto/crypto.dart';
import '../data/spot_classes.dart';
import 'exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Spot {
  String? apiKey;
  String? secretKey;

  Future<dynamic> _private([Map<String, String?>? params]) async {
    final uri = Uri.https('api.binance.com', 'api/v3/account', params);

    final response = await http.get(uri, headers: {
      'X-MBX-APIKEY': apiKey!,
      'Acess-Control-Alllow-Origin': '*',
    });

    final result = convert.jsonDecode(response.body);

    if (result is Map) if (result.containsKey("code"))
      throw BinanceApiException(result["msg"], result["code"]);

    return result;
  }

  /// Returns the params signed by the secret key
  Digest _signRequest(Map params, String secret) {
    var queryString = Uri(
      queryParameters: params.map(
        (key, value) => MapEntry(
          key,
          value == null ? null : value.toString(),
        ),
      ),
    ).query;
    var key = convert.utf8.encode(secret);
    var bytes = convert.utf8.encode(queryString);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);

    return digest;
  }

  /// Returns a bool that tells if the connecting to the account failed (has error)
  Future<bool> _hasError(String pub, [Map<String, String?>? params]) async {
    final uri = Uri.https('api.binance.com', 'api/v3/account', params);

    final response = await http.get(uri, headers: {
      'X-MBX-APIKEY': pub,
      'Acess-Control-Alllow-Origin': '*',
    });

    final result = convert.jsonDecode(response.body);

    if (result is Map) if (result.containsKey("code")) return true;

    return false;
  }

  /// Returns general info about the account from /v3/account
  ///
  /// https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#account-information-user_data
  Future<AccountInfo> accountInfo(int time) async {
    await _getCredentials();
    final params = {'timestamp': '$time'};

    params['recvWindow'] = '60000';
    params['signature'] = '${_signRequest(params, secretKey!)}';

    final response = await _private(params);

    return AccountInfo.fromMap(response);
  }

  /// Returns a bool that tells if the account exists or not
  Future<bool> accountExists(int time, String? pub, String? sec) async {
    final params = {'timestamp': '$time'};

    params['recvWindow'] = '60000';
    params['signature'] = '${_signRequest(params, sec!)}';

    bool error = await _hasError(pub!, params);

    if (error) return false;
    apiKey = pub;
    secretKey = sec;

    // If the account is valid store the keys on the device
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', pub);
    await prefs.setString('secretKey', sec);

    return true;
  }

  /// Change the apiKey and secretKey variables if there's anything stored on the device
  Future<void> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('apiKey');
    String? secret = prefs.getString('secretKey');

    if (key != null) apiKey = key;
    if (secret != null) secretKey = secret;
  }
}
