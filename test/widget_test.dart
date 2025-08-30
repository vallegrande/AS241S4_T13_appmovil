import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodTrackApp());

    // Aquí puedes poner tests específicos de tu LoginPage
    // Por ejemplo, verificar que aparezca el texto del botón de login
    expect(find.text('Iniciar sesión'), findsOneWidget);

    // Si quieres simular un tap, asegúrate de usar el texto o el icon correcto
    // await tester.tap(find.byType(ElevatedButton));
    // await tester.pump();
  });
}
