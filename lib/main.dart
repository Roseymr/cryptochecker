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

var rest = Binance();
String? selectedCurrency = 'EUR';
Map<String, IconData> currencyIcon = {
  'EUR': Icons.euro,
  'USDT': Icons.attach_money,
};

void main() => runApp(MyApp());

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // App warpped arround a RestartWidget needed to reload the app properly
    return RestartWidget(
        child: MaterialApp(
      home: Scaffold(
        body: new Container(
            child: new Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 1000,
              height: 500,
              alignment: Alignment.center,
              child: BalanceWidget(),
            ),
            new Container(
              // Create the currency button on top right with some padding
              margin: const EdgeInsets.only(top: 25.0, right: 25.0),
              alignment: Alignment.topRight,
              child: CurrencyWidget(),
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

class CurrencyWidget extends StatefulWidget {
  @override
  _CurrencyState createState() => _CurrencyState();
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

// Select currency Button with clickable dropdown
class _CurrencyState extends State<CurrencyWidget> {
  // Change the currency being used every time the function is called
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

  // Save the currency preferences on the device
  void _getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currencyName = prefs.getString('currency');

    setState(() {
      selectedCurrency = currencyName;
    });
  }

  // Returns the currency that is not beign used by the user
  String _currencyOption() {
    if (selectedCurrency == 'EUR') return 'USDT';
    return 'EUR';
  }

  // When the widget is created, get the currency preference
  @override
  void initState() {
    _getCurrency();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        // Wrapping the widget on a Theme so it's possible to disable splashColor and highlightColor
        // This is done in order to not see highlight artifacts arround the rounded border of the dropdown menu
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerColor: Colors.transparent,
        ),
        child: new Container(
            // Width and position of the button
            width: 150,
            alignment: Alignment.topRight,
            child: new Container(
                // Rounded borders on the ExpansionTile
                decoration: BoxDecoration(
                  color: customColors['secondary'],
                  borderRadius: new BorderRadius.vertical(
                      top: Radius.circular(30), bottom: Radius.circular(30)),
                ),
                child: ExpansionTile(
                  iconColor: Colors.black, // Change the color of the arrow
                  // First Row with the current currency
                  title: new Row(
                    children: <Widget>[
                      Icon(
                        currencyIcon[selectedCurrency],
                        color: Colors.white,
                      ),
                      Text(
                        '  $selectedCurrency',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  // Second row with the currency avaible to switch
                  children: <Widget>[
                    new Container(
                        height: 45.0,
                        child: GestureDetector(
                          // onTap change the currency and reload the App
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        )),
                  ],
                ))));
  }
}

class _BalanceState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100, right: 10),
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
