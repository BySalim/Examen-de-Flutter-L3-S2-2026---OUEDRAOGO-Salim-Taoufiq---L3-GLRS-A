import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:badwallet/app.dart';

void main() {
  testWidgets('Le démarrage affiche le logo BadWallet', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const BadWalletApp());
    expect(find.text('BadWallet'), findsOneWidget);
  });
}
