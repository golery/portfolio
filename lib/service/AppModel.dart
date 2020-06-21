import 'package:portfolio/model/Models.dart';

class AppModel {
  List<Transaction> transactions = [];
  List<Meta> metas = [];
  List<String> portfolio = [
    'SPY',
    'XOP',
    'AMZN',
    'CRM',
    'TSLA',
    'UBER',
    'IVV',
    'HYG',
    'VHT',
    'VYM',
    'BSV',
    'BND'
  ];

  AppModel() {
    transactions = [
      Transaction("XOP", TransactionType.BUY,
          quantity: 20, price: 311.17, time: DateTime.parse("2020-06-16")),
    ];
    metas = [
      Meta("AMZN", "US0231351067_67_USD"),
      Meta("TSLA", "US88160R1014_67_USD"),
      Meta("UBER", "US90353T1007_65_USD"),
      Meta("CRM", "US79466L3024_65_USD"),
      Meta("IVV", "US4642872000_69_USD"),
      Meta("HYG", "US4642885135_69_USD"),
      Meta("VHT", "US92204A5048_69_USD"),
      Meta("VYM", "US9219464065_69_USD"),
      Meta("BSV", "US9219378273_69_USD"),
      Meta("BND", "US9219378356_67_USD"),
      Meta('SPY', "US78462F1030_69_USD"),
    ];
  }
}
