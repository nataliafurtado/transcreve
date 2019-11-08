import 'package:flutter/material.dart';
import 'package:gerenciador/helpers/dp_helper.dart';
import 'package:gerenciador/models/item.dart';
import 'package:gerenciador/screens/novo_item.dart';

enum OrderOptions { orderaz, orderza, excluirMarcadas }

class ListaItems extends StatefulWidget {
  final Lista lista;

  ListaItems(this.lista);

  @override
  _ListaItemsState createState() => _ListaItemsState();
}

class _ListaItemsState extends State<ListaItems> {
  DBHelper helper = DBHelper();
  List<Item> listaItems = [];

  void _getListItens() async {
    List<Item> l = await helper.getItems(widget.lista);

    setState(() {
      listaItems = l;
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        listaItems.sort((a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        listaItems.sort((a, b) {
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
      case OrderOptions.excluirMarcadas:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('ATENÇÃO'),
                content:
                    Text('Tem certeza que deseja excluir os items marcados ?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('CANCELAR'),
                  ),
                  FlatButton(
                    onPressed: () {
                      _excluriMarcadas();
                      Navigator.of(context).pop();
                    },
                    child: Text('EXCLUIR'),
                  ),
                ],
              );
            });

        break;
    }
    setState(() {});
  }

  void _excluriMarcadas() {
    List<Item> listaMarcados = listaItems.where((i) {
      return i.marcada == true;
    }).toList();

    listaMarcados.forEach((i) {
      helper.deleteItem(i.id);
    });

    _getListItens();
  }

  @override
  void initState() {
    super.initState();
    _getListItens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista.name),
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Excluir Marcadas"),
                value: OrderOptions.excluirMarcadas,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: listaItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => NovoItem(
                            listaItems[index].path,
                            '00:00:00',
                            widget.lista,
                            listaItems[index],
                            null
                          )));
            },
            leading: Checkbox(
              value: listaItems[index].marcada,
              onChanged: (marcadaBool) {
                setState(() {
                  listaItems[index].marcada = marcadaBool;
                });
                helper.updateItem(listaItems[index]);
              },
            ),
            title: Text(
              listaItems[index].nome,
              style: Theme.of(context).textTheme.headline,
            ),
          );
        },
      ),
    );
  }
}
