import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador/helpers/dp_helper.dart';
import 'package:gerenciador/login/autenticacao.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc extends BlocBase {
  final BuildContext context;
  LoginBloc(this.context);
//  LoginBloc();

  // await _autenticacao.signOut();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  GoogleSignInAccount _currentUser;

  final Atenticacao _autenticacao = Atenticacao();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _senhaCotroller = BehaviorSubject<String>();
  Observable<String> get senhaFluxo => _senhaCotroller.stream;
  Sink<String> get senhaEvent => _senhaCotroller.sink;

  final _senha2Cotroller = BehaviorSubject<String>();
  Observable<String> get senha2Fluxo => _senha2Cotroller.stream;
  Sink<String> get senha2Event => _senha2Cotroller.sink;

  final _emailController = BehaviorSubject<String>();
  Observable<String> get emailFluxo => _emailController.stream;
  Sink<String> get emailEvent => _emailController.sink;

  var _controllerLoading = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get outLoading => _controllerLoading.stream;

  // Future<String> onClickGoogle() async {
  //   String erro = '';
  //   try {
  //     _currentUser = await _googleSignIn.signIn();
  //   } catch (error) {
  //     erro = error;
  //     print(error);
  //   }

  //   if (_currentUser != null) {
  //     erro = null;
  //   }
  //   return erro;
  // }

  Future<String> garantirEstarLogadoGoolgle() async {
    String erro = 'Um erro ocorreu. ';
    GoogleSignInAccount user = _googleSignIn.currentUser;
    FirebaseUser user1;
    // if (user == null) {
    user = await _googleSignIn.signIn();
    print('logou google');

    //  }

    // if (await _auth.currentUser() == null) {
    GoogleSignInAuthentication credentialGoogle =
        await _googleSignIn.currentUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: credentialGoogle.accessToken,
      idToken: credentialGoogle.idToken,
    );

    user1 = (await _auth.signInWithCredential(credential)).user;
    // hyhy
    // }
    _currentUser = user;

    if (user != null) {
      erro = null;

      _emailController.value = user.email;

      // try {
      //   await _autenticacao.loginUser(
      //       _emailController.value, _senhaCotroller.value);
      // } catch (e) {
      //   erro = e.code;
      //   return erro;
      // }

      _carregarSharedPerferenciasLogado(_emailController.value);
    }
    return erro;

    // String erro = 'Um erro ocorreu. ';
    // GoogleSignInAccount user = _googleSignIn.currentUser;
    // print(user?.email); // ummmmmmmmmmmmmm
    // if (user == null) {
    //   if (true) {
    //     user = await _googleSignIn.signIn();
    //     if (await _auth.currentUser() == null) {
    //       GoogleSignInAuthentication credentialGoogle =
    //           await _googleSignIn.currentUser.authentication;
    //       //   await _auth.signInWithCustomToken(token: credential.idToken);
    //       final AuthCredential credential = GoogleAuthProvider.getCredential(
    //         accessToken: credentialGoogle.accessToken,
    //         idToken: credentialGoogle.idToken,
    //       );

    //       final FirebaseUser user =
    //           (await _auth.signInWithCredential(credential)).user;
    //       print("signed in " + user.displayName);
    //     }
    //   }
    // }
    // _currentUser = user;

    // if (user != null) {
    //   erro = null;
    // }
    //    _carregarSharedPerferenciasLogado(_emailController.value);
    // return erro;
  }

  Future<String> verSeEstaLogado() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;

      if (_currentUser != null) {
        //0fazer o q tem q fazer se logado
        return null;
      }
    });

    return 'Algo ocorreu';
  }

  DBHelper helper = DBHelper();
  Future<String> logar() async {
    String aviso = '';
    if (_senhaCotroller.value == null || _emailController.value == null) {
      return 'Preencha todos os campos';
    }
//  _emailController.value = 'qq@qq.com';
//     _senhaCotroller.value = 'qqqqqq';

    _emailController.value = _emailController.value.trim();
    _senhaCotroller.value = _senhaCotroller.value.trim();
    _controllerLoading.add(!_controllerLoading.value);
    try {
      await _autenticacao.loginUser(
          _emailController.value, _senhaCotroller.value);
      // _emailController.value, _senhaCotroller.value);
      aviso = null;
    } catch (e) {
      aviso = e.code;
    }

    _controllerLoading.add(!_controllerLoading.value);
    _carregarSharedPerferenciasLogado(_emailController.value);
    return aviso == null ? null : _excecaoAviso(aviso);
  }

  _carregarSharedPerferenciasLogado(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  Future<String> novoUsuario() async {
    String aviso = '';
    if (_senhaCotroller.value != _senha2Cotroller.value) {
      return 'As senhas estão diferentes';
    } else if (_senhaCotroller.value == null ||
        _senha2Cotroller.value == null ||
        _emailController.value == null) {
      return 'Preencha todos os campos';
    }

    _controllerLoading.add(!_controllerLoading.value);
    try {
      await _autenticacao.signUp(
          _emailController.value.trim(), _senhaCotroller.value.trim());
      aviso = null;
    } catch (e) {
      aviso = e.code;
    }
    Lista _lista = Lista();
    _lista.name = 'Nova Lista';
    helper.saveLista(_lista);

    _controllerLoading.add(!_controllerLoading.value);
    return aviso == null ? null : _excecaoAvisoNovoUsuario(aviso);
  }

  String _excecaoAviso(String aviso) {
    if (aviso.contains('ERROR_WRONG_PASSWORD')) {
      return 'Senha errada';
    } else if (aviso.contains('ERROR_INVALID_EMAIL')) {
      return 'Email inválido';
    } else if (aviso.contains('ERROR_USER_NOT_FOUND')) {
      return 'Usuário não encontrado';
    } else if (aviso.contains('ERROR_TOO_MANY_REQUESTS')) {
      return 'Muitas tentativas, aguarde e tente denovo';
    } else if (aviso.contains('ERROR_OPERATION_NOT_ALLOWED')) {
      return 'Usuário não permitido';
    }
  }

  String _excecaoAvisoNovoUsuario(String aviso) {
    if (aviso.contains('ERROR_WEAK_PASSWORD')) {
      return 'Senha fraca';
    } else if (aviso.contains('ERROR_INVALID_EMAIL')) {
      return 'Email inválido';
    } else if (aviso.contains('ERROR_EMAIL_ALREADY_IN_USE')) {
      return 'Email ja possui conta ativa';
    }
  }

  String _excecaoRecuperacaoEmail(String aviso) {
    if (aviso.contains('ERROR_INVALID_EMAIL')) {
      return 'Email inválido!';
    } else if (aviso.contains('ERROR_USER_NOT_FOUND')) {
      return 'Usuário não encontrado!';
    }
    return 'Email não encontrado!';
  }

  @override
  Future<String> resetPassword() async {
    String aviso;
    if (_emailController.value == null || _emailController.value.isEmpty) {
      return 'Digite um email válido!';
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.value);
      aviso = null;
    } catch (e) {
      // print(e.code);
      aviso = _excecaoRecuperacaoEmail(e.code);
    }
    return aviso;
  }

  @override
  void dispose() {
    _controllerLoading.close();
    _emailController.close();
    _senhaCotroller.close();
    _senha2Cotroller.close();
    super.dispose();
  }
}
