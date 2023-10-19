import 'package:calculadora_imc/main.dart';
import 'package:calculadora_imc/utils/calculo_imc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CalculadoraImc(),
  ));
}

class CalculadoraImc extends StatefulWidget {
  const CalculadoraImc({super.key});

  @override
  State<CalculadoraImc> createState() => _CalculadoraImcState();
}

class _CalculadoraImcState extends State<CalculadoraImc> {
  TextEditingController alturaController = TextEditingController();
  TextEditingController pesoController = TextEditingController();
  List<String> userData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de IMC')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: alturaController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(
                    text: newValue.text.replaceAll(',', '.'),
                    selection: newValue.selection,
                  );
                }),
              ],
              decoration: const InputDecoration(labelText: 'Altura'),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso'),
              )),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              String altura = alturaController.text;
              String peso = pesoController.text;

              if (peso.isEmpty || altura.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Erro"),
                      content: const Text(
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                          "Por favor, insira um valor válido para peso e altura."),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text("Fechar"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                double alturaNum = double.parse(altura);
                double pesoNum = double.parse(peso);
                double resultado;
                String? classificacao;
                double resultadoNum;

                resultado = calculo(pesoNum, alturaNum);
                resultadoNum = double.parse(resultado.toStringAsFixed(2));
                debugPrint(resultado.toString());

                if (resultado < 16) {
                  classificacao = "Magreza leve";
                }
                if (resultado >= 16 && resultado < 17) {
                  classificacao = "Magreza moderada";
                }
                if (resultado >= 17 && resultado < 18.5) {
                  classificacao = "Magreza leve";
                }
                if (resultado >= 18.5 && resultado < 25) {
                  classificacao = "Saudável";
                }
                if (resultado >= 25 && resultado < 30) {
                  classificacao = "Sobrepeso";
                }
                if (resultado >= 30 && resultado < 35) {
                  classificacao = "Obesidade grau I";
                }
                if (resultado >= 35 && resultado < 40) {
                  classificacao = "Obesidade grau II (severa)";
                }
                if (resultado >= 40) {
                  classificacao = "obesidade grau III (mórbida)";
                }
                String data =
                    'Altura: $altura metros;\nPeso: $peso kg;\nIMC: $resultadoNum;\nSua classificação é: $classificacao.';

                final userBox = Hive.box<Data>('imcDataBox');
                userBox.add(Data(data));
                setState(() {
                  userData.add(data);
                });
                pesoController.clear();
                alturaController.clear();
              }
            },
            child: const Icon(Icons.add),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Data>('imcDataBox').listenable(),
              builder: (context, box, child) {
                final userData = box.values.toList().cast<Data>();

                return ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(userData[index].data,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 16)),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
