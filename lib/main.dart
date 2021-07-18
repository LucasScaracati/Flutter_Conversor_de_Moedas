import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=6cd2096c";
main() async {
  var url = Uri.parse(request);
  http.Response response = await http.get(url);
  // print(request.toString());
  //print('Response status: ${response.statusCode}');
  //print('Response body: ${response.body}');
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  var url = Uri.parse(request);
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar = 0;
  double euro = 0;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    double dollar = double.parse(text);
    realController.text = funConvert(dollar, this.dollar);
    euroController.text = funConvert2(dollar, this.dollar, euro);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = funConvert(euro, this.euro);
    dolarController.text = funConvert2(euro, this.euro, dollar);
  }

  String funConvert(double text, double moeda) {
    return (text * moeda).toStringAsFixed(2);
  }

  String funConvert2(double text, double moeda, double moeda2) {
    return (text * moeda / moeda2).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados ...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          bulidTestFiled("Real", "R\$", realController,
                              _realChanged, _clearAll),
                          Divider(),
                          bulidTestFiled("Dollar", "US\$", dolarController,
                              _dollarChanged, _clearAll),
                          Divider(),
                          bulidTestFiled("Euro", "€", euroController,
                              _euroChanged, _clearAll),
                          Divider(),
                        ]));
              }
          }
        },
      ),
    );
  }
}

Widget bulidTestFiled(String label, String prefix, TextEditingController c,
    Function f, Function a) {
  return TextField(
      controller: c,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: (value) {
        if (value.isNotEmpty) {
          f(value);
        } else {
          a();
        }
      },
      keyboardType: TextInputType.number);
}
