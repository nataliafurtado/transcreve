import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gerenciador/blocs/novo-iten-bloc.dart';

import 'package:gerenciador/helpers/dp_helper.dart';
import 'package:gerenciador/helpers/dp_helper.dart' as prefix1;
import 'package:gerenciador/screens/player_widget.dart';
import 'package:gerenciador/widgets/inicio.dart';
import 'package:http/http.dart' as http;
//import 'package:gerenciador/helpers/dp_helper.dart' as prefix0;
import 'package:gerenciador/models/item.dart';
//import 'package:gerenciador/screens/lista_items.dart';
//import 'package:gerenciador/widgets/inicio.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:path/path.dart' as prefix0;

class NovoItem extends StatefulWidget {
  final String pathPasado;
  String recorderTxt;
  Lista listaJaExistia;
  Item itemJaExistia;
  NovoItenBloc bloc;

  NovoItem(this.pathPasado, this.recorderTxt, this.listaJaExistia,
      this.itemJaExistia, this.bloc);

  @override
  _NovoItemState createState() => _NovoItemState();
}

class _NovoItemState extends State<NovoItem> {
//NovoItenBloc bloc;

  List<String> _listaItemPorItem = [];
  DBHelper helper = DBHelper();
  final _transcritoController = TextEditingController();
  bool _transcreveu = false;
  bool _formatadaItemPorItem = false;

  bool teste = false;

  final _novoNomeController = TextEditingController();

  //var listaTextEditingControllers = <TextEditingController>[];
  //var listsTextFields = <TextField>[];

  // FlutterSound flutterSound = new FlutterSound();
  // StreamSubscription _gravacao;
  // double slider_current_position = 0.0;
  // //String _recorderTxt = '00:00:00';
  // double max_duration = 1.0;

  int indexSelecionado = 0;

  List<Lista> listas = List();

  @override
  void initState() {
    super.initState();

    if (widget.itemJaExistia == null) {
      converterAudio(widget.pathPasado);
    } else {
      _transcreveu = true;
      _transcritoController.text = widget.itemJaExistia.nome;
    }

    getAllListas();
  }

  @override
  void dispose() {
    //  bloc.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   //  selecionaIndexCertoCasoJaExistente();
  //   super.didChangeDependencies();
  // }

  // void selecionaIndexCertoCasoJaExistente() {
  //   indexSelecionado = 1;
  //   //
  //   //   print(listas.length.toString() + 'leennnggggg');
  //   //   Lista l = listas.firstWhere((i) => i.id == widget.listaJaExistia.id);
  //   //   print(l.id);
  //   //   indexSelecionado = listas.indexOf(l);
  //   // }
  // }

  void getAllListas() {
    helper.getAllListas().then((list) {
      setState(() {
        listas = list;
        if (widget.itemJaExistia != null) {
          indexSelecionado = listas.indexOf(
              listas.firstWhere((i) => i.id == widget.listaJaExistia.id));
        }
      });
    });
  }

  // void startPlayer() async {
  //   String path = await flutterSound.startPlayer(widget.pathPasado);
  //   await flutterSound.setVolume(1.0);
  //   print('startPlayer: $path');

  //   try {
  //     _gravacao = flutterSound.onPlayerStateChanged.listen((e) {
  //       if (e != null) {
  //         slider_current_position = e.currentPosition;
  //         max_duration = e.duration;

  //         DateTime date = new DateTime.fromMillisecondsSinceEpoch(
  //             e.currentPosition.toInt(),
  //             isUtc: true);
  //         String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
  //         this.setState(() {
  //           // this._isPlaying = true;
  //           widget.recorderTxt = txt.substring(0, 8);
  //         });
  //       }
  //     });
  //   } catch (err) {
  //     print('error: $err');
  //   }
  // }

  // void stopPlayer() async {
  //   try {
  //     String result = await flutterSound.stopPlayer();
  //     print('stopPlayer: $result');
  //     if (_gravacao != null) {
  //       _gravacao.cancel();
  //       _gravacao = null;
  //     }

  //     this.setState(() {});
  //   } catch (err) {
  //     print('error: $err');
  //   }
  // }

  void _salvarItemPorITem() async {
    if (_novoNomeController.text.length > 25) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('ATENÇÃO'),
              content:
                  Text('O nome da Lista não pode ser maior que 25 caracteres'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    } else if (_novoNomeController.text.isEmpty) {
      int qtdItems = await _getNumeroItemsDaLista(listas[indexSelecionado]);
      for (var i = 0; i < _listaItemPorItem.length; i++) {
        Item novoItem = Item(
          nome: _listaItemPorItem[i],
          path: widget.pathPasado,
          idListaTable: listas[indexSelecionado].id,
          marcada: false,
          gravacaoTamanho: widget.recorderTxt,
          ordem: qtdItems + 1 + i,
          data: DateTime.now().toIso8601String(),
        );
        helper.saveItem(novoItem);
      }
    } else {
      Lista _lista = Lista();
      _lista.name = _novoNomeController.text;
      print('listaName.listaName.listaName.listaName.listaName');
      print(_lista.name);
      print(_listaItemPorItem.toString());
      _lista = await helper.saveLista(_lista);

      for (var i = 0; i < _listaItemPorItem.length; i++) {
        Item novoItem = Item(
          nome: _listaItemPorItem[i],
          path: widget.pathPasado,
          idListaTable: _lista.id,
          marcada: false,
          gravacaoTamanho: widget.recorderTxt,
          ordem: i,
          data: DateTime.now().toIso8601String(),
        );
        helper.saveItem(novoItem);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => Inicio()),
        ModalRoute.withName('/'),
      );
    }
  }

  void _salvarGravacao() async {
    int qtdItems = await _getNumeroItemsDaLista(listas[indexSelecionado]);
    //  Item jaexistente = await helper.getItem(widget.pathPasado);
    if (widget.itemJaExistia != null) {
      if (_formatadaItemPorItem) {
        _salvarItemPorITem();
      } else {
        widget.itemJaExistia.idListaTable = listas[indexSelecionado].id;
        widget.itemJaExistia.gravacaoTamanho = widget.recorderTxt;
        widget.itemJaExistia.data = DateTime.now().toIso8601String();
        widget.itemJaExistia.nome = _transcritoController.text;
        helper.updateItem(widget.itemJaExistia);

        // if (_formatadaItemPorItem) {
        //   for (var i = 0; i < _listaItemPorItem.length; i++) {
        //     Item novoItem = Item(
        //       nome: _listaItemPorItem[i],
        //       path: widget.pathPasado,
        //       idListaTable: listas[indexSelecionado].id,
        //       marcada: false,
        //       gravacaoTamanho: widget.recorderTxt,
        //       ordem: qtdItems + 1,
        //       data: DateTime.now().toIso8601String(),
        //     );
        //     helper.saveItem(novoItem);
        //   }
        // }
      }
//Navigator.of(context).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => Inicio()),
        ModalRoute.withName('/'),
      );
      // Navigator.popUntil(
      //     context, ModalRoute.withName(Navigator.defaultRouteName));
      //context,
      // MaterialPageRoute(
      //     builder: (ctx) => ListaItems(listas[indexSelecionado])));

      print('jjjjjaaaa' + widget.itemJaExistia.toString());
    } else {
      if (_formatadaItemPorItem) {
        _salvarItemPorITem();
      } else {
        Item novoItem = Item(
          nome: _transcritoController.text,
          path: widget.pathPasado,
          idListaTable: listas[indexSelecionado].id,
          marcada: false,
          gravacaoTamanho: widget.recorderTxt,
          ordem: qtdItems + 1,
          data: DateTime.now().toIso8601String(),
        );
        helper.saveItem(novoItem);
      }

      // print('novooooooo' + novoItem.toString());
      Navigator.of(context).pop();
    }
  }

  void converterAudio(String caminho) async {
    // List fileBytes =
    //     await File('/storage/emulated/0/audio55555.flac').readAsBytesSync();
    // print(base64.encode(fileBytes));

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    // String caminho = '/storage/emulated/0/default.m4a';
    String nomePontoFlac = caminho.replaceAll('.m4a', '') + '\Convertido.flac';
    await _flutterFFmpeg
        .execute(
            "-i $caminho -acodec pcm_s24le -c:a flac -ac 1 -ar 16000 -sample_fmt s32 $nomePontoFlac")
        .then((rc) => print("FFmpeg process exited with rc $rc"));
// final dir = Directory('/storage/emulated/0/audio333333.flac');
//     dir.deleteSync(recursive: true);
//     print('acabou-seeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
    _enviarParaGoogleSpech(nomePontoFlac);
  }

//   String base64String(Uint16List data) {
//   return base64Encode(data);
// }

  Future<void> _enviarParaGoogleSpech(String caminho) async {
    Future.delayed(Duration(seconds: 2), () => "2");
    List fileBytes = await File(caminho).readAsBytesSync();
    String arq = await base64.encode(fileBytes);

    String corpo = json.encode({
      "config": {"encoding": "FLAC", "languageCode": "pt-BR"},
      "audio": {"content": arq}
    });
    String url =
        'https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyCmtetM_CuiTpCJZE48LSW1n-i0O-dyVfU';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response response =
        await http.post(url, headers: headers, body: corpo);

    if (response.body.contains('{}')) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('ATENÇÃO'),
              content: Text('Não foi possível entender o AUDIO'),
            );
          });

      await Future.delayed(Duration(seconds: 2));

      // Navigator.of(context).pop();
      // Navigator.of(context).pop();
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) => new Inicio()));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => Inicio()),
        ModalRoute.withName('/'),
      );
      // setState(() {
      //   _transcritoController.text = 'casa maria apartamento mona';
      //   _transcreveu = true;
      // });
    } else {
      setState(() {
        print(json.decode(response.body));
        _transcritoController.text =
        
         json.decode(response.body)['results'][0]
            ['alternatives'][0]['transcript'];
        _transcreveu = true;
      });
    }
  }

  Widget _formatadorTexto() {
    if (_formatadaItemPorItem == false && _transcreveu == true) {
      _listaItemPorItem = _transcritoController.text.split(' ');
      print(_listaItemPorItem.toString());
      print(_listaItemPorItem.length.toString() + 'length');
      for (var i = 0; i < _listaItemPorItem.length; i++) {
        String g = _listaItemPorItem.elementAt(i);
        String gg = g[0].toUpperCase() + g.substring(1);
        if (gg != null && gg.isNotEmpty) {
          _listaItemPorItem[i] = gg;
        }
      }

      bloc.listaItemPorItemEvent.add(_listaItemPorItem);

      return TextField(
        controller: _transcritoController,
        maxLines: 8,
        decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      );
    } else if (_formatadaItemPorItem == false && _transcreveu == false) {
      return Column(
        children: <Widget>[
          Text('Enviando para GOOGLE TRADUTOR'),
          CircularProgressIndicator(),
        ],
      );
    } else if (_formatadaItemPorItem == true) {
      print('passou aqui ahama hhhh');

      return StreamBuilder(
        stream: bloc.listaItemPorItemFluxo,
        builder: (context, snapshot) {
          return Container(
            height: snapshot.data == null
                ? 100
                : snapshot.data.length.toDouble() * 42,
            child: ListView.builder(
                itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                itemBuilder: (context, index) {
                  TextEditingController textEditingController =
                      TextEditingController(
                    text: snapshot.data[index],
                  );
                  textEditingController.selection = new TextSelection(
                    baseOffset: 0,
                    extentOffset: snapshot.data[index].length,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          onChanged: (texto) {
                            snapshot.data[index] = texto;
                            int i = _listaItemPorItem.indexWhere((tt) {
                              return tt == snapshot.data[index];
                            });
                            _listaItemPorItem = snapshot.data;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          bloc.teste(snapshot.data[index]);
                          _listaItemPorItem = snapshot.data;
                        },
                      )
                    ],
                  );
                }),
          );
        },
      );
    }
  }

  Future<int> _getNumeroItemsDaLista(Lista lista) async {
    return await helper.getCountItemsDeLista(lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FlatButton(
                child: const Text(
                  'Descartar',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Container(
              child: FlatButton(
                child: const Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  _salvarGravacao();
                },
              ),
            ),
          ],
        ),
      ),
      body:
          //  BlocProvider(
          //     blocs: [
          //              Bloc((i) => NovoItenBloc()),
          //           ],
          //    child:
          Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            PlayerWidget(pathPassado: widget.pathPasado),
            Container(padding: EdgeInsets.all(5), child: _formatadorTexto()),

            //   Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text(
            //     'OPÇOES DE FORMATAÇÃO',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 25,color: Theme.of(context).primaryColorDark) ,
            //   ),
            // ),
            Container(
              height: _formatadaItemPorItem ? 100 : 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Visibility(
                    visible: _formatadaItemPorItem,
                    child: RaisedButton(
                      color: Colors.amber,
                      onPressed: () {
                        _novoNomeController.text =
                            _listaItemPorItem[0] + 'Lista';

                        // _novoNomeController.addListener(() {
                        //   _novoNomeController.selection = TextSelection(
                        //       baseOffset: 0,
                        //       extentOffset: _novoNomeController.text.length);
                        // });
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('NOVA LISTA'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextFormField(
                                      controller: _novoNomeController,
                                      decoration: InputDecoration(
                                          hintText: "Nova Lista"),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      _salvarItemPorITem();
                                    },
                                    child: Text('Salvar'),
                                  )
                                ],
                              );
                            });
                      },
                      child: Text('CRIAR NOVA LISTA'),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _formatadaItemPorItem = !_formatadaItemPorItem;
                      });
                    },
                    child: _formatadaItemPorItem
                        ? Text('FORMATAR TEXTO COMPLETO')
                        : Text('FORMATAR EM ITEM POR ITEM'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'SALVAR NA LISTA',
                style: TextStyle(
                    fontSize: 25, color: Theme.of(context).primaryColorDark),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: listas.length,
                itemBuilder: (context, index) {
                  return _contactCard(context, index);
                },
              ),
            ),
          ],
        ),
        //),
      ),
    );
  }

  String _cortaString(String name) {
    if (name.length > 20) {
      return name;
    } else {
      return name;
    }
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        color: indexSelecionado == index ? Colors.pink : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.list),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listas.isEmpty
                          ? ''
                          : _cortaString(listas[index].name) ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          indexSelecionado = index;
        });
      },
    );
  }
}
