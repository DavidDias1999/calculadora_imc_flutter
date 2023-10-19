import 'package:calculadora_imc/pages/my_app.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'main.g.dart';

@HiveType(typeId: 0)
class Data {
  @HiveField(0)
  final String data;

  Data(this.data);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(
      UserDataAdapter()); // Use UserDataAdapter, não UserData()
  await Hive.openBox<Data>('imcDataBox');

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}
