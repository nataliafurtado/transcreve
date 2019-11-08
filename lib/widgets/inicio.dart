import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador/blocs/novo-iten-bloc.dart';
import 'package:gerenciador/login/autenticacao.dart';

import 'package:gerenciador/main.dart';
import 'package:gerenciador/screens/nova_lista_screen.dart';
import 'package:gerenciador/widgets/listas.dart';
import 'package:gerenciador/widgets/nova_gravacao.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OrderOptions { excluirLista, logout }
NovoItenBloc bloc = BlocProvider.getBloc<NovoItenBloc>();
class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final Atenticacao _autenticacao = Atenticacao();

  @override
  void initState() {
 
    super.initState();
  }

  bool _mostrarExcluir = false;

  void _orderList(OrderOptions result)async {
    switch (result) {
      case OrderOptions.excluirLista:
        _mostrarExcluir = !_mostrarExcluir;
        break;
      case OrderOptions.logout:
          SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('email');
        _autenticacao.signOut().then((_) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        });

        //  Navigator.popUntil(context, ModalRoute.withName("/"));

        // Navigator.pushReplacement(context,
        //                   MaterialPageRoute(builder: (context) => LoginScreen3()));

        //                        Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (ctx) => LoginScreen3()),
        //   ModalRoute.withName('/'),
        // );

        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Excluir Lista"),
                value: OrderOptions.excluirLista,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Sair"),
                value: OrderOptions.logout,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
        title: Text(
          'TRANSCREVE',
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            NovaGravacao( bloc:bloc),
            Divider(),
            Listas(_mostrarExcluir),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => NovaListaScreen()));
        },
      ),
    );
  }
}
