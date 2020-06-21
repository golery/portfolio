import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:portfolio/model/Models.dart';
import 'package:portfolio/service/BofaCsvParser.dart';
import 'package:portfolio/service/Repository.dart';

// https://www.swissquote.ch/mobile/android/Quote.action?formattedList&addServices=true&formatNumbers=true&listType=Quotes&api=2&format=json&formatNumbers=true&framework=5.1.1&l=en&locale=en_US&mobile=android&version=60107.0&wl=sq&mid=2580395469211932394&s=AMZN
class Api {
  String _key = "OjViNDQxZjE2YzViMjQyNGU3ZDNkOTg1ZDMwMjRmM2U5";

//  Future<Quote> getPrice(String symbol) async {
//    String url =
//        "https://api-v2.intrinio.com/securities/$symbol/prices/realtime?api_key=$_key";
//    var response = await http.get(url);
//    print('${response.body}');
//    var json = convert.jsonDecode(response.body);
//    Quote quote = new Quote();
//    quote.lastPrice = json["last_price"];
//    quote.lastTime = json["last_time"];
//    return quote;
//  }
  Future<Map<String, Quote>> getPrice(Iterable<String> symbols) async {
    var metas = repository.model.metas;
    String list = symbols.map((symbol) {
      var meta =
          metas.firstWhere((o) => o.symbol == symbol, orElse: () => null);
      if (meta == null) return "&s=" + symbol + ",u";
      return "&s=" + meta.key;
    }).join("");
    String url =
        "https://www.swissquote.ch/mobile/android/Quote.action?formattedList&addServices=true&formatNumbers=true&listType=Quotes&$list&api=2&format=json&formatNumbers=true&framework=5.1.1&l=en&locale=en_US&mobile=android&version=60107.0&wl=sq&mid=2580395469211932394";
    print('Load ' + url);
    var response = await http.get(url);
    print('${response.body}');
    List<dynamic> json = convert.jsonDecode(response.body);
    Map<String, Quote> quotes = {};
    json.forEach((o) {
      Quote quote = new Quote();
      quote.lastPrice = _parsePrice(o["last"]);
      quote.lastTime = o["lastTime"];
      quote.symbol = o["symbol"];
      quote.lastChangePercent = _parsePrice(o["lastChangePercent"]);
      quotes[quote.symbol] = quote;
    });

    return quotes;
  }

  double _parsePrice(String text) {
    String txt = text.replaceAll(",", "");
    return double.tryParse(txt);
  }

  Future<List<Transaction>> getTransaction() async {
    String url =
        "https://drive.google.com/uc?id=1NAY5piWcVSnlcMiyMcZ_wc9_tKgLSH49";
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    url = json["url"];
    print('Download Bofa from ' + url);
    response = await http.get(url);
    return await BofaCsvParser().parseCsv(response.body);
  }
}

var api = new Api();
