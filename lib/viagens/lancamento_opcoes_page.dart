import 'package:flutter/material.dart';
import 'package:poc_viagem/viagens/lancamentos_diarias_screen.dart';
import 'package:poc_viagem/viagens/selecao_despesas_screen.dart';

import '../ui/theme.dart';
// import 'package:flutter/services.dart';
import '../ui/widgets/common_widgets.dart';

class LancamentoOpcoesPage extends StatefulWidget {
  const LancamentoOpcoesPage({super.key, this.dataInicio, this.dataFim});
  final DateTime? dataInicio;
  final DateTime? dataFim;

  @override
  State<LancamentoOpcoesPage> createState() => _LancamentoOpcoesPageState();
}

class _LancamentoOpcoesPageState extends State<LancamentoOpcoesPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1976D2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        centerTitle: true,
        title: Text(
          'Lançamento de despesas',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _IlustracaoFinanceira(color: cs.primary),
                    const SizedBox(height: AppSpacing.md),
                    const AppCard(
                      child: Text(
                        'Deseja fazer lançamento agora?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlineOption(
                            label: 'Diária',
                            selected: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LancamentosDiariasScreen(dataInicio: widget.dataInicio, dataFim: widget.dataFim),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppOutlineOption(
                            label: 'Por Despesa',
                            selected: true,
                            onTap: () {
                              // Acesso direto: manter 'Diárias' disponível na seleção
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelecaoDespesasScreen(incluirDiarias: true)));
                            },
                          ),
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
        minimum: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        child: SizedBox(
          height: 52,
          child: FilledButton.tonal(onPressed: () => Navigator.maybePop(context), child: const Text('Mais tarde')),
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
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: [appShadow(0.04)]),
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
