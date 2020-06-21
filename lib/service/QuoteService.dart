import 'package:portfolio/model/Models.dart';
import 'package:portfolio/service/Api.dart';

class QuoteService {
  Future<Map<String, Quote>> getPrice(List<String> symbols) async {
    return api.getPrice(symbols);
  }
}

QuoteService quoteService = new QuoteService();
