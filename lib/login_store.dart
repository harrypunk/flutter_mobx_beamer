import 'package:mobx/mobx.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  @observable
  bool isLogged = false;

  @action
  void doLogin() {
    isLogged = true;
  }

  @action
  void doLogout() {
    isLogged = false;
  }
}
