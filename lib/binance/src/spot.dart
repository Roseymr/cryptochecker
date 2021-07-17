import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';
import 'package:crypto/crypto.dart';

import '../data/spot_classes.dart';
import '../data/enums.dart';
import '../apiKey.dart' as apiKey;
import 'exceptions.dart';

class Spot {
  Future<dynamic> _private(String path, [Map<String, String?>? params]) async {
    final uri = Uri.https('api.binance.com', 'api$path', params);
    final response = await http.get(uri, headers: {
      'X-MBX-APIKEY': apiKey.public,
    });

    final result = convert.jsonDecode(response.body);

    if (result is Map) if (result.containsKey("code"))
      throw BinanceApiException(result["msg"], result["code"]);

    return result;
  }

  /// Returns general info about the account from /v3/account
  ///
  /// https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#account-information-user_data
  Future<AccountInfo> accountInfo(/*String time*/) async {
    var time = DateTime.now().millisecondsSinceEpoch;

    var key = convert.utf8.encode(apiKey.secret);
    var bytes = convert.utf8.encode('timestamp=$time');

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);

    final params = {'timestamp': '$time', 'signature': '$digest'};
    final response = await _private('/v3/account', params);

    return AccountInfo.fromMap(response);
  }
}
