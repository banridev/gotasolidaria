# GotaSolidária (Flutter v1)

Aplicativo mobile em Flutter para doadores de sangue no Brasil, implementado fielmente ao protótipo `GotaSolidaria.pdf` (11 telas/estados) utilizando **exclusivamente Hive** (`hive` + `hive_flutter`) para persistência local e `share_plus` para compartilhamento de campanhas.

## Estrutura de Pastas

```text
lib/
├── main.dart                         # Inicialização do Hive, AppStateScope e ThemeMode dinâmico
├── theme/
│   └── app_theme.dart                # Tokens de cor (Claro e Escuro) extraídos do protótipo
├── models/
│   ├── donor_profile.dart            # Perfil do doador + TypeAdapter Hive
│   ├── donation_record.dart          # Registro de doação + TypeAdapter Hive
│   ├── blood_center.dart             # Hemocentro local + TypeAdapter Hive
│   └── app_preferences.dart          # Preferências (Modo Escuro, alertas, lembrete) + TypeAdapter
├── services/
│   ├── hive_service.dart             # Persistência 100% Hive + seed inicial do protótipo + reset
│   └── app_state.dart                # Estado reativo, cálculo de aptidão/intervalo e métricas
├── screens/
│   ├── main_shell_screen.dart        # Bottom Navigation Bar (Início, Histórico, Emergência, Perfil)
│   ├── home_screen.dart              # Pág. 1 — Início
│   ├── new_donation_screen.dart      # Págs. 2, 6, 7, 8 e 9 — Nova Doação + modais + teclados
│   ├── history_screen.dart           # Pág. 3 — Histórico de Doações
│   ├── emergency_screen.dart         # Pág. 4 — Emergência (Apoiar & Compartilhar)
│   ├── profile_screen.dart           # Pág. 5 — Meu Perfil
│   └── edit_profile_screen.dart      # Pág. 10 — Editar Perfil
└── widgets/
    ├── custom_date_picker_dialog.dart # Pág. 6 — Seletor de Data
    ├── blood_center_sheet.dart       # Pág. 7 — Selecione o Hemocentro
    ├── custom_keyboards.dart         # Págs. 8 e 9 — Teclado Numérico e Teclado de Texto
    ├── campaign_share_sheet.dart     # Pág. 11 — Modal de Compartilhamento + share_plus
    ├── donor_avatar.dart             # Avatar do doador com seletor de estilo local
    └── gota_icons.dart               # Ícones customizados (sirene, gota, calendário, switch)
```

## Como Executar

```bash
flutter pub get
flutter run
```

Para executar os testes automatizados (widgets + persistência Hive):

```bash
flutter test
```
