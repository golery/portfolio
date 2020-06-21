import 'package:portfolio/model/Models.dart';
import 'package:portfolio/service/Repository.dart';

class AssetCalc {
  Perf getPerf(String symbol, double lastPrice) {
    var transactions = repository.model.transactions
        .where((tx) => tx.symbol == symbol)
        .toList();
    transactions.sort((a, b) => b.time.compareTo(a.time));
    double cost;
    double performance;
    double performancePercent;
    double assetValue;
    double assetQty;
    if (lastPrice != null) {
      assetQty = 0;
      cost = 0;
      transactions.forEach((tx) {
        if (tx.type == TransactionType.BUY) {
          cost += tx.quantity * tx.price;
          assetQty += tx.quantity;
        } else if (tx.type == TransactionType.SELL) {
          cost -= tx.quantity * tx.price;
          assetQty -= tx.quantity;
        } else if (tx.type == TransactionType.DIVIDEND) {
          cost -= tx.price;
        }
      });
      assetValue = assetQty * lastPrice;
      performance = assetValue - cost;
      performancePercent = performance / cost;
    }
    return Perf(
        performance: performance,
        performancePercent: performancePercent,
        assetQty: assetQty,
        assetValue: assetValue,
        transactions: transactions);
  }
}

var assetCalc = AssetCalc();
