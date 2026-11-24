import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Literal Page 8 Numeric Keyboard for Volume input (`0–9`, backspace, `Concluir`).
class NumericDonationKeyboard extends StatelessWidget {
  const NumericDonationKeyboard({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onDone,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;

    return Container(
      color: colors.keyboardBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toolbar row (`Numérico` chip + `Concluir`)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 6, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_outlined,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Numérico',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onDone,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'Concluir',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildRow(['1', '2', '3'], colors),
              const SizedBox(height: 8),
              _buildRow(['4', '5', '6'], colors),
              const SizedBox(height: 8),
              _buildRow(['7', '8', '9'], colors),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _KeyButton(
                      height: 54,
                      backgroundColor: colors.keyboardSpecialKey,
                      onTap: onBackspace,
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 22,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KeyButton(
                      height: 54,
                      backgroundColor: colors.keyboardKey,
                      onTap: () => onDigit('0'),
                      child: Text(
                        '0',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KeyButton(
                      height: 54,
                      backgroundColor: colors.primary,
                      onTap: onDone,
                      child: const Text(
                        'Concluir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits, GotaColors colors) {
    return Row(
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _KeyButton(
              height: 54,
              backgroundColor: colors.keyboardKey,
              onTap: () => onDigit(digits[i]),
              child: Text(
                digits[i],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Literal Page 9 Text QWERTY Keyboard for Observações input.
class TextDonationKeyboard extends StatefulWidget {
  const TextDonationKeyboard({
    super.key,
    required this.onText,
    required this.onBackspace,
    required this.onDone,
  });

  final ValueChanged<String> onText;
  final VoidCallback onBackspace;
  final VoidCallback onDone;

  @override
  State<TextDonationKeyboard> createState() => _TextDonationKeyboardState();
}

class _TextDonationKeyboardState extends State<TextDonationKeyboard> {
  bool _uppercase = true;
  bool _numericMode = false;
  bool _emojiMode = false;

  static const List<String> _row1Alpha = [
    'Q',
    'W',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
  ];
  static const List<String> _row2Alpha = [
    'A',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
  ];
  static const List<String> _row3Alpha = [
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
  ];

  static const List<String> _row1Num = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ];
  static const List<String> _row2Num = [
    '-',
    '/',
    ':',
    ';',
    '(',
    ')',
    ',',
    '.',
    '?',
  ];
  static const List<String> _row3Num = [
    '!',
    '"',
    "'",
    '%',
    '+',
    '=',
    '°',
  ];

  static const List<String> _quickEmojis = [
    '😊',
    '❤️',
    '🩸',
    '👍',
    '💪',
    '🙏',
    '😌',
    '✨',
  ];

  void _handleKey(String raw) {
    if (_numericMode) {
      widget.onText(raw);
      return;
    }
    final char = _uppercase ? raw.toUpperCase() : raw.toLowerCase();
    widget.onText(char);
    if (_uppercase) {
      setState(() => _uppercase = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gotaColors;
    final row1 = _numericMode ? _row1Num : _row1Alpha;
    final row2 = _numericMode ? _row2Num : _row2Alpha;
    final row3 = _numericMode ? _row3Num : _row3Alpha;

    return Container(
      color: colors.keyboardBg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toolbar row (keyboard icon + `Concluir`)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 8, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.onDone,
                      child: Icon(
                        Icons.keyboard_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDone,
                      child: Text(
                        'Concluir',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_emojiMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: _quickEmojis
                        .map(
                          (emoji) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: _KeyButton(
                                height: 42,
                                backgroundColor: colors.keyboardKey,
                                onTap: () => widget.onText(emoji),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              // Row 1: Q W E R T Y U I O P
              Row(
                children: [
                  for (int i = 0; i < row1.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: _KeyButton(
                        height: 44,
                        backgroundColor: colors.keyboardKey,
                        onTap: () => _handleKey(row1[i]),
                        child: Text(
                          _numericMode
                              ? row1[i]
                              : (_uppercase
                                  ? row1[i]
                                  : row1[i].toLowerCase()),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              // Row 2: A S D F G H J K L
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (int i = 0; i < row2.length; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: _KeyButton(
                          height: 44,
                          backgroundColor: colors.keyboardKey,
                          onTap: () => _handleKey(row2[i]),
                          child: Text(
                            _numericMode
                                ? row2[i]
                                : (_uppercase
                                    ? row2[i]
                                    : row2[i].toLowerCase()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Row 3: Shift + Z..M + Backspace
              Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: _uppercase && !_numericMode
                          ? colors.surface
                          : colors.keyboardSpecialKey,
                      onTap: () => setState(() => _uppercase = !_uppercase),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  for (int i = 0; i < row3.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: _KeyButton(
                        height: 44,
                        backgroundColor: colors.keyboardKey,
                        onTap: () => _handleKey(row3[i]),
                        child: Text(
                          _numericMode
                              ? row3[i]
                              : (_uppercase
                                  ? row3[i]
                                  : row3[i].toLowerCase()),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: colors.keyboardSpecialKey,
                      onTap: widget.onBackspace,
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Row 4: 123 | emoji | espaço | return
              Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: colors.keyboardSpecialKey,
                      onTap: () => setState(() {
                        _numericMode = !_numericMode;
                        _emojiMode = false;
                      }),
                      child: Text(
                        _numericMode ? 'ABC' : '123',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 42,
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: _emojiMode
                          ? colors.surface
                          : colors.keyboardSpecialKey,
                      onTap: () => setState(() => _emojiMode = !_emojiMode),
                      child: const Text(
                        '😊',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: colors.keyboardKey,
                      onTap: () => widget.onText(' '),
                      child: Text(
                        'espaço',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 78,
                    child: _KeyButton(
                      height: 44,
                      backgroundColor: colors.primary,
                      onTap: widget.onDone,
                      child: const Text(
                        'return',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.height,
    required this.backgroundColor,
    required this.onTap,
    required this.child,
  });

  final double height;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 0.8,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
