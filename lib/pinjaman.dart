import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pinjaman extends StatefulWidget {
  const Pinjaman({super.key});

  @override
  _PinjamanState createState() => _PinjamanState();
}

class _PinjamanState extends State<Pinjaman> {
  // Pindahkan controller keluar dari build
  TextEditingController idMemberC = TextEditingController();
  TextEditingController kodeBukuC = TextEditingController();
  TextEditingController tglPinjamC = TextEditingController();

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        // Menyimpan tanggal yang dipilih ke dalam controller
        tglPinjamC.text = pickedDate.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
            left: 40.0, right: 40.0, top: 20.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Pinjaman',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: idMemberC,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "ID Member",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: kodeBukuC,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Kode Buku",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: tglPinjamC,
              readOnly: true,
              autocorrect: false,
              onTap: () {
                _selectDate();
              },
              decoration: const InputDecoration(
                labelText: "Tanggal Pinjam",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.date_range),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                if (idMemberC.text.isEmpty ||
                    kodeBukuC.text.isEmpty ||
                    tglPinjamC.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Peringatan'),
                        content: const Text('Tidak boleh ada data yang kosong'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                var response = await http.post(
                    Uri.parse("http://localhost/uasml/api/pinjaman"),
                    body: {
                      "id_member": idMemberC.text,
                      "kode_buku": kodeBukuC.text,
                      "tgl_pinjam": tglPinjamC.text,
                    });

                var updateStok = await http.post(
                    Uri.parse(
                        "http://localhost/uasml/api/buku?id=${kodeBukuC.text}"),
                    body: {
                      "action": "pinjam",
                    });

                if (response.statusCode == 200 &&
                    updateStok.statusCode == 200) {
                  // print('Response status: ${response.statusCode}');
                  // print('Response body: ${response.body}');
                  idMemberC.clear();
                  kodeBukuC.clear();
                  tglPinjamC.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data Pinjaman berhasil ditambah'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Sepertinya ada kesalahan server, harap tunggu bentar dan dicoba lagi yak'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Tambah Pinjaman'),
            ),
          ],
        ),
      ),
    );
  }
}
