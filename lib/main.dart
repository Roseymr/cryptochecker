import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'binance/binance.dart';

/* Custom Colors */
var customColors = {
  'background': Color(0xFF343538),
  'primary': Color(0xFFF3C178),
  'secondary': Color(0xFFFE5F55),
  'neutral': Color(0xFFD1D1D1),
};

void main() => runApp(MyApp());

var rest = Binance();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BalanceWidget(),
        ),
        backgroundColor: customColors['background'],
      ),
    );
  }
}

class BalanceWidget extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

Future<String> printData(AccountInfo? acc) async {
  String res = '';

  if (acc != null)
    for (Balance b in acc.balances)
      if (b.free != 0) {
        AveragedPrice avg = await rest.averagePrice(b.asset + 'EUR');
        res +=
            '${b.asset}: ${b.free} - ${(avg.price * (b.free as double)).toStringAsFixed(2)} EUR \n';
      }

  return res;
}

class _BalanceState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(100.0),
      color: customColors['primary'],
      child: FutureBuilder<AccountInfo>(
        future: rest.accountInfo(),
        builder: (BuildContext context, AsyncSnapshot<AccountInfo> snapshot) {
          // AsyncSnapshot<Your object type>
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text('Please wait its loading...'));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return FutureBuilder<String>(
                future: printData(snapshot.data),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return Center(
                      child: Text('${snap.data}'),
                    );
                  }
                  return Center(child: Text('Please wait its loading...'));
                },
              );
          }
        },
      ),
    );
  }
}
