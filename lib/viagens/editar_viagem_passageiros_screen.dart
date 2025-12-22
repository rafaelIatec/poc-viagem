import 'package:flutter/material.dart';

import '../ui/theme.dart';
import './resumo_auxilio_screen.dart';

class EditarViagemPassageirosScreen extends StatefulWidget {
  const EditarViagemPassageirosScreen({super.key});

  @override
  State<EditarViagemPassageirosScreen> createState() => _EditarViagemPassageirosScreenState();
}

class _EditarViagemPassageirosScreenState extends State<EditarViagemPassageirosScreen> {
  final TextEditingController _nomeCtrl = TextEditingController();
  String? _trechoSelecionado;

  final List<String> _trechos = const <String>['Curitiba -> São Paulo', 'São Paulo -> Campinas', 'Pinheiro -> Santa Helena'];

  final List<_Passageiro> _passageiros = <_Passageiro>[];
  int? _editIndex;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  void _adicionarOuSalvar() {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty || _trechoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome e selecione o trecho.')));
      return;
    }

    if (_editIndex != null) {
      _passageiros[_editIndex!] = _Passageiro(nome: nome, trecho: _trechoSelecionado!);
      _editIndex = null;
    } else {
      _passageiros.add(_Passageiro(nome: nome, trecho: _trechoSelecionado!));
    }

    _nomeCtrl.clear();
    setState(() => _trechoSelecionado = null);
  }

  void _editar(int index) {
    final p = _passageiros[index];
    _nomeCtrl.text = p.nome;
    _trechoSelecionado = p.trecho;
    setState(() => _editIndex = index);
  }

  void _excluir(int index) {
    setState(() => _passageiros.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    const azulHeader = Color(0xFF1976D2);
    const amarelo = Color(0xFFFFC107);
    const azulAvancar = Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: azulHeader,
          elevation: 0,
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
          centerTitle: true,
          title: const Text(
            'Editar viagem',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                children: const [
                  Text(
                    'Informe quem viajou com você',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'em cada trecho.',
                    style: TextStyle(color: amarelo, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quem viajou com você?', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              _CampoNome(controller: _nomeCtrl),
              const SizedBox(height: AppSpacing.sm),
              _CampoTrecho(trechos: _trechos, value: _trechoSelecionado, onChanged: (v) => setState(() => _trechoSelecionado = v)),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _adicionarOuSalvar,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: azulHeader),
                    foregroundColor: azulHeader,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_editIndex != null ? 'Salvar' : 'Adicionar passageiro', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Lista de passageiros
              if (_passageiros.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [appShadow(0.04)],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      for (int i = 0; i < _passageiros.length; i++) ...[
                        _PassageiroItem(passageiro: _passageiros[i], onEdit: () => _editar(i), onDelete: () => _excluir(i)),
                        if (i < _passageiros.length - 1) const Divider(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),

              if (_passageiros.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const Text('Nenhum passageiro adicionado ainda.'),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ResumoAuxilioScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: azulAvancar,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Avançar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _CampoNome extends StatelessWidget {
  const _CampoNome({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Digite o nome completo',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}

class _CampoTrecho extends StatelessWidget {
  const _CampoTrecho({required this.trechos, required this.value, required this.onChanged});
  final List<String> trechos;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Selecione os trechos')),
        ...trechos.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class _PassageiroItem extends StatelessWidget {
  const _PassageiroItem({required this.passageiro, required this.onEdit, required this.onDelete});
  final _Passageiro passageiro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Colors.black54),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(passageiro.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, color: Colors.black87),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(passageiro.trecho)),
          ],
        ),
      ],
    );
  }
}

class _Passageiro {
  final String nome;
  final String trecho;
  _Passageiro({required this.nome, required this.trecho});
}
