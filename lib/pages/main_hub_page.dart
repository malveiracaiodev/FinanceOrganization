import 'package:flutter/material.dart';
import '../widgets/fundo_cosmico.dart';
import '../widgets/app_drawer.dart';
import '../core/theme/app_theme.dart';
import '../services/preferences_service.dart';
import '../models/usuario.dart';
import 'dashboard_page.dart'; // Import da sua dashboard atual

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Usuario? _usuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = await PreferencesService.carregarUsuario();
    setState(() {
      _usuario = user;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primeiroNome = _usuario?.nome ?? 'Comandante';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(), // Seu menu lateral acoplado aqui
      body: FundoCosmico(
        child: _carregando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🌌 BARRA SUPERIOR (Menu Hambúrguer Espacial)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00B4D8), width: 1),
                            ),
                            child: const Text(
                              "SISTEMA ONLINE",
                              style: TextStyle(color: Color(0xFF8CE8FF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // 👋 SAUDAÇÃO CENTRAL
                      Text(
                        "Olá, $primeiroNome!",
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bem-vindo ao centro de comando da sua organização financeira.",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
                      ),
                      
                      const Spacer(),

                      // 🛸 CARD CENTRAL DE STATUS RÁPIDO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1424).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF1A2740), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFF00B4D8), size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              "MARK I COGNITIVO",
                              style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Pronto para processar dados de despesas e contratos vigentes.",
                              textAlign: Center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 🔥 BOTÃO PREMIUM ESTILO STITCH UI PARA ACESSAR A DASHBOARD
                      Padding(
                        padding: const EdgeInsets.bottom(24.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF060B16), // Fundo espacial escuro
                            foregroundColor: const Color(0xFF8CE8FF), // Ciano Stitch
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Color(0xFF00B4D8), width: 2), // Borda Neon Ciano Brilhante
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF00B4D8).withValues(alpha: 0.4), // Brilho de fundo
                          ),
                          onPressed: () {
                            // 🚀 Navegação suave para a tela de Dashboard
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardPage()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rocket_launch_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                "ACESSAR PAINEL DE CONTROLE",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2),
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