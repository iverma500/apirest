import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/Gif.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP REST API',

      // to hide debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('APP REST API'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FutureGifs(),
              ),
            ),
            child: Text('GIFS en tendencia'),
          ),
        ),
      ),
    );
  }
}

class FutureGifs extends StatelessWidget {
  /// Función que devuelve la lista de Gifs GIPHY
  /// con un delay de 2 segundos
  /// Esta función trabaja asincronamente
  Future<List<Gif>> getData() {
    return Future.delayed(Duration(seconds: 2), () async {
      final response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=fB26WdcPXrwzVCS2XnL1l06XYvhUiLTw&limit=10&rating=g'));

      if(response.statusCode == 200){
        List<Gif> gifs = [];

        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);

        for(var item in jsonData["data"]){
          gifs.add(Gif(item["title"], item["images"]["downsized"]["url"]));
        }
        print(jsonData);
        return gifs;

      } else {
        throw Exception("Fallo en la conexión");
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gifs destacados'),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            // si código de conexión == 200
            if (snapshot.connectionState == ConnectionState.done) {
              // salida de error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} ha ocurrido',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // si hay datos llenamos un grid view con los gifs
                //con filas de 2 gifs
              } else if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount: 2,
                  children: getGifs(snapshot.data),
                );
              }
            }

            // muestra de indicador para la espera del usuario
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          //obtener datos de la API REST
          future: getData(),
        ),
      ),
    );
  }

  List<Widget> getGifs(List<Gif>? data){
      List<Widget> getData = [];
      //crear un card con el gif y su nombre
      for(var item in data!){
        getData.add(
          Card(
            child: Column(
              children: [
                Expanded(child: Image.network(item.url, fit: BoxFit.fill,),)
              ],
            ),
          )
        );
      }

      return getData;
  }
}