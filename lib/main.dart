import 'package:flutter/material.dart';
import 'package:proyecto/navigations/Drawer.dart';
import 'package:proyecto/screens/loginScreen.dart';
import 'package:proyecto/screens/registerScreen.dart';

void main() {
  runApp(Proyecto());
}

class Proyecto extends StatelessWidget {
  const Proyecto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Cuerpo());
  }
}

class Cuerpo extends StatelessWidget {
  const Cuerpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text("ONEFLIX")),
      drawer: MyDrawer(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("images/oneflixC.png", fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Entretenimiento de calidad"),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      irLogin(context);
                    },
                    child: Text("Login"),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      irRegister(context);
                    },
                    child: const Text("REGISTER"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void irLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Loginscreen()),
  );
}

void irRegister(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Registerscreen()),
  );
}
