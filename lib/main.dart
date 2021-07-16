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

//var a = DateTime.now().millisecondsSinceEpoch.toString();

var rest = Binance();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Balance(),
        ),
        backgroundColor: customColors['background'],
      ),
    );
  }
}

class Balance extends StatefulWidget {
  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
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
              return Center(
                  child: new Text(
                      '${snapshot.data.toString()}')); // snapshot.data  :- get your object which is pass from your downloadData() function
          }
        },
      ),
    );
  }
}
