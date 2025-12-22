import 'package:flutter/material.dart';
import 'package:poc_viagem/viagens/deslocamento_map_screen.dart';
import 'package:poc_viagem/viagens/detalhe_despesas_screen.dart';
import 'package:poc_viagem/viagens/resumo_viagem_screen.dart';
import 'package:poc_viagem/viagens/selecao_despesas_screen.dart';

import '../ui/theme.dart';
import '../ui/widgets/common_widgets.dart';

class LancamentosDiariasScreen extends StatefulWidget {
  const LancamentosDiariasScreen({super.key, this.dataInicio, this.dataFim, this.fromSelecao = false, this.remainingCategorias = const <String>[]});
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final bool fromSelecao;
  final List<String> remainingCategorias; // Ordem esperada: outras despesas, e 'Aluguel de carro' por último se existir

  @override
  State<LancamentosDiariasScreen> createState() => _LancamentosDiariasScreenState();
}

class _LancamentosDiariasScreenState extends State<LancamentosDiariasScreen> {
  final TextEditingController _descricaoCtrl = TextEditingController();

  // Datas exibidas no seletor e a data selecionada
  late final List<DateTime> _datas;
  late DateTime _dataSelecionada;

  // Seleção por data (permite múltiplas opções por dia; 'Básica' é exclusiva)
  late Map<DateTime, Set<_OpcaoDiaria>> _selecoesPorData;

  @override
  void initState() {
    super.initState();
    final inicio = widget.dataInicio;
    final fim = widget.dataFim;
    if (inicio != null && fim != null) {
      // Constrói a lista de datas do intervalo selecionado (inclusive)
      final days = fim.difference(inicio).inDays;
      _datas = [for (int i = 0; i <= days; i++) DateTime(inicio.year, inicio.month, inicio.day).add(Duration(days: i))];
      _dataSelecionada = _datas.first;
    } else {
      // Fallback: 7 dias a partir de hoje
      final base = DateTime.now();
      _datas = [for (int i = 0; i < 7; i++) DateTime(base.year, base.month, base.day).add(Duration(days: i))];
      _dataSelecionada = _datas.first;
    }

    // Inicializa seleção por data (nenhuma opção selecionada)
    _selecoesPorData = {for (final d in _datas) DateTime(d.year, d.month, d.day): <_OpcaoDiaria>{}};
  }

  // Helpers de seleção por data
  Set<_OpcaoDiaria> _opcoesDaDataAtual() {
    final key = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
    return _selecoesPorData[key] ?? <_OpcaoDiaria>{};
  }

  void _toggleBasica() {
    final key = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
    final atual = Set<_OpcaoDiaria>.from(_opcoesDaDataAtual());
    if (atual.contains(_OpcaoDiaria.basica)) {
      atual.remove(_OpcaoDiaria.basica);
    } else {
      atual
        ..clear()
        ..add(_OpcaoDiaria.basica);
    }
    _selecoesPorData[key] = atual;
  }

  void _toggleNaoBasica(_OpcaoDiaria opcao) {
    final key = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
    final atual = Set<_OpcaoDiaria>.from(_opcoesDaDataAtual());
    if (atual.contains(opcao)) {
      atual.remove(opcao);
    } else {
      atual.add(opcao);
      // Ao escolher qualquer não-básica, desmarca 'Básica'
      atual.remove(_OpcaoDiaria.basica);
    }
    _selecoesPorData[key] = atual;
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool vindoDaSelecao = widget.fromSelecao;
    final bool temAlgumaDiariaSelecionada = _selecoesPorData.values.any((s) => s.isNotEmpty);

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
          'Lançamentos',
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

                    // Seleção de data (simplificado com base nas datas recebidas)
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selecionar data', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _datas
                                .map(
                                  (d) => Expanded(
                                    child: Center(
                                      child: Text(
                                        _fmtDiaSemana(d),
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
                            children: _datas
                                .map(
                                  (d) => Expanded(
                                    child: Center(
                                      child: _DiaItem(data: d, selecionado: _isSameDate(d, _dataSelecionada), onTap: () => setState(() => _dataSelecionada = d)),
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
                            selected: _opcoesDaDataAtual().contains(_OpcaoDiaria.basica),
                            icon: Icons.check_circle_outline,
                            baseColor: Theme.of(context).colorScheme.primary,
                            onTap: () => setState(() => _toggleBasica()),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Desjejum',
                            selected: _opcoesDaDataAtual().contains(_OpcaoDiaria.desjejum),
                            icon: Icons.coffee,
                            baseColor: Colors.orange,
                            onTap: () => setState(() => _toggleNaoBasica(_OpcaoDiaria.desjejum)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Almoço',
                            selected: _opcoesDaDataAtual().contains(_OpcaoDiaria.almoco),
                            icon: Icons.restaurant,
                            baseColor: Colors.amber,
                            onTap: () => setState(() => _toggleNaoBasica(_OpcaoDiaria.almoco)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _OptionItem(
                            label: 'Jantar',
                            selected: _opcoesDaDataAtual().contains(_OpcaoDiaria.jantar),
                            icon: Icons.dinner_dining,
                            baseColor: const Color(0xFF4CAF50),
                            onTap: () => setState(() => _toggleNaoBasica(_OpcaoDiaria.jantar)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final selecaoAtual = Set<_OpcaoDiaria>.from(_opcoesDaDataAtual());
                          setState(() {
                            for (final d in _datas) {
                              _selecoesPorData[DateTime(d.year, d.month, d.day)] = Set<_OpcaoDiaria>.from(selecaoAtual);
                            }
                          });
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(const SnackBar(content: Text('Escolhas replicadas para todas as datas.')));
                        },
                        icon: const Icon(Icons.copy_all),
                        label: const Text('Replicar'),
                      ),
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
                child: FilledButton.tonal(
                  onPressed: !vindoDaSelecao
                      ? () {
                          // Fluxo vindo de LancamentoOpcoesPage: após diárias, vai direto para Resumo
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResumoViagemScreen()));
                        }
                      : (temAlgumaDiariaSelecionada
                            ? () {
                                // Fluxo vindo da seleção: seguir ordem definida
                                final restantes = List<String>.from(widget.remainingCategorias);
                                final bool temAluguel = restantes.contains('Aluguel de carro');
                                final outras = restantes.where((e) => e != 'Aluguel de carro').toList(growable: false);

                                if (outras.isEmpty) {
                                  if (temAluguel) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeslocamentoMapScreen()));
                                  } else {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResumoViagemScreen()));
                                  }
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DetalheDespesasScreen(categoriasSelecionadas: outras, temAluguelCarro: temAluguel),
                                    ),
                                  );
                                }
                              }
                            : null),
                  child: const Text('Próximo'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Visibility(
              visible: !vindoDaSelecao,
              child: TextButton.icon(
                onPressed: () {
                  // Vindo da tela de Diária (opções): permitir adicionar outras despesas (sem Diárias)
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SelecaoDespesasScreen(incluirDiarias: false)));
                },
                icon: Icon(Icons.add, color: cs.primary),
                label: Text(
                  'Adicionar Despesa',
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaItem extends StatelessWidget {
  const _DiaItem({required this.data, required this.selecionado, required this.onTap});
  final DateTime data;
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
      child: Text('${data.day}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: child),
    );
  }
}

String _fmtDiaSemana(DateTime d) {
  const dias = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
  return dias[d.weekday % 7];
}

bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

enum _OpcaoDiaria { basica, desjejum, almoco, jantar }

_OpcaoDiaria _opcaoFromLabel(String label) {
  switch (label) {
    case 'Básica':
      return _OpcaoDiaria.basica;
    case 'Desjejum':
      return _OpcaoDiaria.desjejum;
    case 'Almoço':
      return _OpcaoDiaria.almoco;
    case 'Jantar':
      return _OpcaoDiaria.jantar;
    default:
      return _OpcaoDiaria.jantar;
  }
}

extension _OpcaoDiariaExt on _OpcaoDiaria {
  String get label {
    switch (this) {
      case _OpcaoDiaria.basica:
        return 'Básica';
      case _OpcaoDiaria.desjejum:
        return 'Desjejum';
      case _OpcaoDiaria.almoco:
        return 'Almoço';
      case _OpcaoDiaria.jantar:
        return 'Jantar';
    }
  }
}

// (sem helpers globais adicionais)

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
