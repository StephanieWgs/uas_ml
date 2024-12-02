import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Pengembalian extends StatefulWidget {
  const Pengembalian({super.key});

  @override
  _PengembalianState createState() => _PengembalianState();
}

class _PengembalianState extends State<Pengembalian> {
  List<Map<String, String>> daftarPinjaman = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost/uasml/api/pinjaman?status=dipinjam'));
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          daftarPinjaman =
              List<Map<String, String>>.from(responseData['data'].map((item) {
            return {
              'tgl_pinjam': item['tgl_pinjam'].toString(),
              'kode_pinjaman': item['kode_pinjaman'].toString(),
              'id_member': item['id_member'].toString(),
              'kode_buku': item['kode_buku'].toString(),
            };
          }).toList());
          isLoading = false;
        });
      } else {
        setState(() {
          daftarPinjaman = [];
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

  void updateStatus(String kodePinjaman) async {
    var response = await http.post(
      Uri.parse('http://localhost/uasml/api/pinjaman?id=$kodePinjaman'),
      body: {'status': 'kembali'},
    );
    if (response.statusCode == 200) {
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pinjaman $kodePinjaman telah dikembalikan'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        daftarPinjaman.removeWhere(
            (pinjaman) => pinjaman['kode_pinjaman'] == kodePinjaman);
      });
      fetchData();
    }
  }

  void bukuKembali(String kodePinjaman) {
    final pinjaman = daftarPinjaman
        .firstWhere((pinjaman) => pinjaman['kode_pinjaman'] == kodePinjaman);
    final TextEditingController kodeBukuC =
        TextEditingController(text: pinjaman['kode_buku']);
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController tglKembaliController =
            TextEditingController();

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
              tglKembaliController.text = pickedDate.toString().split(" ")[0];
            });
          }
        }

        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 40.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Buku Kembali',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tglKembaliController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Tgl Kembali",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
                      ),
                      onTap: () {
                        _selectDate();
                      },
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
                            if (tglKembaliController.text.isEmpty) {
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
                              return;
                            }
                            var response = await http.post(
                                Uri.parse(
                                    "http://localhost/uasml/api/pengembalian"),
                                body: {
                                  'kode_pinjaman': kodePinjaman,
                                  "tgl_kembali": tglKembaliController.text,
                                });

                            var updateStok = await http.post(
                                Uri.parse(
                                    "http://localhost/uasml/api/buku?id=${kodeBukuC.text}"),
                                body: {
                                  "action": "kembali",
                                });

                            if (response.statusCode == 200 &&
                                updateStok.statusCode == 200) {
                              updateStatus(kodePinjaman);
                              // print('Response status: ${response.statusCode}');
                              // print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Data pengembalian berhasil ditambah'),
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
                          child: const Text('Buku Kembali'),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'List Pinjaman Berjalan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : daftarPinjaman.isEmpty
                      ? const Center(child: Text('Tidak ada data tersedia'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.8),
                              1: FlexColumnWidth(1.0),
                              3: FlexColumnWidth(1.2),
                              4: FlexColumnWidth(1.0),
                              5: FlexColumnWidth(),
                            },
                            children: [
                              // Header Tabel
                              const TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.blueAccent),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Tgl Pinjam',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Kode Pinjaman',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'NIM',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Kode Buku',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Aksi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),

                              ...daftarPinjaman.map((pinjaman) {
                                return TableRow(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    color: Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['tgl_pinjam']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['kode_pinjaman']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['id_member']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['kode_buku']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons
                                                .swap_horizontal_circle_outlined,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            bukuKembali(
                                                pinjaman['kode_pinjaman']!);
                                          },
                                        )
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
