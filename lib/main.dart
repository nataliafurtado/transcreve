import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador/blocs/novo-iten-bloc.dart';
import 'package:gerenciador/login/login-bloc.dart';
import 'package:gerenciador/login/login.dart';
import 'package:gerenciador/widgets/inicio.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          child: BlocProvider(blocs: [
            Bloc((i) => LoginBloc(context)),




            
            Bloc((i) => NovoItenBloc()),
             
          ], child: LoginScreen3()),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
