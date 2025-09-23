// lib/Dishes/Presentations/panel_presentations.dart
import 'package:flutter/material.dart';
import 'package:myapp/Dishes/Presentations/form_presentations.dart';

class PanelPresentations extends StatelessWidget {
  final List<Map<String, dynamic>> presentations;

  const PanelPresentations({
    super.key,
    required this.presentations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Presentaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormPresentations()),
                );
              },
              child: const Text('+ Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ...presentations.map((pres) => Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(pres['image'], width: 50, height: 50, fit: BoxFit.cover),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pres['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('S/${pres['price'].toStringAsFixed(2)}'),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 16.0),
                            Text('${pres['time']} min'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16.0, color: Colors.yellow),
                            Text('${pres['popularity']}% popularidad'),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: pres['popularity'] / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: pres['active'] ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      pres['active'] ? 'Disponible' : 'Inactivo',
                      style: const TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}