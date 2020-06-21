import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/model/Models.dart';
import 'package:portfolio/service/AssetCalc.dart';
import 'package:portfolio/service/QuoteService.dart';
import 'package:portfolio/service/Repository.dart';

class StockTransactionPage extends StatefulWidget {
  final String symbol;

  StockTransactionPage(this.symbol);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StockTransactionPage> {
  Map<TransactionType, String> txTypeI18n = {
    TransactionType.SELL: 'SELL',
    TransactionType.BUY: 'BUY',
    TransactionType.DIVIDEND: 'DIVIDEND',
  };
  Quote quote;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    Map<String, Quote> quotes = await quoteService.getPrice([widget.symbol]);
    setState(() {
      this.quote = quotes[widget.symbol];
    });
  }

  @override
  Widget build(BuildContext context) {
    var transactions = repository.model.transactions
        .where((tx) => tx.symbol == widget.symbol)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.symbol),
        actions: <Widget>[],
      ),
      body: _body(transactions),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _ok,
//        child: Icon(Icons.check),
//      ),
    );
  }

  Widget _body(List<Transaction> transactions) {
    var perf = assetCalc.getPerf(widget.symbol, quote?.lastPrice);

    return ListView.separated(
      itemCount: transactions.length + 1,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListTile(
              title: _header(widget.symbol, perf.performance,
                  perf.performancePercent, perf.assetValue, perf.assetQty));
        }
        return ListTile(
          title: _transaction(transactions[index - 1]),
        );
      },
    );
  }

  _header(String symbol, double performance, double performancePercent,
      double assetValue, double assetQty) {
    if (quote == null) return Text("Loading...");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$symbol ${NumberFormat.compact().format(assetQty)} x \$ ' +
              NumberFormat.decimalPattern().format(quote.lastPrice),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text('Asset Value: ' + NumberFormat.decimalPattern().format(assetValue),
            style: TextStyle(fontSize: 20)),
        Text(
            'Gain/loss: ' +
                NumberFormat.decimalPattern().format(performance) +
                ' (${NumberFormat.decimalPercentPattern(decimalDigits: 2).format(performancePercent)})',
            style: TextStyle(fontSize: 20))
      ],
    );
  }

  _transaction(Transaction transaction) {
    num price = quote?.lastPrice;
    double change;
    double gain;
    if (transaction.type == TransactionType.DIVIDEND) {
      return _dividend(transaction);
    } else {
      if (price != null) {
        change = (price - transaction.price) / transaction.price;
        gain = (price - transaction.price) * transaction.quantity;
      }
    }
    String time = transaction.time == null
        ? ''
        : DateFormat.yMd().format(transaction.time);
    String txtChange =
        change == null ? '' : NumberFormat("#0.0#%", "en_US").format(change);
    String txtGain =
        gain == null ? '' : NumberFormat.decimalPattern().format(gain);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$time'),
        Row(
          children: <Widget>[
            Text('${txTypeI18n[transaction.type]}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
                '  ${NumberFormat.compact().format(transaction.quantity)} @ ${transaction.price}'),
          ],
        ),
        Text('Change: ${txtChange}. Gain: ${txtGain}'),
      ],
    );
  }

  _dividend(Transaction transaction) {
    String time = transaction.time == null
        ? ''
        : DateFormat.yMd().format(transaction.time);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$time'),
        Row(
          children: <Widget>[
            Text('${txTypeI18n[transaction.type]}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('  ${transaction.price}'),
          ],
        ),
      ],
    );
  }
}
