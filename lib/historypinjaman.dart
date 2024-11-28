import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryPinjaman extends StatefulWidget {
  const HistoryPinjaman({super.key});

  @override
  _HistoryPinjamanState createState() => _HistoryPinjamanState();
}

class _HistoryPinjamanState extends State<HistoryPinjaman> {
  List<Map<String, String>> daftarPinjaman = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/uasml/api/pinjaman'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
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
              'status': item['status'].toString(),
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

  //detail
  void detailPinjaman(String kodePinjaman) async {
    showDialog(
      context: context,
      builder: (context) {
        final member = daftarPinjaman.firstWhere(
            (pinjaman) => pinjaman['kode_pinjaman'] == kodePinjaman);
        final TextEditingController tglPinjamController =
            TextEditingController(text: member['tgl_pinjam']);
        final TextEditingController idMemberController =
            TextEditingController(text: member['id_member']);
        final TextEditingController kodeBukuController =
            TextEditingController(text: member['kode_buku']);
        final TextEditingController statusController =
            TextEditingController(text: member['status']);
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
                      'Detail Pinjaman $kodePinjaman',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tglPinjamController,
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tgl Pinjam",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: idMemberController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "ID Member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kodeBukuController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Kode Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: statusController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Status Pinjaman",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info, color: Colors.blue),
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

  void deletePinjaman(String kodePinjaman) {
    final pinjaman = daftarPinjaman
        .firstWhere((pinjaman) => pinjaman['kode_pinjaman'] == kodePinjaman);
    final TextEditingController kodeBukuC =
        TextEditingController(text: pinjaman['kode_buku']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Text("Apakah Anda ingin menghapus pinjaman $kodePinjaman?"),
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
                      'http://localhost/uasml/api/pinjaman?id=$kodePinjaman'),
                );

                var updateStok = await http.post(
                    Uri.parse(
                        "http://localhost/uasml/api/buku?id=${kodeBukuC.text}"),
                    body: {
                      "action": "kembali",
                    });

                if (response.statusCode == 200 &&
                    updateStok.statusCode == 200) {
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  setState(() {
                    daftarPinjaman.removeWhere((pinjaman) =>
                        pinjaman['kode_pinjaman'] == kodePinjaman);
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

  void editPinjaman(String kodePinjaman) {
    showDialog(
      context: context,
      builder: (context) {
        final pinjaman = daftarPinjaman.firstWhere(
            (pinjaman) => pinjaman['kode_pinjaman'] == kodePinjaman);
        final TextEditingController tglPinjamController =
            TextEditingController(text: pinjaman['tgl_pinjam']);
        final TextEditingController idMemberController =
            TextEditingController(text: pinjaman['id_member']);
        final TextEditingController kodeBukuController =
            TextEditingController(text: pinjaman['kode_buku']);
        final TextEditingController statusController =
            TextEditingController(text: pinjaman['status']);

        Future<void> _selectDate() async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            setState(() {
              tglPinjamController.text = pickedDate.toString().split(" ")[0];
            });
          }
        }

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
                      'Edit Pinjaman $kodePinjaman',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tglPinjamController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tgl Pinjam",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.date_range, color: Colors.blue),
                      ),
                      onTap: () {
                        _selectDate();
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: idMemberController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "ID Member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kodeBukuController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Kode Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: statusController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Status Pinjaman",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info, color: Colors.blue),
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
                            if (tglPinjamController.text.isEmpty ||
                                idMemberController.text.isEmpty ||
                                kodeBukuController.text.isEmpty ||
                                statusController.text.isEmpty) {
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
                                    "http://localhost/uasml/api/pinjaman?id=$kodePinjaman"),
                                body: {
                                  "tgl_pinjam": tglPinjamController.text,
                                  "id_member": idMemberController.text,
                                  "kode_buku": kodeBukuController.text,
                                  "status": statusController.text,
                                });
                            if (response.statusCode == 200) {
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Data pinjaman berhasil diubah'),
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
                  'History Pinjaman',
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
                              2: FlexColumnWidth(2.0),
                              3: FlexColumnWidth(2.0),
                              4: FlexColumnWidth(1.2),
                              5: FlexColumnWidth(),
                            },
                            children: [
                              // Header Tabel
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.blue),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Tgl Pinjam',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kode',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('ID Member',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kode Buku',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Status',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Aksi',
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),

                              ...daftarPinjaman.map((pinjaman) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['tgl_pinjam']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['kode_pinjaman']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['id_member']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['kode_buku']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(pinjaman['status']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info,
                                              color: Colors.amber),
                                          onPressed: () => detailPinjaman(
                                              pinjaman['kode_pinjaman']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () => editPinjaman(
                                              pinjaman['kode_pinjaman']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => deletePinjaman(
                                              pinjaman['kode_pinjaman']!),
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
