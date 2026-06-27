/*
  Esto es un test básico de Flutter.
  Para realizar una interacción con un widget en tu test, utiliza la utilidad WidgetTester
  en el paquete flutter_test. Por ejemplo, puedes enviar gestos de tap y scroll.
  Un widget es un elemento de la interfaz de usuario que forma parte de tu aplicación, 
  como un botón, un texto o una imagen.
  La utilidad WidgetTester te permite simular interacciones con estos widgets, 
  como hacer clic en un botón o desplazarte por una lista.
  El paquete flutter_test proporciona una variedad de métodos para encontrar widgets en el 
  árbol de widgets, como find.text, find.byType, find.byKey, entre otros.
  También puedes usar WidgetTester para encontrar widgets hijos en el árbol de widgets,
  leer texto y verificar que los valores de las propiedades de los widgets sean correctos.
  El árbol de widgets es la estructura jerárquica que representa la interfaz de usuario 
  de la aplicación.
  Cada widget puede tener widgets hijos, y estos a su vez pueden tener sus propios hijos, 
  formando así un árbol.
  Para más información, consulta la documentación oficial de Flutter sobre testing:
  https://flutter.dev/docs/testing
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
