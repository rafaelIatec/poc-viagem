import 'package:flutter/material.dart';
import 'package:poc_viagem/viagens/resumo_viagem_screen.dart';

import '../ui/theme.dart';

class ResumoAuxilioScreen extends StatefulWidget {
  const ResumoAuxilioScreen({super.key});

  @override
  State<ResumoAuxilioScreen> createState() => _ResumoAuxilioScreenState();
}

class _ResumoAuxilioScreenState extends State<ResumoAuxilioScreen> {
  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);
    const azulVibrante = Color(0xFF2196F3);
    const amarelo = Color(0xFFFFC107);
    final azulClaro = const Color(0xFF1976D2).withOpacity(0.08);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(116),
        child: AppBar(
          backgroundColor: azul,
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
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Veja o resumo dos KM percorridos e',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'o valor estimado do auxílio',
                style: TextStyle(color: amarelo, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Total Geral
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: azulClaro, borderRadius: BorderRadius.circular(AppRadius.lg)),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Total',
                      style: TextStyle(color: azul, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'R\$ 64,91',
                      style: TextStyle(color: azul, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Cards de Resumo
              const ResumoKmCard(titulo: 'Sozinho', km: '45.55 Km', valorPorKm: 'R\$ 1,4250', total: 'R\$ 64,91'),
              const SizedBox(height: AppSpacing.md),
              const ResumoKmCard(titulo: '1 passageiro', km: '45.55 Km', valorPorKm: 'R\$ 1,4250', total: 'R\$ 64,91'),
              const SizedBox(height: AppSpacing.md),
              const ResumoKmCard(titulo: '2 ou+ passageiros', km: '45.55 Km', valorPorKm: 'R\$ 1,4250', total: 'R\$ 64,91'),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResumoViagemScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: azulVibrante,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Salvar e Avançar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class ResumoKmCard extends StatelessWidget {
  const ResumoKmCard({super.key, required this.titulo, required this.km, required this.valorPorKm, required this.total});
  final String titulo;
  final String km;
  final String valorPorKm;
  final String total;

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1976D2);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [appShadow(0.04)],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: azul, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          _linhaItem('Km', km),
          const SizedBox(height: AppSpacing.xs),
          _linhaItem('Valor por Km', valorPorKm),
          const SizedBox(height: AppSpacing.xs),
          _linhaItem('TOTAL', total, bold: true),
        ],
      ),
    );
  }

  Widget _linhaItem(String titulo, String valor, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: style),
        Text(valor, style: style),
      ],
    );
  }
}
