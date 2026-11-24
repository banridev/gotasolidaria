import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gota_solidaria/main.dart';
import 'package:gota_solidaria/services/app_state.dart';
import 'package:gota_solidaria/services/hive_service.dart';
import 'package:gota_solidaria/widgets/gota_icons.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late Directory tempDir;
  int testCounter = 0;
  late HiveService hiveService;
  late AppState appState;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gota_solidaria_test_');
  });

  setUp(() async {
    testCounter++;
    hiveService = HiveService();
    await hiveService.init(
      customPath: tempDir.path,
      boxPrefix: 't${testCounter}_',
    );
    appState = AppState(hiveService);
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<void> flushHiveAndSettle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Page 1 (Início) renders all seeded prototype elements',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(GotaSolidariaApp(appState: appState));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Doador'), findsOneWidget);
    expect(find.text('Tipo: O+'), findsWidgets);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('dias'), findsOneWidget);
    expect(find.text('Você está apto para doar!'), findsOneWidget);
    expect(find.text('Seu gesto pode salvar\naté 4 vidas.'), findsOneWidget);
    expect(
      find.text('Você já cumpriu o intervalo\nrecomendado.'),
      findsOneWidget,
    );
    expect(find.text('ÚLTIMA DOAÇÃO'), findsOneWidget);
    expect(find.text('12/05/2026 no Hemocentro SP'), findsOneWidget);
    expect(find.text('Registrar Nova Doação'), findsOneWidget);
    expect(find.text('Estoque em nível crítico'), findsOneWidget);
    expect(find.text('O- e A- precisam de doações urgentes.'), findsOneWidget);
    expect(
      find.text('Hidrate-se bem e leve um documento com foto.'),
      findsOneWidget,
    );
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Emergência'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets(
      'Pages 2, 6, 7, 8, 9 (Nova Doação + DatePicker + BloodCenter + Numeric & Text Keyboards) persist to Hive',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(GotaSolidariaApp(appState: appState));
    await tester.pumpAndSettle();

    // Open Nova Doação
    await tester.tap(find.text('Registrar Nova Doação'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Doação'), findsOneWidget);
    expect(find.text('Conte como foi sua doação'), findsOneWidget);
    expect(find.text('28/09/2026'), findsOneWidget);
    expect(find.text('Fundação Pró-Sangue - Clínicas'), findsWidgets);
    expect(find.text('VOLUME PADRÃO'), findsOneWidget);

    // Page 6: Open Custom Date Picker
    await tester.tap(find.text('28/09/2026'));
    await tester.pumpAndSettle();
    expect(find.text('Selecionar Data'), findsOneWidget);
    expect(find.text('Segunda-feira, 28 de set.'), findsOneWidget);
    expect(find.text('Setembro 2026'), findsOneWidget);
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('15/09/2026'), findsOneWidget);

    // Page 7: Open Blood Center Selector Sheet
    await tester.tap(find.text('Fundação Pró-Sangue - Clínicas').first);
    await tester.pumpAndSettle();
    expect(find.text('Selecione o Hemocentro'), findsOneWidget);
    expect(find.text('Banco de Sangue Paulista'), findsOneWidget);
    expect(find.text('Hemocentro Hospital São Paulo'), findsOneWidget);
    expect(find.text('Posto Barueri - Pró-Sangue'), findsOneWidget);

    await tester.tap(find.text('Banco de Sangue Paulista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar Local'));
    await tester.pumpAndSettle();
    expect(find.text('Banco de Sangue Paulista'), findsOneWidget);

    // Select Plaquetas
    await tester.tap(find.text('Plaquetas'));
    await tester.pumpAndSettle();

    // Page 8: Open Numeric Keyboard and edit Volume
    await tester.tap(find.text('450'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Numérico'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('5').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Concluir').last);
    await tester.pumpAndSettle();
    expect(find.text('455'), findsOneWidget);

    // Page 9: Open Text Keyboard and type note
    await tester.tap(find.text('Ex.: tontura leve, hematoma ou tudo bem...'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('espaço'), findsOneWidget);
    expect(find.text('return'), findsOneWidget);
    await tester.tap(find.text('O'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('k'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('return'));
    await tester.pumpAndSettle();
    expect(find.text('Ok'), findsOneWidget);

    // Save record to Hive
    await tester.tap(find.text('Salvar Registro'));
    await flushHiveAndSettle(tester);

    // Verify Hive updated Home screen and History count
    expect(appState.totalDonations, 6);
    expect(find.text('15/09/2026 no Banco de Sangue Paulista'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Page 3 (Histórico), Page 4 & 11 (Emergência + Share Modal), Page 5 & 10 (Perfil + Editar Perfil + Modo Escuro)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(GotaSolidariaApp(appState: appState));
    await tester.pumpAndSettle();

    // Tab 1: Histórico (Page 3)
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de Doações'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('até 20 vidas'), findsOneWidget);
    expect(find.text('2 registros'), findsOneWidget);
    expect(find.text('Hemocentro São Paulo'), findsOneWidget);
    expect(find.text('Hospital das Clínicas'), findsOneWidget);
    expect(
      find.text('Você já completou 5 doações. Que impacto lindo!'),
      findsOneWidget,
    );
    expect(find.text('Adicionar anterior'), findsOneWidget);

    // Filter 2025
    await tester.tap(find.text('2025').first);
    await tester.pumpAndSettle();
    expect(find.text('3 registros'), findsOneWidget);

    // Tab 2: Emergência (Page 4)
    await tester.tap(find.text('Emergência'));
    await tester.pumpAndSettle();
    expect(find.text('Apoiar & Compartilhar'), findsOneWidget);
    expect(find.text('SOS Hemocentro SP'), findsOneWidget);
    expect(find.text('URGENTE'), findsOneWidget);
    expect(find.text('Campanha Urgente: Tipo O- e A-'), findsOneWidget);
    expect(find.text('Compartilhar no WhatsApp'), findsOneWidget);

    // Open Page 11 Campaign Share Modal
    await tester.tap(find.text('Compartilhar no WhatsApp'));
    await tester.pumpAndSettle();
    expect(find.text('SOS Hemocentro SP - Campanha O- e A-'), findsOneWidget);
    expect(find.text('app.gotasolidaria.org/campanha'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('Mensagens'), findsOneWidget);
    expect(find.text('Copiar link da campanha'), findsOneWidget);
    expect(find.text('Salvar imagem nos arquivos'), findsOneWidget);
    expect(
      find.text('Compartilhar via Bluetooth / Proximidade'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Tab 3: Perfil (Page 5)
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(find.text('Carlos Silva'), findsOneWidget);
    expect(find.text('Doador desde 2024'), findsOneWidget);
    expect(find.text('Doador Prata • 5 doações'), findsOneWidget);
    expect(find.text('Homem (60 dias)'), findsOneWidget);
    expect(find.text('72 kg (Apto > 50kg)'), findsOneWidget);

    // Toggle Dark Mode via the first GotaSwitch -> saved in Hive
    await tester.tap(find.byType(GotaSwitch).first);
    await flushHiveAndSettle(tester);
    expect(appState.themeMode, ThemeMode.dark);
    expect(hiveService.getPreferences().darkMode, isTrue);

    // Open Editar Perfil (Page 10)
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Editar Perfil'), findsOneWidget);
    expect(find.text('Trocar foto'), findsOneWidget);
    expect(find.text('Informações Pessoais'), findsOneWidget);
    expect(find.text('Dados de Aptidão'), findsOneWidget);
    expect(find.text('Ações da Conta'), findsOneWidget);

    // Change blood type to A- and Biological Sex to Feminino
    await tester.tap(find.text('A-'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feminino (90 dias / máx 3x ano)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar Alterações'));
    await flushHiveAndSettle(tester);

    // Verify Hive updated Profile & Home badge
    expect(appState.profile.bloodType, 'A-');
    expect(appState.profile.biologicalSex, 'Feminino');
    expect(find.text('Tipo: A-'), findsWidgets);
    expect(find.text('Mulher (90 dias)'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
  });

  test('HiveService supports clearing user data and restoring prototype defaults',
      () async {
    await appState.clearAllUserData();
    expect(appState.totalDonations, 0);
    expect(appState.profile.fullName, 'Novo Doador');
    expect(appState.bloodCenters.length, 4);

    await appState.resetToPrototypeDefaults();
    expect(appState.totalDonations, 5);
    expect(appState.livesImpacted, 20);
    expect(appState.profile.fullName, 'Carlos Silva');
    expect(appState.profile.bloodType, 'O+');
    expect(appState.latestDonation?.formattedDate, '12/05/2026');
    expect(appState.latestDonation?.displayShortName, 'Hemocentro SP');
  });
}
