import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/model/Models.dart';
import 'package:portfolio/service/Api.dart';
import 'package:portfolio/service/AssetCalc.dart';
import 'package:portfolio/service/Repository.dart';
import 'package:portfolio/widget//StockTransactionPage.dart';

void main() => runApp(MyApp());

// https://api-v2.intrinio.com/securities/AAPL/prices/realtime?api_key=OjY3NDhlZDEwZGJhMjQ2MTMxMTA4MzBkOTZkNGJiY2Q1

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Assets'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Quote> _quotes = {};
  Map<String, Perf> _perfs = {};

  void _load() async {
    var transactions = await api.getTransaction();
    var symbols = transactions.map((e) => e.symbol).toSet();
    _quotes = await api.getPrice(symbols);

    repository.model.transactions = transactions;
    setState(() {});
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _quoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _item(String symbol) {
    TextStyle style = TextStyle(fontSize: 20);
    Quote quote = _quotes[symbol];
    double lastPrice;
    String lastTime;
    if (quote != null) {
      lastPrice = quote.lastPrice;
      lastTime = quote.lastTime;
    }
    var lastChangePct = quote.lastChangePercent;
    String lastChangePctTxt =
        NumberFormat.decimalPercentPattern(decimalDigits: 2)
            .format(lastChangePct / 100);

    Widget first = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(symbol, style: style.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: <Widget>[
            Text('\$$lastPrice', style: style),
            Text(' ($lastChangePctTxt)',
                style: style.copyWith(color: _getChangeColor(lastChangePct))),
          ],
        ),
      ],
    );
    Widget second;
    var perf = assetCalc.getPerf(symbol, lastPrice);
    var totalTxt = NumberFormat.decimalPattern().format(perf.assetValue);
    var txPrice = _getLastTransaction(perf).price;
    var costTxt = NumberFormat.decimalPattern().format(txPrice);
    var changePct = (lastPrice - txPrice) / txPrice;
    var changePctTxt =
        NumberFormat.decimalPercentPattern(decimalDigits: 2).format(changePct);
    var gainLossTxt = NumberFormat.decimalPattern().format(perf.performance);
    second = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("Asset: \$$totalTxt", style: style),
        Row(
          children: <Widget>[
            Text("Last Tx: ",
                style: style.copyWith(fontWeight: FontWeight.bold)),
            Text("$changePctTxt",
                style: style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getChangeColor(changePct))),
          ],
        ),
      ],
    );

    var third = Row(
      children: <Widget>[
        Text("Gain/Loss: ", style: style),
        Text(gainLossTxt, style: style),
      ],
    );

    return InkWell(
        onTap: () => _openStock(symbol),
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(children: <Widget>[first, second, third])));
  }

  Color _getChangeColor(double lastChangePct) {
    if (lastChangePct == null || lastChangePct == 0) return Colors.black;
    return lastChangePct > 0 ? Color(0xff037d50) : Colors.red;
  }

  Transaction _getLastTransaction(Perf perf) {
    return perf.transactions.firstWhere((tx) =>
        tx.type == TransactionType.BUY || tx.type == TransactionType.SELL);
  }

  _openStock(String symbol) {
    Navigator.of(context).push(new MaterialPageRoute<void>(
      builder: (context) => StockTransactionPage(symbol),
    ));
  }

  Widget _quoteList() {
    var symbols = _quotes.keys.toList();
    symbols.forEach((symbol) =>
        _perfs[symbol] = assetCalc.getPerf(symbol, _quotes[symbol].lastPrice));
    symbols = symbols.where((element) => _perfs[element].assetQty > 0).toList();
    symbols.sort();
    Widget list = ListView.separated(
        itemCount: symbols.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.blueGrey,
            ),
        itemBuilder: (BuildContext context, int index) {
          String symbol = symbols[index];
          return _item(symbol);
        });
    return list;
  }
}
