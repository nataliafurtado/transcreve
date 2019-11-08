import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador/blocs/novo-iten-bloc.dart';
      NovoItenBloc bloc = BlocProvider.getBloc<NovoItenBloc>();

class FormatadorTexto extends StatelessWidget {
  List<String> _listaItemPorItem;
      bool _formatadaItemPorItem;
      bool _transcreveu;
      TextEditingController _transcritoController;
FormatadorTexto(this._listaItemPorItem,this._formatadaItemPorItem,this._transcreveu,this._transcritoController);


  @override
  Widget build(BuildContext context) {

    return _formatadorTexto();
  }

  Widget _formatadorTexto(
      ) {
    
    if (_formatadaItemPorItem == false && _transcreveu == true) {
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
      _listaItemPorItem = _transcritoController.text.split(' ');

      for (var i = 0; i < _listaItemPorItem.length; i++) {
        String g = _listaItemPorItem.elementAt(i);
        String gg = g[0].toUpperCase() + g.substring(1);
        // if (i==1 && teste==true) {
        //}else{
        _listaItemPorItem[i] = gg;

        //}
      }
      //  bloc.listaItemPorItemEvent.add(_listaItemPorItem);

      return Container(
        height: _listaItemPorItem.length.toDouble() * 42,
        child: ListView.builder(
          itemCount: _listaItemPorItem.length,
          itemBuilder: (context, index) {
            return _listaItemPorITemWidget(
              index,
              _listaItemPorItem,
            );
          },
        ),
      );
    }
  }

  Widget _listaItemPorITemWidget(int index, List<String> listaItemPorItem) {
    TextEditingController textEditingController = TextEditingController(
      text: listaItemPorItem[index],
    );

    textEditingController.selection = new TextSelection(
      baseOffset: 0,
      extentOffset: listaItemPorItem[index].length,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            initialValue: listaItemPorItem[index],
            autofocus: true,
            onFieldSubmitted: (texto) {
              listaItemPorItem[index] = texto;
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // print(index);
            // print(_listaItemPorItem.length);

            // print(_listaItemPorItem.length);
            // setState(() {
            //   _listaItemPorItem.removeAt(index);
            //   teste = true;
            //   // _formatadaItemPorItem =  _formatadaItemPorItem;
            // });
          },
        )
      ],
    );
  }
}
