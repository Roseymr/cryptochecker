import 'package:cryptochecker/binance/binance.dart';

/// Represents the Balances contained within [AccountInfo.balances]
///
/// https://binance-docs.github.io/apidocs/spot/en/#account-information-user_data
class Balance {
  final String asset;
  final double free;
  final double locked;

  Balance.fromMap(Map m)
      : this.asset = m['asset'],
        this.free = double.parse(m['free']),
        this.locked = double.parse(m['locked']);
}

/// Current account information
///
/// https://binance-docs.github.io/apidocs/spot/en/#account-information-user_data
class AccountInfo {
  final int makerCommission;
  final int takerCommission;
  final int buyerCommission;
  final int sellerCommission;
  final bool canTrade;
  final bool canWithdraw;
  final bool canDeposit;
  final DateTime updateTime;
  final String accountType;
  final List<Balance> balances;
  final List<String> permissions;

  AccountInfo.fromMap(Map m)
      : this.makerCommission = m['makerCommission'],
        this.takerCommission = m['takerCommission'],
        this.buyerCommission = m['buyerCommission'],
        this.sellerCommission = m['sellerCommission'],
        this.canTrade = m['canTrade'],
        this.canWithdraw = m['canWithdraw'],
        this.canDeposit = m['canDeposit'],
        this.updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        this.accountType = m['accountType'],
        this.balances =
            m['balances'].map<Balance>((b) => Balance.fromMap(b)).toList(),
        this.permissions = List<String>.from(m['permissions']);
}
