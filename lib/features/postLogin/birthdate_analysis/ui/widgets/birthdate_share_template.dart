import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/birthdate_model.dart';

class BirthdateShareTemplate extends StatelessWidget {
  final ModelBirthdate birthdate;
  final Map<String, String> l10n;

  const BirthdateShareTemplate({
    super.key,
    required this.birthdate,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF4C542);
    final secondaryColor = const Color(0xFF66D1C1);
    final cardColor = const Color(0xFF16263E);
    final title = l10n['share_subject'] ?? 'My Numero Shastra Analysis';

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B1422),
            const Color(0xFF13243A),
            const Color(0xFF0C1727),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _buildDecorativeCircle(360, accentColor.withValues(alpha: 0.09)),
          ),
          Positioned(
            bottom: -70,
            left: -70,
            child: _buildDecorativeCircle(320, secondaryColor.withValues(alpha: 0.08)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 78),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  "NUMERO SHASTRA",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 54),

                Container(
                  padding: const EdgeInsets.all(34),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        birthdate.fullName ?? "Soul Searcher",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DateFormat('dd MMMM yyyy').format(birthdate.birthdate),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                Row(
                  children: [
                    Expanded(
                      child: _buildNumberCard(
                        "Psychic Number",
                        birthdate.personalityNumber?.toString() ?? "?",
                        accentColor,
                        cardColor,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildNumberCard(
                        "Destiny Number",
                        birthdate.lifePathNumber?.toString() ?? "?",
                        secondaryColor,
                        cardColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                Text(
                  "LO SHU GRID",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 22),

                _buildLoshuGrid(birthdate.loShuGrid, cardColor, accentColor),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, const Color(0xFFE2B53C)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2B1A00), size: 34),
                      const SizedBox(width: 14),
                      const Text(
                        "Unlock Full Analysis",
                        style: TextStyle(
                          color: Color(0xFF2B1A00),
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: Text(
                    "Get your complete numerology report on Numero Shastra.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildNumberCard(
    String title,
    String value,
    Color accent,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 88,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoshuGrid(List<dynamic>? grid, Color cardColor, Color accent) {
    if (grid == null || grid.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 640,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: List.generate(3, (rowIndex) {
          return Row(
            children: List.generate(3, (colIndex) {
              final index = rowIndex * 3 + colIndex;
              final cell = index < grid.length ? grid[index] : null;
              final hasNumber = cell != null && cell.toString().isNotEmpty;

              return Expanded(
                child: Container(
                  height: 170,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasNumber
                        ? accent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: hasNumber
                          ? accent.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1.4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasNumber ? cell.toString() : "•",
                      style: TextStyle(
                        color: hasNumber ? Colors.white : Colors.white24,
                        fontSize: hasNumber ? 44 : 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
