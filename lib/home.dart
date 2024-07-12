import 'package:flutter/material.dart';
import 'dart:math';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

//Declaración de variables
class _HomeState extends State<Home> {
  List<int> numerosMenores = [];
  List<int> numerosMayores = [];
  List<Map<String, dynamic>> historial = [];
  String nivel = 'facil'; // Nivel inicial
  String numeroAleatorio = '';
  final TextEditingController numeroController = TextEditingController();
  String mensaje = '';
  int numeroIntentos = 5;
  int intentoClic = 0;
  int intentosRestantes = 4;
  int puntaje = 0;
  int minNumero = 1;
  int maxNumero = 10;
  double _valorActualSlider = 1;
  int puntosAcierto = 1;

//Declaración de funciones

//Niveles de dificultad
  void _configurarDificultad(int valorSlider) {
    switch (valorSlider) {
      case 1:
        nivel = 'facil';
        minNumero = 1;
        maxNumero = 10;
        numeroIntentos = 5;
        puntosAcierto = 1;
        break;
      case 2:
        nivel = 'medio';
        minNumero = 1;
        maxNumero = 20;
        numeroIntentos = 8;
        puntosAcierto = 2;
        break;
      case 3:
        nivel = 'avanzado';
        minNumero = 1;
        maxNumero = 100;
        numeroIntentos = 15;
        puntosAcierto = 4;
        break;
      case 4:
        nivel = 'extremo';
        minNumero = 1;
        maxNumero = 1000;
        numeroIntentos = 25;
        puntosAcierto = 8;
        break;
    }
    _cambiarNivel();
  }

//Cambiar de nivel
  void _cambiarNivel() {
    setState(() {
      intentoClic = 0;
      intentosRestantes = numeroIntentos;
      numerosMenores.clear();
      numerosMayores.clear();
      _generarNumero();
    });
  }

//Generar número aleatorio
  void _generarNumero() {
    setState(() {
      numeroAleatorio =
          (Random().nextInt(maxNumero - minNumero + 1) + minNumero).toString();
      numeroController.clear();
      print('Número aleatorio: $numeroAleatorio');
    });
  }

//Comprobación de número
  void _comprobarNumero() {
    int? numeroIngresado = int.tryParse(numeroController.text);
    if (numeroIngresado == null ||
        numeroIngresado < minNumero ||
        numeroIngresado > maxNumero) {
      _mostrarError('Número inválido',
          'Por favor, ingresa un número entre $minNumero y $maxNumero.');
      return;
    }

    setState(() {
      if (numeroIngresado == int.parse(numeroAleatorio)) {
        mensaje = '¡Felicidades!';
        puntaje += puntosAcierto;
        intentoClic = 0;
        historial.add({'numero': numeroIngresado, 'resultado': 'acertado'});
        _generarNumero();
      } else {
        intentoClic++;
        intentosRestantes = numeroIntentos - intentoClic;

        if (numeroIngresado < int.parse(numeroAleatorio)) {
          numerosMenores.add(numeroIngresado);
          mensaje =
              'El número ingresado es menor. Tienes $intentosRestantes intentos.';
        } else {
          numerosMayores.add(numeroIngresado);
          mensaje =
              'El número ingresado es mayor. Tienes $intentosRestantes intentos.';
        }

        if (intentoClic >= numeroIntentos) {
          mensaje = '¡Perdiste! Tu puntaje fue de $puntaje';
          _muestraDialogo();
        }
        numeroController.clear();
      }
    });
  }

  //Limpiar al perder juego
  void _perderJuego() {
    setState(() {
      intentoClic = 0;
      intentosRestantes = numeroIntentos;
      puntaje = 0;
      numerosMenores.clear();
      numerosMayores.clear();
      historial.clear();
      _generarNumero();
    });
  }

//Mostrar diálogo al perder
  Future<void> _muestraDialogo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Perdiste'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('El número secreto fue $numeroAleatorio.'),
                Text('Tu puntaje fue de $puntaje'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                _perderJuego();
              },
            ),
          ],
        );
      },
    );
  }

  //Mostrar errores
  Future<void> _mostrarError(String titulo, String contenido) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contenido),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _configurarDificultad(_valorActualSlider
        .toInt()); // Inicializa el juego con la dificultad fácil
  }

//Widget Principal
  @override
  Widget build(BuildContext context) {
    String hintText = 'Ingresa un número del $minNumero al $maxNumero';

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Adivina el número'),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(200, 255, 238, 204),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/background/bkg.png',
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      value: _valorActualSlider,
                      min: 1,
                      max: 4,
                      divisions: 3,
                      label: _valorActualSlider.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _valorActualSlider = value;
                          _configurarDificultad(_valorActualSlider.toInt());
                        });
                      },
                    ),
                    Text('Dificultad: $nivel'),
                    const SizedBox(height: 20),
                    TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: hintText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _comprobarNumero,
                      child: const Text('Comprobar número'),
                    ),
                    const SizedBox(height: 30),
                    Text(mensaje),
                    const SizedBox(height: 30),
                    Text('Puntaje: $puntaje'),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                              child: _crearColumna(
                                  'Menor', numerosMenores, Colors.red)),
                          Expanded(
                              child: _crearColumna(
                                  'Mayor', numerosMayores, Colors.blue)),
                          Expanded(
                              child: _crearColumna(
                                  'Historial',
                                  historial
                                      .where(
                                          (h) => h['resultado'] == 'acertado')
                                      .map((h) => h['numero'] as int)
                                      .toList(),
                                  Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

//Widget de columnas
  Widget _crearColumna(String titulo, List<int> numeros, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: numeros.reversed.map((numero) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.all(8),
                  color: color.withOpacity(0.5),
                  child: Text(numero.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
