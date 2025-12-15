import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'selecionar_data_viagem_page.dart';

class AdicionarViagemPage extends StatefulWidget {
  const AdicionarViagemPage({super.key});

  @override
  State<AdicionarViagemPage> createState() => _AdicionarViagemPageState();
}

class _AdicionarViagemPageState extends State<AdicionarViagemPage> {
  final _formKey = GlobalKey<FormState>();

  String? _motivo;
  String? _temVoto; // campo texto (formato YYYY-MM)
  String _descricao = '';

  bool get _isValid => (_motivo != null && _motivo!.isNotEmpty) && (_temVoto != null && _validMesAno(_temVoto!)) && _descricao.trim().isNotEmpty;

  bool _validMesAno(String v) {
    final re = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
    return re.hasMatch(v);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelecionarDataViagemPage(motivo: _motivo!, observacoes: _descricao),
        ),
      );
      if (!mounted) return;
      if (result is Map && result['inicio'] != null && result['fim'] != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Período selecionado: '
                '${(result['inicio'] as DateTime).day}/${(result['inicio'] as DateTime).month}/${(result['inicio'] as DateTime).year}'
                ' → '
                '${(result['fim'] as DateTime).day}/${(result['fim'] as DateTime).month}/${(result['fim'] as DateTime).year}',
              ),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HeaderAdicionarViagem()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelBold(text: 'Motivo da viagem'),
                    const SizedBox(height: 8),
                    _ShadowField(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        isExpanded: true,
                        // ignore: deprecated_member_use
                        value: _motivo,
                        hint: const Text('Selecione'),
                        items: const [
                          DropdownMenuItem(value: 'Reunião', child: Text('Reunião')),
                          DropdownMenuItem(value: 'Treinamento', child: Text('Treinamento')),
                          DropdownMenuItem(value: 'Visita a cliente', child: Text('Visita a cliente')),
                          DropdownMenuItem(value: 'Conferência', child: Text('Conferência')),
                          DropdownMenuItem(value: 'Outros', child: Text('Outros')),
                        ],
                        onChanged: (v) => setState(() => _motivo = v),
                        validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _LabelBold(text: 'Tem voto?'),
                    const SizedBox(height: 8),
                    _ShadowField(
                      child: TextFormField(
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Ex: 2024-05', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')), LengthLimitingTextInputFormatter(7)],
                        onChanged: (v) => setState(() => _temVoto = v),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo obrigatório';
                          if (!_validMesAno(v)) return 'Use o formato YYYY-MM';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    _LabelBold(text: 'Conte-nos mais sobre essa viagem'),
                    const SizedBox(height: 8),
                    _ShadowField(
                      child: TextFormField(
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Escreva aqui.', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        minLines: 5,
                        maxLines: 8,
                        onChanged: (v) => setState(() => _descricao = v),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton(onPressed: _isValid ? _submit : null, child: const Text('Próximo')),
        ),
      ),
    );
  }
}

class _HeaderAdicionarViagem extends StatelessWidget {
  const _HeaderAdicionarViagem();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cs.primary, cs.primaryContainer]),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(icon: const Icon(Icons.arrow_back_ios_new), color: Colors.white, onPressed: () => Navigator.maybePop(context)),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) nav.pop();
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(44, 6, 44, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Adicionar viagem',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Conte um pouco mais sobre a sua viagem',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600),
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

class _LabelBold extends StatelessWidget {
  const _LabelBold({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _ShadowField extends StatelessWidget {
  const _ShadowField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
