import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/plan_provider.dart';
import '../../models/plan_template.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_card.dart';
import 'plan_customization_screen.dart';
import 'create_custom_plan_screen.dart';

class PlanTemplatesScreen extends StatefulWidget {
  const PlanTemplatesScreen({super.key});

  @override
  State<PlanTemplatesScreen> createState() => _PlanTemplatesScreenState();
}

class _PlanTemplatesScreenState extends State<PlanTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Study Plan Templates'),
            Text(
              'Choose a template or create custom',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create Custom Plan',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateCustomPlanScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, planProvider, _) {
          if (planProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final templates = planProvider.templates;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Create Custom Plan Card
              GradientCard(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.15),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.create, color: AppTheme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Custom Plan',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Build your own schedule from scratch',
                                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateCustomPlanScreen()),
                          );
                        },
                        child: const Text('Create Custom'),
                      ),
                    ),
                  ],
                ),
              ),
              // Templates
              if (templates.isEmpty)
                const Center(child: Text('No templates available'))
              else
                ...templates.map((template) => _TemplateCard(template: template)),
            ],
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final PlanTemplate template;

  const _TemplateCard({required this.template});

  Color _getTypeColor() {
    switch (template.type) {
      case 'CAT':
        return const Color(0xFFEF4444);
      case 'GMAT':
        return const Color(0xFF8B5CF6);
      case 'UPSC':
        return const Color(0xFF10B981);
      case 'JEE':
        return const Color(0xFF3B82F6);
      case 'NEET':
        return const Color(0xFFF59E0B);
      case 'SSC':
        return const Color(0xFF06B6D4);
      case 'DSA':
        return const Color(0xFFEC4899);
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return GradientCard(
      colors: [
        typeColor.withOpacity(0.1),
        typeColor.withOpacity(0.05),
      ],
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  template.type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  template.difficulty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            template.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            template.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: typeColor),
              const SizedBox(width: 6),
              Text(
                '${template.duration.weeks} weeks',
                style: TextStyle(
                  fontSize: 13,
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.book_outlined, size: 16, color: typeColor),
              const SizedBox(width: 6),
              Text(
                '${template.subjects.length} subjects',
                style: TextStyle(
                  fontSize: 13,
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (template.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.features.take(3).map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlanCustomizationScreen(template: template),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Select Template'),
            ),
          ),
        ],
      ),
    );
  }
}
