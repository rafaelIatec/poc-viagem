import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poc_viagem/viagens/deslocamento_map_screen.dart';
import 'package:poc_viagem/viagens/resumo_viagem_screen.dart';

import '../ui/theme.dart';

class DetalheDespesasScreen extends StatefulWidget {
  const DetalheDespesasScreen({super.key, required this.categoriasSelecionadas, this.temAluguelCarro = false});
  final List<String> categoriasSelecionadas;
  final bool temAluguelCarro; // Se verdadeiro, ao concluir vai para DeslocamentoMapScreen

  @override
  State<DetalheDespesasScreen> createState() => _DetalheDespesasScreenState();
}

class _DetalheDespesasScreenState extends State<DetalheDespesasScreen> {
  final TextEditingController _valorCtrl = TextEditingController();
  final TextEditingController _obsCtrl = TextEditingController();

  final List<_ItemDespesa> _itens = [];
  final List<String> _comprovantes = [];
  int _currentIndex = 0;

  double get _valorDigitado {
    final raw = _valorCtrl.text.trim().replaceAll('.', '').replaceAll(',', '.');
    if (raw.isEmpty) return 0.0;
    return double.tryParse(raw) ?? 0.0;
  }

  double get _total => _itens.fold<double>(0.0, (acc, e) => acc + e.valor) + _valorDigitado;

  String _formatBRL(double v) {
    final s = v.toStringAsFixed(2); // 1234.56
    final parts = s.split('.');
    String intPart = parts[0];
    final decPart = parts[1];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final remaining = intPart.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buf.write('.');
      }
    }
    final grouped = buf.toString();
    return 'R\$ $grouped,$decPart';
  }

  void _adicionarDespesa() {
    final valor = _valorDigitado;
    if (valor <= 0) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Informe um valor válido.')));
      return;
    }
    final total = widget.categoriasSelecionadas.length;
    if (_currentIndex >= total) {
      return;
    }
    // Permite apenas 1 item por categoria atual
    if (_itens.length > _currentIndex) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Despesa já adicionada para "${widget.categoriasSelecionadas[_currentIndex]}".')));
      return;
    }
    _itens.add(_ItemDespesa(valor: valor, observacao: _obsCtrl.text.trim()));
    _valorCtrl.clear();
    _obsCtrl.clear();
    setState(() {});
  }

  void _adicionarComprovantes() async {
    // Placeholder: abre opções e adiciona um comprovante fictício
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeria'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Câmera'), onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
    _comprovantes.add('comprovante_${_comprovantes.length + 1}.jpg');
    setState(() {});
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);
    const destaque = Color(0xFFFFC107);
    final total = widget.categoriasSelecionadas.length;
    final categoriaAtual = total > 0 ? widget.categoriasSelecionadas[_currentIndex] : 'Despesa';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          categoriaAtual,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
            // Seção de título/instrução
            Container(
              color: azul,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Conte-nos mais sobre',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'seu gasto...',
                    style: TextStyle(color: destaque, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Progresso do preenchimento
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: azul),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Despesa ${_currentIndex + 1} de $total',
                    style: TextStyle(color: azul, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text('Restantes: ${total - (_currentIndex + 1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Resumo do Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                height: 64,
                decoration: BoxDecoration(color: azul.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
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
                      _formatBRL(_total),
                      style: TextStyle(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Formulário de Entrada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  boxShadow: [appShadow(0.06)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Valor', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        decoration: const InputDecoration(
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: AppSpacing.md),
                      const Text('Observação', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _obsCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Valor devido a...',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botão de Adição Rápida alinhado à direita
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: (_currentIndex >= total || _itens.length > _currentIndex) ? null : _adicionarDespesa,
                  icon: Icon(Icons.add, color: azul),
                  label: Text(
                    'Adicionar despesa',
                    style: TextStyle(color: azul, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: azul),
                    minimumSize: const Size(10, 36),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Lista dos itens adicionados (opcional, para visualização)
            if (_itens.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Itens adicionados', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.xs),
                    ..._itens.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.observacao.isEmpty ? 'Sem observação' : e.observacao)),
                            Text(_formatBRL(e.valor), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Ações inferiores
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _adicionarComprovantes,
                      style: ElevatedButton.styleFrom(backgroundColor: azul.withValues(alpha: 0.08), foregroundColor: azul, minimumSize: const Size.fromHeight(48)),
                      child: const Text('Adicionar comprovantes', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final total = widget.categoriasSelecionadas.length;
                        if (_currentIndex >= total) {
                          return;
                        }
                        // Se ainda não adicionou a despesa desta categoria, tenta adicionar automaticamente
                        if (_itens.length == _currentIndex) {
                          final valor = _valorDigitado;
                          if (valor <= 0) {
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(const SnackBar(content: Text('Informe um valor para adicionar esta despesa.')));
                            return;
                          }
                          _itens.add(_ItemDespesa(valor: valor, observacao: _obsCtrl.text.trim()));
                          _valorCtrl.clear();
                          _obsCtrl.clear();
                        }

                        // Avança para a próxima categoria ou segue para o resumo
                        if (_currentIndex + 1 < total) {
                          setState(() {
                            _currentIndex += 1;
                          });
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(SnackBar(content: Text('Agora: ${widget.categoriasSelecionadas[_currentIndex]}')));
                          return;
                        }
                        // Final do detalhamento: se houver aluguel, segue para mapa; senão, vai para resumo
                        if (widget.temAluguelCarro) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DeslocamentoMapScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ResumoViagemScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: azul, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                      child: const Text('Próximo', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDespesa {
  _ItemDespesa({required this.valor, required this.observacao});
  final double valor;
  final String observacao;
}
