import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
String? selectedCurrency = 'EUR';
Map<String, IconData> currencyIcon = {
  'EUR': Icons.euro,
  'USDT': Icons.attach_money,
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RestartWidget(
        child: MaterialApp(
      home: Scaffold(
        body: new Container(
            child: new Column(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(top: 25.0, right: 25.0),
              alignment: Alignment.topRight,
              child: LanguageWidget(),
            ),
            new Container(
              height: 600,
              alignment: Alignment.center,
              child: BalanceWidget(),
            ),
          ],
        )),
        backgroundColor: customColors['background'],
      ),
    ));
  }
}

class BalanceWidget extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class LanguageWidget extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

Future<String> printData(AccountInfo? acc) async {
  String res = '';

  /*Make a total money function*/

  if (acc != null)
    for (Balance b in acc.balances)
      if (b.free != 0) {
        AveragedPrice avg =
            await rest.averagePrice(b.asset + '$selectedCurrency');
        TickerStats stat = await rest.dailyStats(b.asset + '$selectedCurrency');
        res +=
            '${b.asset}: ${b.free} - ${(avg.price * b.free).toStringAsFixed(2)} $selectedCurrency - Last Day: ${stat.priceChangePercent}%\n';
      }

  return res;
}

class _LanguageState extends State<LanguageWidget> {
  void _setCurrency() async {
    String curr;

    if (selectedCurrency == 'EUR')
      curr = 'USDT';
    else
      curr = 'EUR';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', curr);

    setState(() {
      selectedCurrency = curr;
    });
  }

  void _getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currencyName = prefs.getString('currency');

    setState(() {
      selectedCurrency = currencyName;
    });
  }

  String _currencyOption() {
    if (selectedCurrency == 'EUR') return 'USDT';
    return 'EUR';
  }

  @override
  void initState() {
    _getCurrency();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: 200,
        alignment: Alignment.topRight,
        child: new Container(
            decoration: BoxDecoration(
              color: customColors['secondary'],
              borderRadius: new BorderRadius.vertical(
                  top: Radius.circular(15), bottom: Radius.circular(15)),
            ),
            child: ExpansionTile(
              title: new Row(
                children: <Widget>[
                  Icon(
                    currencyIcon[selectedCurrency],
                    color: Colors.white,
                  ),
                  Text(
                    'Currency ($selectedCurrency)',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
              children: <Widget>[
                new Container(
                    height: 45.0,
                    child: GestureDetector(
                      onTap: () {
                        _setCurrency();
                        RestartWidget.restartApp(context);
                      },
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            currencyIcon[_currencyOption()],
                            color: Colors.white,
                          ),
                          Text(
                            '${_currencyOption()}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    )),
              ],
            )));
  }
}

class _BalanceState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(100.0),
      color: customColors['primary'],
      child: FutureBuilder<AccountInfo>(
        future: rest.accountInfo(DateTime.now().millisecondsSinceEpoch),
        builder: (BuildContext context, AsyncSnapshot<AccountInfo> snapshot) {
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
