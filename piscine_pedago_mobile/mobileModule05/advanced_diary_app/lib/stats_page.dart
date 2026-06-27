// =============================================================================
//  PISCINE MOBILE - MÓDULO 05: STATS WIDGET
//  Componente encargado de analizar las entradas del diario y mostrar
//  estadísticas visuales sobre el estado de ánimo del usuario.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  Color _getFeelingColor(String feeling) {
    if (feeling.contains('Feliz')) return Colors.amber;
    if (feeling.contains('Neutral')) return Colors.blueGrey;
    if (feeling.contains('Triste')) return Colors.blue;
    if (feeling.contains('Enfadado')) return Colors.red;
    if (feeling.contains('Tranquilo')) return Colors.teal;
    if (feeling.contains('Emocionado')) return Colors.orange;
    if (feeling.contains('Enamorado')) return Colors.pink;
    if (feeling.contains('Sorprendido')) return Colors.purple;
    if (feeling.contains('Cansado')) return Colors.blueGrey;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Escuchamos todas las entradas del usuario para calcular estadísticas en tiempo real.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('diaries')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Mientras carga, mostramos un indicador circular.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        
        // Si no hay datos, informamos al usuario.
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                'Escribe algunas notas para ver tu análisis de ánimo aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        // --- LÓGICA DE CÁLCULO ---
        // Usamos un Mapa para contar cuántas veces aparece cada sentimiento.
        Map<String, int> feelingCounts = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final feeling = data['feeling'] as String?;
          if (feeling != null) {
            feelingCounts[feeling] = (feelingCounts[feeling] ?? 0) + 1;
          }
        }

        // Convertimos el mapa a una lista y la ordenamos de mayor a menor frecuencia.
        final sortedFeelings = feelingCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Análisis de Sentimientos',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Basado en tus últimas ${docs.length} vivencias.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              
              // Generamos una barra de progreso para cada sentimiento registrado.
              ListView.builder(
                shrinkWrap: true, // Importante: permite que la lista ocupe solo el espacio necesario.
                physics: const NeverScrollableScrollPhysics(), // El scroll lo gestiona el padre.
                itemCount: sortedFeelings.length,
                itemBuilder: (context, index) {
                    final entry = sortedFeelings[index];
                    final percentage = (entry.value / docs.length);
                    final color = _getFeelingColor(entry.key);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      entry.key.split(' ').first,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    entry.key.split(' ').skip(1).join(' '),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                '${(percentage * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: color, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Barra visual que indica la proporción.
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
