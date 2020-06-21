import 'package:intl/intl.dart';
import 'package:portfolio/model/Models.dart';

class BofaCsvParser {
  Future<List<Transaction>> parseCsv(String csv) async {
    List<String> rows = csv.split("\n");
    List<Transaction> transactions = [];
    for (int i = 7; i < rows.length; i++) {
      var row = rows[i].trim();
      if (row.isEmpty) continue;
      if (row.replaceAll(",", "").trim().isEmpty) continue;
      if (row.indexOf("Total activity") >= 0) continue;

      List<String> fields = _splitRow(row);
      String description = fields[3];
      TransactionType type = _getType(description);
      if (type != null) {
        try {
          DateTime time = DateFormat.yMd().parse(fields[0]);
          String symbol = fields[5];

          double quantity, price;
          if (type == TransactionType.BUY || type == TransactionType.SELL) {
            quantity = double.parse(fields[6]).abs();
            price =
                double.parse(fields[7].replaceAll("\$", "").replaceAll(",", ""))
                    .abs();
          } else if (type == TransactionType.DIVIDEND) {
            quantity = 1;
            price = double.parse(
                fields[8].replaceAll("\$", "").replaceAll(",", ""));
          }
          Transaction tx = Transaction(symbol, type,
              quantity: quantity, price: price, time: time);
          transactions.add(tx);
        } catch (ex, stacktrace) {
          print('Fail to parse $fields $ex $stacktrace');
        }
      }
    }
    return transactions;
  }

  List<String> _splitRow(String row) {
    List<String> result = [];
    while (true) {
      var index;
      var text;
      if (row.startsWith("\"")) {
        var end = row.indexOf("\"", 1);
        index = row.indexOf(",", end);
        text = row.substring(1, end);
      } else {
        index = row.indexOf(",");
      }
      if (index < 0) {
        result.add(text ?? row);
        break;
      }
      result.add(text ?? row.substring(0, index).trim());
      if (index == row.length - 1) {
        result.add('');
        break;
      }
      row = row.substring(index + 1);
    }
    return result;
  }

  TransactionType _getType(String description) {
    if (description.indexOf("Sale") >= 0) {
      return TransactionType.SELL;
    }
    if (description.indexOf("Purchase") >= 0) {
      return TransactionType.BUY;
    }
    if (description.indexOf("Dividend") >= 0) {
      return TransactionType.DIVIDEND;
    }
    if (description.indexOf("Deposit") >= 0 ||
        description.indexOf("Withdrawal") >= 0 ||
        description.indexOf("Funds Received") >= 0 ||
        description.indexOf("Other Income") >= 0 ||
        description.indexOf("Exchange") == 0 ||
        description.indexOf("Bank Interest") >= 0) {
      return null;
    }

    print('UNKNONW type ' + description);
    return null;
  }
}
