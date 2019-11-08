import 'package:bloc_pattern/bloc_pattern.dart';

import 'package:rxdart/rxdart.dart';

class NovoItenBloc extends BlocBase {
  // final BuildContext context;
  // NovoItenBloc(this.context);
  NovoItenBloc();

 // List<String> _listaItemPorItem2 = [];

  final _senhaCotroller = BehaviorSubject<String>();
  Observable<String> get senhaFluxo => _senhaCotroller.stream;
  Sink<String> get senhaEvent => _senhaCotroller.sink;

  final _listaItemPorItem = BehaviorSubject<List<String>>.seeded(['teste']); 
  Observable<List<String>> get listaItemPorItemFluxo =>
      _listaItemPorItem.stream;
  Sink<List<String>> get listaItemPorItemEvent => _listaItemPorItem.sink;

  teste(String index) {
    _listaItemPorItem.value.removeWhere((texto) {
     if (index==texto) {
        return true;
     }else{
        return false;
     }
    });

 
    listaItemPorItemEvent.add(_listaItemPorItem.value);
  }

  // final _senha2Cotroller = BehaviorSubject<String>();
  // Observable<String> get senha2Fluxo => _senha2Cotroller.stream;
  // Sink<String> get senha2Event => _senha2Cotroller.sink;

  // final _emailController = BehaviorSubject<String>();
  // Observable<String> get emailFluxo => _emailController.stream;
  // Sink<String> get emailEvent => _emailController.sink;

  // var _controllerLoading = BehaviorSubject<bool>.seeded(false);
  // Stream<bool> get outLoading => _controllerLoading.stream;

  @override
  void dispose() {
    _senhaCotroller.close();
    _listaItemPorItem.close();
   // _listaItemPorItem.close();
   // listaItemPorItemEvent.close();
    super.dispose();
  }
}
