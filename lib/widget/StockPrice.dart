import 'package:flutter/material.dart';

class StockPrice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StockPrice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Price"),
        actions: <Widget>[],
      ),
      body: _body(),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _ok,
//        child: Icon(Icons.check),
//      ),
    );
  }

  Widget _body() {
    return Text("x");
  }

  _ok() {

  }
}