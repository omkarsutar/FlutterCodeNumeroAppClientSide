import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_supabase_order_app_mobile/shared/widgets/shared_widget_barrel.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import '../../cart/providers/cart_providers.dart';
import '../../cart/providers/cart_controller.dart';
import '../providers/numerology_content_providers.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../core/providers/birthdate_localization_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../router/app_routes.dart';
import '../../../../core/providers/app_localization_provider.dart';
import '../../../../core/utils/dialogs.dart';
import '../../../../core/services/analytics_service.dart';
import '../model/numerology_help_content.dart';
import 'widgets/birthdate_share_template.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'utils/analysis_theme.dart';
import 'widgets/mystic_widgets.dart';
import 'sections/narration_guide_section.dart';
import 'sections/age_indicator_section.dart';
import 'sections/numerology_core_details_section.dart';
import 'sections/personality_analysis_section.dart';
import 'sections/loshu_grid_section.dart';
import 'sections/loshu_planes_section.dart';
import 'sections/career_section.dart';
import 'sections/combination_section.dart';
import 'sections/remedy_values_section.dart';
import 'sections/number_occurrence_details_section.dart';
import 'sections/missing_number_tells_section.dart';
import 'sections/missing_number_remedies_section.dart';
import 'sections/important_points_section.dart';
import 'sections/stock_market_info_section.dart';
import 'sections/pinnacle_section.dart';
import 'sections/life_path_section.dart';
import 'sections/boosting_personality_section.dart';
import 'sections/testimonials_section.dart';
import 'sections/user_feedback_section.dart';

class BirthdateAnalysisPage extends ConsumerStatefulWidget {
  const BirthdateAnalysisPage({super.key});

  @override
  ConsumerState<BirthdateAnalysisPage> createState() =>
      _BirthdateAnalysisPageState();
}

class _BirthdateAnalysisPageState extends ConsumerState<BirthdateAnalysisPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _pulseController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshAnalysisData() async {
    // In Riverpod, explicitly triggering dozens of downstream network fetches directly inside
    // a UI refresh loop violates reactive principles.
    // Simply invalidating the primary data source guarantees all downstream providers will fetch when needed!
    ref.invalidate(currentBirthdateRecordProvider);
    ref.invalidate(birthdatesStreamProvider);

    final birthdate = ref.read(birthdateProvider);
    if (birthdate == null) return;

    // ignore: unused_result
    await ref.refresh(birthdatesStreamProvider.future);
  }

  void _navigateToCartAndSelect(DateTime birthdate) async {
    final record = ref.read(currentBirthdateRecordProvider);

    if (record != null && record['id'] != null) {
      final birthdateId = record['id'] as String;

      // Update selected orders provider to include this birthdate
      final currentSelection = ref.read(selectedOrdersProvider);
      final newSelection = Set<String>.from(currentSelection)..add(birthdateId);
      ref.read(selectedOrdersProvider.notifier).state = newSelection;

      // Navigate to cart page (push so back arrow shows on cart)
      if (mounted) {
        context.pushNamed(AppRoute.cartName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final pageTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        onSurfaceVariant: AnalysisTheme.getBodyText(baseTheme),
      ),
    );

    return Theme(
      data: pageTheme,
      child: Builder(
        builder: (context) {
          final l10n = ref.watch(birthdateL10nProvider);
          final birthdate = ref.watch(birthdateProvider);
          final cartStatus = ref.watch(cartStatusProvider);
          final currentLang = ref.watch(languageProvider);
          final hasBeenSaved = cartStatus != null;
          final theme = Theme.of(context);

          return Scaffold(
            key: _scaffoldKey,
            drawer: const CustomDrawer(),
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshAnalysisData,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          stretch: true,
                          expandedHeight: 0,
                          toolbarHeight: 70,
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          elevation: 0,
                          centerTitle: true,
                          leading: IconButton(
                            icon: const Icon(Icons.menu_rounded),
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                          title: Text(
                            l10n['birthdate_analysis'] ?? 'Birthdate Analysis',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          actions: [
                            if (birthdate != null)
                              IconButton(
                                icon: const Icon(Icons.share_rounded),
                                onPressed: _handleShare,
                                tooltip: 'Share Analysis',
                              ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: TextButton(
                                onPressed: () {
                                  ref
                                      .read(languageProvider.notifier)
                                      .toggleLanguage();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AnalysisTheme.getAccent(
                                    theme,
                                  ),
                                  backgroundColor: AnalysisTheme.getAccent(
                                    theme,
                                  ).withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: Text(
                                  currentLang == AppLanguage.english
                                      ? 'EN'
                                      : currentLang == AppLanguage.hindi
                                      ? '\u0939\u093f'
                                      : '\u092e',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(1),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AnalysisTheme.getAccent(
                                theme,
                              ).withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _BirthdateHeaderDelegate(
                            child: _buildBirthdatePickerTile(
                              context,
                              birthdate,
                              l10n,
                              integrated: true,
                            ),
                            backgroundColor: theme.colorScheme.surface,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              AgeIndicatorSection(
                                onEditName: () {
                                  final birthdateRecord = ref.read(
                                    currentBirthdateRecordProvider,
                                  );
                                  final birthdateId =
                                      birthdateRecord?['id'] as String?;
                                  final fullName =
                                      birthdateRecord?['full_name']
                                          as String? ??
                                      'Age Snapshot';
                                  if (birthdateId != null) {
                                    _updateBirthdateName(
                                      birthdateId,
                                      fullName == 'Age Snapshot'
                                          ? ''
                                          : fullName,
                                    );
                                  }
                                },
                              ),
                              NumerologyCoreDetailsSection(
                                onHelp: _showHelpDialog,
                              ),
                              PersonalityAnalysisSection(
                                onHelp: _showHelpDialog,
                              ),
                              LoShuGridSection(onHelp: _showHelpDialog),
                              LoshuPlanesSection(onHelp: _showHelpDialog),
                              RemedyValuesSection(onHelp: _showHelpDialog),
                              MissingNumberTellsSection(
                                onHelp: _showHelpDialog,
                              ),
                              MissingNumberRemediesSection(
                                onHelp: _showHelpDialog,
                              ),
                              NumberOccurrenceDetailsSection(
                                onHelp: _showHelpDialog,
                              ),
                              ImportantPointsSection(onHelp: _showHelpDialog),
                              StockMarketInfoSection(onHelp: _showHelpDialog),
                              PinnacleSection(
                                provider: pinnacleData1Provider,
                                title: "pinnacle_1",
                                onHelp: _showHelpDialog,
                              ),
                              PinnacleSection(
                                provider: pinnacleData2Provider,
                                title: "pinnacle_2",
                                onHelp: _showHelpDialog,
                              ),
                              PinnacleSection(
                                provider: pinnacleData3Provider,
                                title: "pinnacle_3",
                                onHelp: _showHelpDialog,
                              ),
                              PinnacleSection(
                                provider: pinnacleData4Provider,
                                title: "pinnacle_4",
                                onHelp: _showHelpDialog,
                              ),
                              LifePathSection(onHelp: _showHelpDialog),
                              CareerSection(onHelp: _showHelpDialog),
                              BoostingPersonalitySection(
                                onHelp: _showHelpDialog,
                              ),
                              CombinationSection(onHelp: _showHelpDialog),
                              if (birthdate != null) const UserFeedbackSection(),
                              if (hasBeenSaved) ...[
                                const TestimonialsSection(),
                                NarrationGuideSection(
                                  pulseController: _pulseController,
                                ),
                              ],
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionFooter(context, l10n, birthdate, cartStatus),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionFooter(
    BuildContext context,
    Map<String, String> l10n,
    DateTime? birthdate,
    String? cartStatus,
  ) {
    if (cartStatus != null && cartStatus.toLowerCase() != 'pending') {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isPending = cartStatus?.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme
          .colorScheme
          .surface, // Keep background to prevent overlap issues
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: birthdate == null
                ? null
                : () {
                    if (isPending) {
                      ref
                          .read(analyticsServiceProvider)
                          .logClickEvent('read_more_clicked');
                      _navigateToCartAndSelect(birthdate);
                    } else {
                      ref
                          .read(analyticsServiceProvider)
                          .logClickEvent('save_birthdate_clicked');
                      _handleOrderAction(birthdate);
                    }
                  },
            icon: Icon(
              isPending ? Icons.auto_awesome_rounded : Icons.lock_open_rounded,
              size: 20,
            ),
            label: Text(
              isPending
                  ? (l10n['read_more'] ?? 'Unlock Full Analysis')
                  : (l10n['save_birthdate'] ?? 'Reveal My Birthdate Secrets'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending
                  ? theme.colorScheme.secondary
                  : AnalysisTheme.getAccent(theme),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdatePickerTile(
    BuildContext context,
    DateTime? birthdate,
    Map<String, String> l10n, {
    bool integrated = false,
  }) {
    final theme = Theme.of(context);
    final dateDisplay = birthdate != null
        ? DateFormat('dd-MMM-yyyy').format(birthdate)
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: birthdate ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            ref.read(birthdateProvider.notifier).state = picked;
            ref.read(analyticsServiceProvider).logAnalysisView(picked);
          }
        },
        child: MysticSection(
          margin: integrated ? EdgeInsets.zero : const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AnalysisTheme.getAccent(theme).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AnalysisTheme.getAccent(theme),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "${l10n['birthdate_label'] ?? 'Birthdate'} : $dateDisplay",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AnalysisTheme.getAccent(theme),
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                color: AnalysisTheme.getAccent(theme).withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOrderAction(DateTime birthdate) async {
    final l10n = ref.read(birthdateL10nProvider);
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n['cart_saved_login'] ?? 'Please login to continue.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange[700],
          ),
        );
        context.pushNamed(AppRoute.loginName);
      }
      return;
    }

    if (!mounted) return;
    showLoadingDialog(
      context: context,
      message: l10n['please_wait'] ?? 'Placing order...',
    );

    try {
      await ref.read(cartControllerProvider).placeOrder(birthdate: birthdate);

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        await _showThankYouDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n['order_failed_msg'] ?? 'Failed to place order'}: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _updateBirthdateName(String id, String currentName) async {
    final l10n = ref.read(
      appL10nProvider,
    ); // Using global appL10n for general actions
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n['edit_name'] ?? 'Edit Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n['full_name'] ?? 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n['cancel'] ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AnalysisTheme.getAccent(theme),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n['save'] ?? 'Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      if (!mounted) return;
      showLoadingDialog(
        context: context,
        message: l10n['updating'] ?? 'Updating...',
      );

      try {
        await ref.read(cartControllerProvider).updateBirthdateName(id, newName);

        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n['name_updated_success'] ?? 'Name updated successfully!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green[700],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update name: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    }
  }

  Future<void> _showHelpDialog(String conceptKey, AppLanguage lang) {
    final l10n = ref.read(birthdateL10nProvider);
    // Track help interaction
    ref
        .read(analyticsServiceProvider)
        .logClickEvent(
          'help_icon_clicked',
          parameters: {'concept': conceptKey, 'language': lang.name},
        );
    final help = NumerologyHelpRepository.helpData[conceptKey];
    if (help == null) return Future.value();

    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.colorScheme.surface,
        titlePadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AnalysisTheme.getAccent(theme).withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AnalysisTheme.getAccent(theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  help.getTitle(lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AnalysisTheme.getAccent(theme),
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Text(
          help.getContent(lang),
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n['understood'] ?? 'Understood',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AnalysisTheme.getAccent(theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThankYouDialog() {
    final l10n = ref.read(appL10nProvider);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green[700],
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n['analysis_unlocked_title'] ?? 'Analysis Unlocked!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n['analysis_unlocked_msg'] ??
                      'Your birthdate analysis is now saved and unlocked successfully. You can now explore all the hidden secrets of your birthdate!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.goNamed(AppRoute.birthdateAnalysisName);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n['view_analysis'] ?? 'View Analysis',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleShare() async {
    final birthdateData = ref.read(currentBirthdateProvider);
    if (birthdateData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birthdate first')),
      );
      return;
    }

    final l10n = ref.read(birthdateL10nProvider);

    showLoadingDialog(
      context: context,
      message: l10n['share_loading'] ?? 'Generating shareable analysis...',
    );

    try {
      // Capture the template widget
      final image = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1080, 1920),
            devicePixelRatio: 1.0,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              child: BirthdateShareTemplate(
                birthdate: birthdateData,
                l10n: l10n,
              ),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
        targetSize: const Size(1080, 1920),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading

      XFile xFile;
      if (kIsWeb) {
        // On Web, use fromData directly to avoid path_provider dependency
        xFile = XFile.fromData(
          image,
          name: 'birthdate_analysis.png',
          mimeType: 'image/png',
        );
      } else {
        // On Mobile/Desktop, save to temporary file
        final directory = await getTemporaryDirectory();
        final imagePath =
            '${directory.path}/birthdate_analysis_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);
        xFile = XFile(imagePath);
      }

      // Share text
      final psychic = birthdateData.personalityNumber ?? "?";
      final destiny = birthdateData.lifePathNumber ?? "?";
      
      final psychicLabel = l10n['personality_number_label'] ?? 'Psychic Number';
      final destinyLabel = l10n['life_path_number_label'] ?? 'Destiny Number';
      final sharePrefix = l10n['share_prefix'] ?? '✨ Check out my Mystical Analysis! ✨';
      final sharePromo = l10n['share_promo'] ?? 'Get your own numerology analysis and unlock the secrets of your life path with Numero Shastra! 🔮';
      final shareDownload = l10n['share_download'] ?? 'Download now on Play Store';

      final shareText =
          "$sharePrefix\n\n"
          "$psychicLabel: $psychic\n"
          "$destinyLabel: $destiny\n\n"
          "$sharePromo\n\n"
          "$shareDownload: https://play.google.com/store/apps/details?id=com.numero.shastra";

      // Share the file
      await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: l10n['share_subject'] ?? 'My Numero Shastra Analysis',
      );

      ref.read(analyticsServiceProvider).logClickEvent('share_analysis_clicked');
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n['share_error_msg'] ?? 'Failed to share'}: $e')),
        );
      }
    }
  }
}

class _BirthdateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _BirthdateHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 76;

  @override
  double get maxExtent => 76;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _BirthdateHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
