class Quote {
  String symbol;
  double lastPrice;
  String lastTime;
  double lastChangePercent;
}

class Meta {
  String symbol;
  String key;
  Meta(this.symbol, this.key);
}

enum TransactionType { BUY, SELL, DIVIDEND }

class Transaction {
  String symbol;
  double price;
  DateTime time;
  TransactionType type;
  double quantity;
  Transaction(this.symbol, this.type, {this.quantity, this.price, this.time});
}

class Perf {
  double performance, performancePercent;
  double assetValue, assetQty;
  List<Transaction> transactions;
  Perf(
      {this.performance,
      this.performancePercent,
      this.assetValue,
      this.assetQty,
      this.transactions});
}
