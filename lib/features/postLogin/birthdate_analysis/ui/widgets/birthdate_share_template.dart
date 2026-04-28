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
    final accentColor = const Color(0xFF6C63FF); // Modern Purple
    final secondaryColor = const Color(0xFFFF6B6B); // Soft Red

    return Container(
      width: 1080, // High resolution for sharing
      height: 1920, // Story format
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: _buildDecorativeCircle(400, accentColor.withValues(alpha: 0.1)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildDecorativeCircle(300, secondaryColor.withValues(alpha: 0.1)),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                const SizedBox(height: 40),
                Text(
                  "NUMERO SHASTRA",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "MYSTICAL ANALYSIS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 80),

                // Name & Date
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        birthdate.fullName ?? "Soul Searcher",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        DateFormat('dd MMMM yyyy').format(birthdate.birthdate),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // Core Numbers
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberCard(
                        "Psychic Number",
                        birthdate.personalityNumber?.toString() ?? "?",
                        accentColor,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildNumberCard(
                        "Destiny Number",
                        birthdate.lifePathNumber?.toString() ?? "?",
                        secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),

                // Loshu Grid Title
                Text(
                  "LO SHU GRID",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),

                // Loshu Grid
                _buildLoshuGrid(birthdate.loShuGrid),
                
                const Spacer(),

                // Call to Action
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download_rounded, color: Colors.white, size: 40),
                      const SizedBox(width: 20),
                      const Flexible(
                        child: Text(
                          "Download Numero Shastra",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Get your detailed analysis today!",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 28,
                  ),
                ),
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

  Widget _buildNumberCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 96,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoshuGrid(List<dynamic>? grid) {
    if (grid == null || grid.isEmpty) return const SizedBox.shrink();

    // Custom Grid using Column/Row to avoid GridView's View.of() dependencies
    return Container(
      width: 600,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  height: 180,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: hasNumber
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasNumber
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasNumber ? cell.toString() : "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
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
