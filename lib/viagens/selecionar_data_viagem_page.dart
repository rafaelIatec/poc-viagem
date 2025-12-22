import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lancamento_opcoes_page.dart';

class SelecionarDataViagemPage extends StatefulWidget {
  const SelecionarDataViagemPage({super.key, required this.motivo, required this.observacoes});

  final String motivo;
  final String observacoes;

  @override
  State<SelecionarDataViagemPage> createState() => _SelecionarDataViagemPageState();
}

class _SelecionarDataViagemPageState extends State<SelecionarDataViagemPage> {
  DateTime? _inicio;
  DateTime? _fim;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HeaderDataViagem()),
          const SliverToBoxAdapter(child: _WeekdayHeader()),
          SliverToBoxAdapter(
            child: _ResumoSelecao(inicio: _inicio, fim: _fim),
          ),
          SliverList.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final now = DateTime.now();
              final monthDate = DateTime(now.year, now.month + index, 1);
              return _MonthCalendar(month: monthDate, inicio: _inicio, fim: _fim, onDayTap: _onDayTap);
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: FilledButton(
            onPressed: _inicio == null
                ? null
                : () {
                    final inicio = _inicio!;
                    final fim = _fim ?? _inicio!;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LancamentoOpcoesPage(dataInicio: inicio, dataFim: fim),
                      ),
                    );
                  },
            child: const Text('Próximo'),
          ),
        ),
      ),
    );
  }

  void _onDayTap(DateTime day) {
    setState(() {
      if (_inicio == null) {
        _inicio = day;
        _fim = null;
        return;
      }
      if (_fim == null) {
        if (!day.isBefore(_inicio!)) {
          _fim = day;
        } else {
          _inicio = day;
          _fim = null;
        }
        return;
      }
      _inicio = day;
      _fim = null;
    });
  }
}

class _HeaderDataViagem extends StatelessWidget {
  const _HeaderDataViagem();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        height: 140,
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.maybePop(context)),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) nav.pop();
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Data da viagem',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final labels = const ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final l in labels)
            Expanded(
              child: Center(
                child: Text(
                  l,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResumoSelecao extends StatelessWidget {
  const _ResumoSelecao({this.inicio, this.fim});

  final DateTime? inicio;
  final DateTime? fim;

  String _fmt(DateTime d) {
    const dias = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb'];
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final dow = dias[d.weekday % 7];
    final month = meses[d.month - 1];
    return '$dow, ${d.day} $month ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inicioFmt = inicio != null ? _fmt(inicio!) : '--';
    final fimFmt = (fim ?? inicio) != null ? _fmt((fim ?? inicio)!) : '--';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: _ResumoCol(label: 'Início', value: inicioFmt, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResumoCol(label: 'Fim', value: fimFmt, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumoCol extends StatelessWidget {
  const _ResumoCol({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.month, required this.inicio, required this.fim, required this.onDayTap});

  final DateTime month; // first day of month
  final DateTime? inicio;
  final DateTime? fim;
  final void Function(DateTime) onDayTap;

  int _daysInMonth(DateTime m) {
    final firstNext = (m.month == 12) ? DateTime(m.year + 1, 1, 1) : DateTime(m.year, m.month + 1, 1);
    return firstNext.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = _daysInMonth(month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7; // 0=Sun

    const mesesLongos = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Center(
            child: Text('${mesesLongos[month.month - 1]} ${month.year}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6),
            itemCount: firstWeekday + days,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              final dayNum = index - firstWeekday + 1;
              final date = DateTime(month.year, month.month, dayNum);

              final isStart = inicio != null && _isSameDate(date, inicio!);
              final isEnd = fim != null && _isSameDate(date, fim!);
              final inRange = (inicio != null) ? (fim == null ? _isSameDate(date, inicio!) : !date.isBefore(_min(inicio!, fim!)) && !date.isAfter(_max(inicio!, fim!))) : false;

              final isMiddle = inRange && !isStart && !isEnd;

              Color bg;
              Color fg;
              BoxDecoration? deco;
              if (isStart || isEnd) {
                bg = cs.primary;
                fg = Colors.white;
                deco = const BoxDecoration(shape: BoxShape.circle);
              } else if (isMiddle) {
                bg = cs.primary.withValues(alpha: 0.18);
                fg = Colors.black87;
                deco = BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8));
              } else {
                bg = Colors.transparent;
                fg = Colors.black87;
              }

              return GestureDetector(
                onTap: () => onDayTap(date),
                child: Container(
                  decoration: deco,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: (isStart || isEnd) ? BoxDecoration(color: bg, shape: BoxShape.circle) : null,
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: (isStart || isEnd) ? Colors.white : fg, fontWeight: (isStart || isEnd) ? FontWeight.w800 : FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
  DateTime _max(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}
