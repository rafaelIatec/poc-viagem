import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LancamentoOpcoesPage extends StatefulWidget {
  const LancamentoOpcoesPage({super.key});

  @override
  State<LancamentoOpcoesPage> createState() => _LancamentoOpcoesPageState();
}

class _LancamentoOpcoesPageState extends State<LancamentoOpcoesPage> {
  String? _selecionado; // 'diario' | 'despesa'

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _HeaderMinimalista(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    _IlustracaoFinanceira(color: cs.primary),
                    const SizedBox(height: 20),
                    _PerguntaCard(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _OpcaoButton(label: 'Diário', selected: _selecionado == 'diario', onTap: () => setState(() => _selecionado = 'diario')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OpcaoButton(label: 'Por Despesa', selected: _selecionado == 'despesa', onTap: () => setState(() => _selecionado = 'despesa')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton.tonal(onPressed: () => Navigator.maybePop(context), child: const Text('Mais tarde')),
        ),
      ),
    );
  }
}

class _HeaderMinimalista extends StatelessWidget {
  const _HeaderMinimalista();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.maybePop(context)),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Lançamento de despesas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  final nav = Navigator.of(context);
                  if (nav.canPop()) nav.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IlustracaoFinanceira extends StatelessWidget {
  const _IlustracaoFinanceira({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final neutral = Colors.grey.shade300;
    final accent = color.withValues(alpha: 0.18);

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 160,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 56, color: Colors.grey.shade700),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 120,
                    decoration: BoxDecoration(color: neutral, borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: 80,
                    decoration: BoxDecoration(color: neutral, borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -12,
              top: -12,
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(Icons.savings_outlined, color: color, size: 24),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -10,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(Icons.bar_chart_rounded, color: color, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerguntaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Text(
          'Deseja fazer lançamento agora?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _OpcaoButton extends StatelessWidget {
  const _OpcaoButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primary.withValues(alpha: 0.12) : Colors.grey.shade100;
    final border = selected ? cs.primary : Colors.grey.shade300;
    final fg = selected ? cs.primary : Colors.grey.shade800;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, color: fg),
          ),
        ),
      ),
    );
  }
}
