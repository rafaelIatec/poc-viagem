import 'package:flutter/material.dart';

import '../ui/theme.dart';
import './deslocamento_map_screen.dart';

class ResumoViagemScreen extends StatefulWidget {
  const ResumoViagemScreen({super.key});

  @override
  State<ResumoViagemScreen> createState() => _ResumoViagemScreenState();
}

class _ResumoViagemScreenState extends State<ResumoViagemScreen> {
  // Seleção de dias (exemplo simples: 14 dias corridos do mês atual)
  late final List<DateTime> _dias;
  int _selecionadoIndex = 1; // ex.: dia 2 inicialmente

  // Diária (exemplo)
  final double _qtdDiarias = 1.25;
  final double _valorDiaria = 30.0;

  // Despesas
  final List<_ExpenseItem> _itens = <_ExpenseItem>[
    _ExpenseItem(id: '1', titulo: 'Aluguel de carro', valor: 1000.0, anexos: 2, icon: Icons.directions_car_filled_outlined),
    _ExpenseItem(id: '2', titulo: 'Hospedagem', valor: 850.0, anexos: 1, icon: Icons.apartment),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    _dias = List<DateTime>.generate(14, (i) => first.add(Duration(days: i)));
    // Marcar índice 1 (dia 2) se existir
    if (_dias.length > 1) _selecionadoIndex = 1;
  }

  double get _totalDiaria => _qtdDiarias * _valorDiaria;
  double get _totalDespesas => _itens.fold<double>(0, (acc, e) => acc + e.valor);
  double get _totalGeral => _totalDiaria + _totalDespesas;

  String _formatBRL(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    String intPart = parts[0];
    final decPart = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final remaining = intPart.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write('.');
    }
    final grouped = buf.toString();
    return 'R\$ $grouped,$decPart';
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);
    const azulEscuro = Color(0xFF0D47A1);
    const roxo = Color(0xFF673AB7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        title: const Text(
          'Resumo da viagem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),

            // Seletor de data superior
            _DiaSelector(dias: _dias, selecionado: _selecionadoIndex, onSelect: (i) => setState(() => _selecionadoIndex = i)),

            const SizedBox(height: AppSpacing.md),

            // Banner de Total Geral
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: azul.withValues(alpha: 0.30)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(color: azul, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _formatBRL(_totalGeral),
                      style: TextStyle(color: azulEscuro, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Título Diária + Editar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Text('Diaria', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  OutlinedButton(onPressed: () {}, child: const Text('Editar')),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Card de Diária
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      boxShadow: [appShadow(0.06)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Diárias', style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text('$_qtdDiarias', style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valor', style: TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(_formatBRL(_valorDiaria), style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Ícones de refeição no canto superior direito
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Row(
                      children: [
                        _MealDot(color: Colors.purple.shade200, icon: Icons.coffee),
                        const SizedBox(width: 6),
                        _MealDot(color: Colors.amber.shade300, icon: Icons.restaurant),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Botão central "Adicionar Despesa"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Exemplo simples: adicionar item mock
                      setState(() {
                        _itens.add(_ExpenseItem(id: DateTime.now().microsecondsSinceEpoch.toString(), titulo: 'Nova despesa', valor: 120.0, anexos: 0, icon: Icons.receipt_long));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Despesa'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Lista de despesas lançadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  final item = _itens[index];
                  return ExpenseListItem(
                    item: item,
                    valorColor: roxo,
                    onDismissed: (direction) {
                      setState(() => _itens.removeAt(index));
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg + 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeslocamentoMapScreen()));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add_road),
              label: const Text('Adicionar KM', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealDot extends StatelessWidget {
  const _MealDot({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.70)),
    );
  }
}

class _DiaSelector extends StatelessWidget {
  const _DiaSelector({required this.dias, required this.selecionado, required this.onSelect});
  final List<DateTime> dias;
  final int selecionado;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final labels = const ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final d = dias[index];
          final sel = index == selecionado;
          final label = labels[d.weekday % 7]; // DateTime weekday: 1=Mon ... 7=Sun
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: sel ? Colors.blue.withValues(alpha: 0.06) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: sel ? Colors.blue : Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${d.day}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      if (sel) ...[
                        const SizedBox(width: 6),
                        Container(
                          height: 6,
                          width: 6,
                          decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: dias.length,
      ),
    );
  }
}

class _ExpenseItem {
  _ExpenseItem({required this.id, required this.titulo, required this.valor, required this.anexos, required this.icon});
  final String id;
  final String titulo;
  final double valor;
  final int anexos;
  final IconData icon;
}

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({super.key, required this.item, required this.onDismissed, this.valorColor});
  final _ExpenseItem item;
  final DismissDirectionCallback onDismissed;
  final Color? valorColor;

  @override
  Widget build(BuildContext context) {
    final roxo = valorColor ?? const Color(0xFF673AB7);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(AppRadius.md)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.red.shade700),
              const SizedBox(width: 6),
              Text(
                'Remover',
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        onDismissed: onDismissed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: Colors.grey.shade800),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.titulo, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_file, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                          child: Text('${item.anexos}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                // valor formatado
                _formatLocalBRL(item.valor),
                style: TextStyle(color: roxo, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLocalBRL(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    String intPart = parts[0];
    final decPart = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final remaining = intPart.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buf.write('.');
    }
    final grouped = buf.toString();
    return 'R\$ $grouped,$decPart';
  }
}
