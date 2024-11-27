import 'package:flutter/material.dart';

class Pinjaman extends StatelessWidget {
  const Pinjaman({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.credit_card, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'Daftar Pinjaman',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
