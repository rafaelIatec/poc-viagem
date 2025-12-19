import 'package:flutter/material.dart';

import '../ui/theme.dart';

class DeslocamentoMapScreen extends StatefulWidget {
  const DeslocamentoMapScreen({super.key});

  @override
  State<DeslocamentoMapScreen> createState() => _DeslocamentoMapScreenState();
}

class _DeslocamentoMapScreenState extends State<DeslocamentoMapScreen> {
  final TextEditingController _origemCtrl = TextEditingController(text: 'Curitiba, PR, Brasil');
  final TextEditingController _destinoCtrl = TextEditingController(text: 'Hortolândia, SP, Brasil');
  int _zoom = 12;

  @override
  void dispose() {
    _origemCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo: Mapa (fake) com imagem cobrindo toda a tela
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFBBD1F7), Color(0xFFE3ECFF)]),
              ),
            ),
          ),

          // AppBar customizada
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                height: 48,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Deslocamento',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Campos de endereço sobrepostos
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 76, AppSpacing.md, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _AddressField(label: 'Origem', controller: _origemCtrl, onClear: () => setState(() => _origemCtrl.clear())),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Botão de inversão
                      Column(
                        children: [
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                final tmp = _origemCtrl.text;
                                _origemCtrl.text = _destinoCtrl.text;
                                _destinoCtrl.text = tmp;
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const SizedBox(height: 36, width: 36, child: Icon(Icons.swap_vert, color: Colors.blue)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AddressField(label: 'Destino', controller: _destinoCtrl, onClear: () => setState(() => _destinoCtrl.clear())),
                ],
              ),
            ),
          ),

          // Controles de zoom
          Positioned(
            right: AppSpacing.md,
            bottom: 140,
            child: Material(
              color: Colors.white,
              elevation: 3,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                height: 98,
                width: 44,
                child: Column(
                  children: [
                    IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _zoom++)),
                    const Divider(height: 1),
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _zoom = _zoom > 0 ? _zoom - 1 : 0)),
                  ],
                ),
              ),
            ),
          ),

          // Painel inferior persistente
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.lg), topRight: Radius.circular(AppRadius.lg)),
                boxShadow: [appShadow(0.08)],
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
                        child: const Text('Salvar e Avançar', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({required this.label, required this.controller, required this.onClear});
  final String label;
  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [appShadow(0.06)],
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClear),
        ],
      ),
    );
  }
}
