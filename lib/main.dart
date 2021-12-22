import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:mobx/mobx.dart';
import 'package:mobx_beam/login_store.dart';

void main() async {
  runApp(const MyApp());
}

final loginStore = LoginStore();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //https://github.com/slovnicki/beamer/issues/218#issuecomment-826874856
    final routerDelegate = BeamerDelegate(
      guards: [
        /// if the user is authenticated
        /// else send them to /login
        BeamGuard(
            pathPatterns: ['/postnew'],
            check: (context, state) {
              return loginStore.isLogged;
            },
            beamToNamed: (_, __) => '/login'),

        /// if the user is anything other than authenticated
        /// else send them to /home
        BeamGuard(
            pathPatterns: ['/login'],
            check: (context, state) {
              return !loginStore.isLogged;
            },
            beamToNamed: (origin, target) {
              var his = target.history;
              for (var item in his) {
                print("history ${item.routeInformation.location}");
              }
              return '/home';
            }),
      ],
      initialPath: '/home',
      locationBuilder: (routeInformation, _) =>
          BeamerLocations(routeInformation),
    );
    return Observer(builder: (_) {
      // must read observables in observer
      final _ = loginStore.isLogged;

      var beamApp = BeamerProvider(
        routerDelegate: routerDelegate,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
        ),
      );
      return beamApp;
    });
  }
}

class BeamerLocations extends BeamLocation<BeamState> {
  BeamerLocations(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => ['/login', '/home', '/postnew'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomePage(),
      ),
      if (state.uri.pathSegments.contains('postnew'))
        const BeamPage(
          key: ValueKey('postnew'),
          title: 'Postnew',
          child: PostNewPage(),
        ),
      if (state.uri.pathSegments.contains('login'))
        const BeamPage(
          key: ValueKey('login'),
          title: 'Login',
          child: LoginPage(),
        ),
    ];
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
                onPressed: () {
                  context.beamToNamed("/postnew");
                },
                child: const Text("go post new")),
            MaterialButton(onPressed: () {
              loginStore.doLogout();
            }, child: Observer(builder: (_) {
              var t = !loginStore.isLogged ? "noeed to logout" : "logout";
              return Text(t);
            })),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: () {
            loginStore.doLogin();
          },
          child: const Text("log me in"),
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

class PostNewPage extends StatelessWidget {
  const PostNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                context.beamBack();
              },
              child: const Text("go back"),
            ),
            const Text("you can post now"),
          ],
        ),
      ),
    );
  }
}
