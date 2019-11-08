import 'package:flutter/material.dart';
import 'package:gerenciador/helpers/dp_helper.dart';
import 'package:gerenciador/widgets/inicio.dart';

class NovaListaScreen extends StatefulWidget {
  final Lista lista;
  NovaListaScreen({this.lista});

  @override
  _NovaListaScreenState createState() => _NovaListaScreenState();
}

class _NovaListaScreenState extends State<NovaListaScreen> {
  DBHelper helper = DBHelper();
  //Lista _editedLista;
  Lista _lista = Lista();
  final TextEditingController nomeController = TextEditingController();
  // final _nameFocus = FocusNode();
  // bool _userEdited = false;

  @override
  void initState() {
    super.initState();

    // if (widget.lista == null) {
    //   _editedLista = Lista();
    // } else {
    //   _editedLista = Lista.fromMap(widget.lista.toMap());
    //   nomeController.text = _editedLista.name;
    // }
  }

  _salvarLista() {
    if (nomeController.text.isNotEmpty && nomeController.text.length < 20) {
      _lista.name = nomeController.text;
      helper.saveLista(_lista);
     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => Inicio()));
       Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => Inicio()),
        ModalRoute.withName('/'),
      );
    } else {
               
 showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('ATENÇÃO'),
                content:
                    Text('O nome da Lista não pode ser vazio ou maior que 20 caracteres'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Lista'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Form(
            child: TextFormField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text('Salvar'),
              onPressed: () {
                _salvarLista();
              },
            ),
          )
        ]),
      ),
    );
  }
}
