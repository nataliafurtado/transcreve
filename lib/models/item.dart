//import 'dart:io';

//import 'package:flutter/material.dart';

class Item {
  int id;
  String nome;
  String path;
  int idListaTable;
  bool marcada;
  int ordem;
  String data;
  String gravacaoTamanho;

  Item(
      {this.id,
      this.nome,
      this.path,
      this.idListaTable,
      this.marcada,
      this.ordem,
      this.data,
      this.gravacaoTamanho});

  Map toMap() {
    Map<String, dynamic> map = {
      'nameColumn': nome,
      'idListaTable': idListaTable,
      'path': path,
      'marcada': marcada,
      'ordem': ordem,
      'data': data,
      'gravacaoTamanho':gravacaoTamanho,
    };
    if (id != null) {
      map['idColumn'] = id;
    }
    //  if(marcada){

    //  }
    return map;
  }

  Item.fromMap(Map map) {
    id = map['idColumn'];
    nome = map['nameColumn'];
    path = map['path'];
    gravacaoTamanho=map['gravacaoTamanho'];
    idListaTable = map['idListaTable'];
    if (map['marcada'] == 0 || map['marcada'] == null) {
      marcada = false;
    } else {
      marcada = true;
    }
    ordem = map['ordem'];
    data = map['data'];
  }

  @override
  String toString() {
    return "Lista(id: $id, name: $nome,path:$path, idlistatablee $idListaTable, marcada ,$marcada, gravacaotamanho $gravacaoTamanho, ordem $ordem,data $data)";
  }
}
