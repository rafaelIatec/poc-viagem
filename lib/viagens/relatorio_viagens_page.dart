import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adicionar_viagem_page.dart';

class RelatorioViagensPage extends StatelessWidget {
  const RelatorioViagensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _RelatorioHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
              delegate: SliverChildListDelegate([
                _QuickActionCard(
                  backgroundColor: Colors.deepPurple.shade50,
                  title: 'Vai viajar?',
                  illustration: const _FlatIllustration(mainIcon: Icons.airplane_ticket_outlined, accentIcon: Icons.airplanemode_active),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdicionarViagemPage())),
                ),
                _QuickActionCard(
                  backgroundColor: Colors.green.shade50,
                  title: 'Gastou?',
                  illustration: const _FlatIllustration(mainIcon: Icons.account_balance_wallet_outlined, accentIcon: Icons.warning_amber_rounded),
                  onTap: () => _toast(context, 'Gastou?'),
                ),
                _QuickActionCard(
                  backgroundColor: Colors.lightBlue.shade50,
                  title: 'Diárias',
                  illustration: const _FlatIllustration(mainIcon: Icons.calendar_month_outlined, accentIcon: Icons.event_available),
                  onTap: () => _toast(context, 'Diárias'),
                ),
                _QuickActionCard(
                  backgroundColor: Colors.pink.shade50,
                  title: 'Mudou a direção?',
                  illustration: const _FlatIllustration(mainIcon: Icons.alt_route, accentIcon: Icons.question_mark),
                  onTap: () => _toast(context, 'Mudou a direção?'),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            sliver: SliverToBoxAdapter(
              child: _LargeActionCard(
                backgroundColor: Colors.amber.shade50,
                title: 'Acompanhar minhas viagens',
                titleColor: Colors.amber.shade800,
                illustration: const _FlatIllustration(mainIcon: Icons.luggage_outlined, accentIcon: Icons.flight, big: true),
                onTap: () => _toast(context, 'Acompanhar minhas viagens'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text('Próxima viagem', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverToBoxAdapter(
              child: _NextTripCard(date: '18 Dez', origin: 'São Paulo', destination: 'Rio de Janeiro'),
            ),
          ),
        ],
      ),
    );
  }

  static void _toast(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('Abrir: $label (em breve)')));
  }
}

class _RelatorioHeader extends StatelessWidget {
  const _RelatorioHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        height: 180,
        decoration: BoxDecoration(color: Color(0xFF1976D2)),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: Colors.white,
                    onPressed: () async {
                      final popped = await Navigator.maybePop(context);
                      if (!popped && context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(const SnackBar(content: Text('Nenhuma tela anterior para voltar.')));
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) {
                        nav.pop();
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(const SnackBar(content: Text('Nada para fechar.')));
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Relatório de viagens',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Acompanhe de perto ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              TextSpan(
                                text: 'Suas viagens…',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.tertiary, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.backgroundColor, required this.title, required this.illustration, required this.onTap});

  final Color backgroundColor;
  final String title;
  final Widget illustration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: illustration),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeActionCard extends StatelessWidget {
  const _LargeActionCard({required this.backgroundColor, required this.title, required this.titleColor, required this.illustration, required this.onTap});

  final Color backgroundColor;
  final String title;
  final Color titleColor;
  final Widget illustration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: titleColor),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(width: 110, height: 72, child: illustration),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlatIllustration extends StatelessWidget {
  const _FlatIllustration({required this.mainIcon, required this.accentIcon, this.big = false});

  final IconData mainIcon;
  final IconData accentIcon;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.primary.withValues(alpha: 0.18);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: big ? 82 : 72,
            height: big ? 82 : 72,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(big ? 22 : 20)),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Icon(mainIcon, size: big ? 46 : 40, color: colorScheme.primary),
          ),
          Positioned(
            right: -8,
            bottom: -10,
            child: Container(
              decoration: BoxDecoration(color: colorScheme.tertiary.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(8),
              child: Icon(accentIcon, size: big ? 22 : 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextTripCard extends StatelessWidget {
  const _NextTripCard({required this.date, required this.origin, required this.destination});

  final String date;
  final String origin;
  final String destination;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorScheme.primary.withValues(alpha: 0.95), colorScheme.primaryContainer.withValues(alpha: 0.95)]),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _TripInfoColumn(label: 'Data', value: date, alignEnd: false),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.directions_car_filled, color: Colors.white),
                SizedBox(height: 6),
                Icon(Icons.route, color: Colors.white),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TripInfoColumn(label: 'Origem', value: origin, alignEnd: true),
                  const SizedBox(height: 10),
                  _TripInfoColumn(label: 'Destino', value: destination, alignEnd: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripInfoColumn extends StatelessWidget {
  const _TripInfoColumn({required this.label, required this.value, required this.alignEnd});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final crossAxisAlignment = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.90), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
