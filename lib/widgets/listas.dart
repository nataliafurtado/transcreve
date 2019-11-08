import 'package:flutter/material.dart';
import 'package:gerenciador/helpers/dp_helper.dart';
import 'package:gerenciador/models/item.dart';
import 'package:gerenciador/screens/lista_items.dart';

class Listas extends StatefulWidget {
  bool mostrarExcluir = false;

  Listas(this.mostrarExcluir);

  @override
  _ListasState createState() => _ListasState();
}

class _ListasState extends State<Listas> {
  DBHelper helper = DBHelper();

  List<Lista> listas = List();

  @override
  void initState() {
    super.initState();
    // Lista l = Lista();
    // l.name = 'uuuuuuuuuuuuuu';
    // helper.saveLista(l);

    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: listas.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.list),
                  ),
                  Text(
                    listas.isEmpty
                        ? ''
                        : _cortaString(listas[index].name) ?? "",
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Visibility(
                visible: widget.mostrarExcluir,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('ATENÇÃO'),
                            content: Text(
                                'Tem certeza que deseja excluir os items marcados ?'),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('CANCELAR'),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  List<Item> l = await helper
                                      .getItems(listas.elementAt(index));
                                  for (var i = 0; i < l.length; i++) {
                                    helper.deleteItem(l[i].id);
                                  }
                                  await helper
                                      .deleteLista(listas.elementAt(index).id);
                                  setState(() {
                                    listas.removeAt(index);
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('EXCLUIR'),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (ctx) => ListaItems(listas[index])));
      },
    );
  }

// ListTile _tile(String title) => ListTile(
//       title: Text(title,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 20,
//           )),
//       leading: Icon(
//         Icons.list,
//         color: Colors.blue[500],
//       ),
//     );

  void getAllContacts() {
    helper.getAllListas().then((list) {
      setState(() {
        listas = list;
      });
    });
  }

  String _cortaString(String name) {
    if (name.length > 20) {
      return name;
    } else {
      return name;
    }
  }
}
