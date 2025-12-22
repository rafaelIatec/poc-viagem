import 'package:flutter/material.dart';
import 'package:poc_viagem/viagens/deslocamento_map_screen.dart';
import 'package:poc_viagem/viagens/detalhe_despesas_screen.dart';
import 'package:poc_viagem/viagens/lancamentos_diarias_screen.dart';
import 'package:poc_viagem/viagens/resumo_viagem_screen.dart';

class SelecaoDespesasScreen extends StatefulWidget {
  const SelecaoDespesasScreen({super.key, this.incluirDiarias = true});
  final bool incluirDiarias;

  @override
  State<SelecaoDespesasScreen> createState() => _SelecaoDespesasScreenState();
}

class _SelecaoDespesasScreenState extends State<SelecaoDespesasScreen> {
  late final Map<String, bool> _opcoes;

  @override
  void initState() {
    super.initState();
    _opcoes = {
      'Passagens': false,
      'Hospedagem': false,
      'Seguro de viagem': false,
      'Deslocamento': false,
      'Aluguel de carro': false,
      'Abastecimento': false,
      'Diárias': false,
      'Refeições ( religioso )': false,
    };
    if (!widget.incluirDiarias) {
      _opcoes.remove('Diárias');
    }
  }

  bool get _temSelecionadas => _opcoes.values.any((v) => v);

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);
    const destaque = Color(0xFFFFC107); // amarelo/laranja

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Despesas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) nav.pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de instrução com fundo azul
            Container(
              color: azul,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'O que você quer relatar de',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'despesas da viagem?',
                    style: TextStyle(fontWeight: FontWeight.w800, color: destaque),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de opções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _opcoes.keys
                    .map(
                      (k) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _OpcaoDespesaTile(label: k, checked: _opcoes[k]!, onChanged: (val) => setState(() => _opcoes[k] = val ?? false)),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Botão inferior
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _temSelecionadas
                      ? () {
                          final selecionadas = _opcoes.entries.where((e) => e.value).map((e) => e.key).toList(growable: false);

                          final bool temDiarias = selecionadas.contains('Diárias');
                          final bool temAluguel = selecionadas.contains('Aluguel de carro');
                          final List<String> outras = selecionadas.where((e) => e != 'Diárias' && e != 'Aluguel de carro').toList(growable: false);

                          if (temDiarias) {
                            // Ordem: Diárias -> Outras -> Aluguel de carro
                            final restantes = <String>[...outras, if (temAluguel) 'Aluguel de carro'];
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LancamentosDiariasScreen(fromSelecao: true, remainingCategorias: restantes)));
                          } else {
                            // Sem diárias: se só tiver aluguel, vai direto pro mapa; se tiver outras, detalha e aluguel por último
                            if (outras.isEmpty) {
                              if (temAluguel) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const DeslocamentoMapScreen()));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ResumoViagemScreen()));
                              }
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalheDespesasScreen(categoriasSelecionadas: outras, temAluguelCarro: temAluguel),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: azul, foregroundColor: Colors.white),
                  child: const Text('Próximo', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoDespesaTile extends StatelessWidget {
  const _OpcaoDespesaTile({required this.label, required this.checked, required this.onChanged});
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color border = checked ? Theme.of(context).colorScheme.primary : Colors.grey.shade300;
    final Color bg = checked ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06) : Colors.white;
    final Color fg = checked ? Theme.of(context).colorScheme.primary : Colors.grey.shade800;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: ListTile(
        leading: Checkbox(
          value: checked,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700),
        ),
        onTap: () => onChanged(!checked),
      ),
    );
  }
}

// Tela de detalhamento (placeholder mínimo)
class DetalheDespesaScreen extends StatelessWidget {
  const DetalheDespesaScreen({super.key, required this.categoriasSelecionadas});
  final List<String> categoriasSelecionadas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da despesa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categorias selecionadas:', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...categoriasSelecionadas.map((c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• $c'))),
          ],
        ),
      ),
    );
  }
}
