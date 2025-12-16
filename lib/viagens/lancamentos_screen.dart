import 'package:flutter/material.dart';
import 'package:poc_viagem/viagens/selecao_despesas_screen.dart';

import '../ui/theme.dart';
import '../ui/widgets/common_widgets.dart';

class LancamentosScreen extends StatefulWidget {
  const LancamentosScreen({super.key});

  @override
  State<LancamentosScreen> createState() => _LancamentosScreenState();
}

class _LancamentosScreenState extends State<LancamentosScreen> {
  final TextEditingController _descricaoCtrl = TextEditingController();

  // Seleção simples de data (ex.: dias 14..20), com 14 pré-selecionado
  final List<int> _dias = List<int>.generate(7, (i) => 14 + i);
  final List<String> _diasSemana = const ['qui', 'sex', 'sáb', 'dom', 'seg', 'ter', 'qua'];
  int _diaSelecionado = 14;

  // Seleção de refeições
  bool _basica = false;
  bool _desjejum = false;
  bool _almoco = false;
  bool _jantar = true; // Jantar inicia selecionado

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeaderMinimal(title: 'Lançamentos'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Título informativo (sem input)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('Agora fale um pouco mais da sua viagem', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Seção de informações da viagem
                    Row(
                      children: [
                        Text('Trecho não informado', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        FilledButton.tonal(onPressed: () {}, child: const Text('Resumo')),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Seleção de data (calendário simplificado)
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selecionar data', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _diasSemana
                                .map(
                                  (d) => Expanded(
                                    child: Center(
                                      child: Text(
                                        d,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _dias
                                .map(
                                  (d) => Expanded(
                                    child: Center(
                                      child: _DiaItem(dia: d, selecionado: d == _diaSelecionado, onTap: () => setState(() => _diaSelecionado = d)),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Diária (seleção de categoria)
                    Text('Diária', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _OptionItem(
                            label: 'Básica',
                            selected: _basica,
                            icon: Icons.check_circle_outline,
                            baseColor: Theme.of(context).colorScheme.primary,
                            onTap: () => setState(() {
                              _basica = true;
                              _desjejum = false;
                              _almoco = false;
                              _jantar = false;
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Desjejum',
                            selected: _desjejum,
                            icon: Icons.coffee,
                            baseColor: Colors.orange,
                            onTap: () => setState(() {
                              _desjejum = !_desjejum;
                              if (_desjejum || _almoco || _jantar) {
                                _basica = false;
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Almoço',
                            selected: _almoco,
                            icon: Icons.restaurant,
                            baseColor: Colors.amber,
                            onTap: () => setState(() {
                              _almoco = !_almoco;
                              if (_desjejum || _almoco || _jantar) {
                                _basica = false;
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Jantar',
                            selected: _jantar,
                            icon: Icons.dinner_dining,
                            baseColor: const Color(0xFF4CAF50),
                            onTap: () => setState(() {
                              _jantar = !_jantar;
                              if (_desjejum || _almoco || _jantar) {
                                _basica = false;
                              }
                            }),
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
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.tonal(onPressed: () {}, child: const Text('Botão')),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelecaoDespesasScreen()));
              },
              icon: Icon(Icons.add, color: cs.primary),
              label: Text(
                'Adicionar Despesa',
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaItem extends StatelessWidget {
  const _DiaItem({required this.dia, required this.selecionado, required this.onTap});
  final int dia;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Widget child = Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selecionado ? cs.primary.withValues(alpha: 0.10) : Colors.transparent,
        border: Border.all(color: selecionado ? cs.primary : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text('$dia', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: child),
    );
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem({required this.label, required this.selected, required this.onTap, this.icon, this.baseColor});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final Color tone = baseColor ?? Theme.of(context).colorScheme.primary;
    final Color bg = selected ? tone.withValues(alpha: 0.20) : Colors.grey.shade100;
    final Color border = selected ? tone : Colors.grey.shade300;
    final Color fg = selected ? tone : Colors.grey.shade800;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, color: fg),
              if (icon != null) const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
