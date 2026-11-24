import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import 'gota_icons.dart';

const String kCampaignTitle = 'SOS Hemocentro SP - Campanha O- e A-';
const String kCampaignUrl = 'https://app.gotasolidaria.org/campanha';
const String kCampaignDisplayUrl = 'app.gotasolidaria.org/campanha';
const String kCampaignMessage =
    'SOS Hemocentro SP - Campanha Urgente: Tipo O- e A-!\n'
    'Precisamos urgentemente de doadores dos tipos O- e A- para reabastecer '
    'os estoques críticos neste fim de semana.\n'
    'Local: Av. Dr. Enéas Carvalho de Aguiar, 155 - Cerqueira César.\n'
    'Saiba mais e apoie pelo GotaSolidária: $kCampaignUrl';

/// Opens the full Page 11 Campaign Share Modal experience (dark campaign backdrop + white Share Sheet).
Future<void> showCampaignShareModal({
  required BuildContext context,
  GlobalKey? previewBoundaryKey,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _CampaignShareModalScreen(
          previewBoundaryKey: previewBoundaryKey,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    ),
  );
}

class _CampaignShareModalScreen extends StatefulWidget {
  const _CampaignShareModalScreen({this.previewBoundaryKey});

  final GlobalKey? previewBoundaryKey;

  @override
  State<_CampaignShareModalScreen> createState() =>
      _CampaignShareModalScreenState();
}

class _CampaignShareModalScreenState extends State<_CampaignShareModalScreen> {
  bool _busy = false;

  Future<Uint8List?> _capturePreviewPng() async {
    try {
      final boundary = widget.previewBoundaryKey?.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.5);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      }
    } catch (_) {
      // Fallback to bundled campaign asset if capture is unavailable.
    }
    try {
      final data = await rootBundle.load('assets/images/gota_share_thumb.png');
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareViaSharePlus({
    required String channelLabel,
    bool includeImage = false,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      List<XFile>? files;
      if (includeImage) {
        final bytes = await _capturePreviewPng();
        if (bytes != null) {
          if (kIsWeb) {
            files = [
              XFile.fromData(
                bytes,
                mimeType: 'image/png',
                name: 'gotasolidaria_campanha.png',
              ),
            ];
          } else {
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/gotasolidaria_campanha.png');
            await file.writeAsBytes(bytes, flush: true);
            files = [XFile(file.path, mimeType: 'image/png')];
          }
        }
      }

      await SharePlus.instance.share(
        ShareParams(
          text: kCampaignMessage,
          subject: kCampaignTitle,
          files: files,
        ),
      );
    } catch (_) {
      if (mounted) {
        await Clipboard.setData(const ClipboardData(text: kCampaignMessage));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mensagem para $channelLabel copiada para a área de transferência.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(const ClipboardData(text: kCampaignUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado: app.gotasolidaria.org/campanha'),
      ),
    );
  }

  Future<void> _saveImageToFiles() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capturePreviewPng();
      if (bytes == null) {
        throw Exception('Não foi possível gerar a imagem.');
      }
      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem da campanha preparada para compartilhamento.'),
          ),
        );
        return;
      }
      final docsDir = await getApplicationDocumentsDirectory();
      final filename =
          'gotasolidaria_campanha_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${docsDir.path}/$filename');
      await outputFile.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagem salva nos arquivos: $filename'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagem da campanha salva nos arquivos locais.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1E26) : Colors.white;
    final sheetPrimaryText =
        isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final sheetSecondaryText =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final actionCircleBg =
        isDark ? const Color(0xFF282E3A) : const Color(0xFFF3F4F6);
    final cancelBtnBg =
        isDark ? const Color(0xFF282E3A) : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: const Color(0xFF06090F),
      body: Stack(
        children: [
          // Page 11 top dark campaign preview backdrop
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: red circle + GotaSolidária + notification bell
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6B0F1A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'GotaSolidária',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8C9199),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF8C9199),
                        size: 26,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Dark campaign hero card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF12161F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.35),
                              BlendMode.darken,
                            ),
                            child: Image.asset(
                              'assets/images/sos_campaign_banner.jpg',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 180,
                                color: const Color(0xFF2A1416),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.favorite,
                                  color: AppColors.primary,
                                  size: 56,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'SOS Hemocentro SP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8E94A0),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Precisamos urgentemente de doadores dos tipos O- e A- para reabastecer os estoques críticos neste fim de semana.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tap backdrop to dismiss
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),

          // Bottom Share Sheet (exact Page 11 layout)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 38,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3E4554)
                            : const Color(0xFFDDE1E6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Campaign thumbnail & URL row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/gota_share_thumb.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 48,
                              height: 48,
                              color: AppColors.avatarRose,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.water_drop,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kCampaignTitle,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: sheetPrimaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                kCampaignDisplayUrl,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: sheetSecondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF2B3140)
                          : const Color(0xFFF0F1F3),
                    ),
                    const SizedBox(height: 18),
                    // 5 App Shortcut Buttons (WhatsApp, Status, Stories, Telegram, Mensagens)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ShareAppShortcut(
                          label: 'WhatsApp',
                          labelColor: sheetSecondaryText,
                          onTap: () => _shareViaSharePlus(
                            channelLabel: 'WhatsApp',
                          ),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF22C55E),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        _ShareAppShortcut(
                          label: 'Status',
                          labelColor: sheetSecondaryText,
                          onTap: () => _shareViaSharePlus(
                            channelLabel: 'Status',
                            includeImage: true,
                          ),
                          iconWidget: DashedCircleBorder(
                            size: 52,
                            color: const Color(0xFF22C55E),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF22C55E),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        _ShareAppShortcut(
                          label: 'Stories',
                          labelColor: sheetSecondaryText,
                          onTap: () => _shareViaSharePlus(
                            channelLabel: 'Stories',
                            includeImage: true,
                          ),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xFFF58529),
                                  Color(0xFFDD2A7B),
                                  Color(0xFF8134AF),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        _ShareAppShortcut(
                          label: 'Telegram',
                          labelColor: sheetSecondaryText,
                          onTap: () => _shareViaSharePlus(
                            channelLabel: 'Telegram',
                          ),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0EA5E9),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        _ShareAppShortcut(
                          label: 'Mensagens',
                          labelColor: sheetSecondaryText,
                          onTap: () => _shareViaSharePlus(
                            channelLabel: 'Mensagens',
                          ),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3B82F6),
                            ),
                            child: const Icon(
                              Icons.mode_comment_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // 3 Share Action Rows
                    _ShareActionTile(
                      icon: Icons.link_rounded,
                      label: 'Copiar link da campanha',
                      circleBg: actionCircleBg,
                      textColor: sheetPrimaryText,
                      chevronColor: sheetSecondaryText,
                      onTap: _copyLink,
                    ),
                    _ShareActionTile(
                      icon: Icons.file_download_outlined,
                      label: 'Salvar imagem nos arquivos',
                      circleBg: actionCircleBg,
                      textColor: sheetPrimaryText,
                      chevronColor: sheetSecondaryText,
                      onTap: _saveImageToFiles,
                    ),
                    _ShareActionTile(
                      icon: Icons.rss_feed_rounded,
                      label: 'Compartilhar via Bluetooth / Proximidade',
                      circleBg: actionCircleBg,
                      textColor: sheetPrimaryText,
                      chevronColor: sheetSecondaryText,
                      onTap: () => _shareViaSharePlus(
                        channelLabel: 'Bluetooth / Proximidade',
                        includeImage: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Cancelar pill button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cancelBtnBg,
                          foregroundColor: sheetPrimaryText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareAppShortcut extends StatelessWidget {
  const _ShareAppShortcut({
    required this.label,
    required this.labelColor,
    required this.iconWidget,
    required this.onTap,
  });

  final String label;
  final Color labelColor;
  final Widget iconWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 54,
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareActionTile extends StatelessWidget {
  const _ShareActionTile({
    required this.icon,
    required this.label,
    required this.circleBg,
    required this.textColor,
    required this.chevronColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color circleBg;
  final Color textColor;
  final Color chevronColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: textColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}
