import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryPengembalian extends StatefulWidget {
  const HistoryPengembalian({super.key});

  @override
  _HistoryPengembalianState createState() => _HistoryPengembalianState();
}

class _HistoryPengembalianState extends State<HistoryPengembalian> {
  List<Map<String, String>> daftarPengembalian = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/uasml/api/pengembalian'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          daftarPengembalian =
              List<Map<String, String>>.from(responseData['data'].map((item) {
            return {
              'tgl_kembali': item['tgl_kembali'].toString(),
              'kode_pengembalian': item['kode_pengembalian'].toString(),
              'kode_pinjaman': item['kode_pinjaman'].toString(),
            };
          }).toList());
          isLoading = false;
        });
      } else {
        setState(() {
          daftarPengembalian = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  //detail
  void detailPengembalian(String kodePengembalian) async {
    showDialog(
      context: context,
      builder: (context) {
        final member = daftarPengembalian.firstWhere(
            (pengembalian) => pengembalian['kode_pengembalian'] == kodePengembalian);
        final TextEditingController tglKembaliController =
            TextEditingController(text: member['tgl_kembali']);
        final TextEditingController kodePinjamanController =
            TextEditingController(text: member['kode_pinjaman']);
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // buat lebar penuh
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 40.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Detail pengembalian $kodePengembalian',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tglKembaliController,
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tgl Kembali",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kodePinjamanController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Kode Pinjaman",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
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
                          child: const Text('Batal'),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deletePengembalian(String kodePengembalian) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Text("Apakah Anda ingin menghapus pengembalian $kodePengembalian?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
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
              child: const Text("Batal"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final response = await http.delete(
                  Uri.parse(
                      'http://localhost/uasml/api/pengembalian?id=$kodePengembalian'),
                );

                if (response.statusCode == 200) {
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  setState(() {
                    daftarPengembalian.removeWhere((pengembalian) =>
                        pengembalian['kode_pengembalian'] == kodePengembalian);
                  });

                  fetchData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
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
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  void editPengembalian(String kodePengembalian) {
    showDialog(
      context: context,
      builder: (context) {
        final member = daftarPengembalian.firstWhere(
            (pengembalian) => pengembalian['kode_pengembalian'] == kodePengembalian);
        final TextEditingController tglKembaliController =
            TextEditingController(text: member['tgl_kembali']);
        final TextEditingController kodePinjamanController =
            TextEditingController(text: member['kode_pinjaman']);
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // buat lebar penuh
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 40.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Edit pengembalian $kodePengembalian',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tglKembaliController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tgl Kembali",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kodePinjamanController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Kode Pinjaman",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
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
                          child: const Text('Batal'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Cek apakah ada field yang kosong
                            if (tglKembaliController.text.isEmpty ||
                                kodePinjamanController.text.isEmpty ) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Peringatan'),
                                    content: const Text(
                                        'Tidak boleh ada data yang kosong'),
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
                              return; // Menghentikan eksekusi jika ada field kosong
                            }
                            var response = await http.post(
                                Uri.parse(
                                    "http://localhost/uasml/api/pengembalian?id=$kodePengembalian"),
                                body: {
                                  "tgl_kembali": tglKembaliController.text,
                                  "kode_pinjaman": kodePinjamanController.text,
                                });
                            if (response.statusCode == 200) {
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Data pengembalian berhasil diubah'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              fetchData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Sepertinya ada kesalahan server, harap tunggu bentar dan dicoba lagi yak'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
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
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
            const Row(
              children: [
                Text(
                  'History Pengembalian',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : daftarPengembalian.isEmpty
                      ? const Center(child: Text('Tidak ada data tersedia'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                            },
                            children: [
                              // Header Tabel
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.blue),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Tgl Kembali',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kode Pengembalian',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kode Pinjam',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Aksi',
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),

                              ...daftarPengembalian.map((pengembalian) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pengembalian['tgl_kembali']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pengembalian['kode_pengembalian']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pengembalian['kode_pinjaman']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info,
                                              color: Colors.amber),
                                          onPressed: () => detailPengembalian(
                                              pengembalian['kode_pengembalian']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () => editPengembalian(
                                              pengembalian['kode_pengembalian']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => deletePengembalian(
                                              pengembalian['kode_pengembalian']!),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

