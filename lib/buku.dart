import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Buku extends StatefulWidget {
  const Buku({super.key});

  @override
  _BukuState createState() => _BukuState();
}

class _BukuState extends State<Buku> {
  List<Map<String, String>> daftarBuku = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fungsi untuk mengambil data buku
  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/uasml/api/buku'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          daftarBuku =
              List<Map<String, String>>.from(responseData['data'].map((item) {
            return {
              'kode_buku': item['kode_buku'].toString(),
              'judul': item['judul'].toString(),
              'penulis': item['penulis'].toString(),
              'penerbit': item['penerbit'].toString(),
              'kategori': item['kategori'].toString(),
              'tahun': item['tahun'].toString(),
              'stok': item['stok'].toString(),
            };
          }).toList());
          isLoading = false;
        });
      } else {
        setState(() {
          daftarBuku = [];
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

  //Hapus Buku
  void deleteBuku(String kodeBuku) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content:
              Text("Apakah Anda ingin menghapus buku dengan kode $kodeBuku?"),
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
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Proses penghapusan member
                final response = await http.delete(
                  Uri.parse('http://localhost/uasml/api/buku?id=$kodeBuku'),
                );

                if (response.statusCode == 200) {
                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');

                  // Update daftar member setelah penghapusan
                  setState(() {
                    daftarBuku
                        .removeWhere((buku) => buku['kode_buku'] == kodeBuku);
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

  // Fungsi untuk tambah buku
  void tambahBuku() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController judulController = TextEditingController();
        final TextEditingController penulisController = TextEditingController();
        final TextEditingController penerbitController =
            TextEditingController();
        final TextEditingController kategoriController =
            TextEditingController();
        final TextEditingController tahunController = TextEditingController();
        final TextEditingController stokController = TextEditingController();

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
                      'Tambah Buku',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: judulController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Judul Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penulisController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Penulis Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penerbitController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Penerbit Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.print, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kategoriController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Kategori Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.menu_open_outlined, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tahunController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tahun Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.calendar_month, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Stok",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.library_books_rounded,
                            color: Colors.blue),
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
                            if (judulController.text.isEmpty ||
                                penulisController.text.isEmpty ||
                                penerbitController.text.isEmpty ||
                                kategoriController.text.isEmpty ||
                                tahunController.text.isEmpty ||
                                stokController.text.isEmpty) {
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
                                Uri.parse("http://localhost/uasml/api/buku"),
                                body: {
                                  "judul": judulController.text,
                                  "penulis": penulisController.text,
                                  "penerbit": penerbitController.text,
                                  "kategori": kategoriController.text,
                                  "tahun": tahunController.text,
                                  "stok": stokController.text
                                });
                            if (response.statusCode == 200) {
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data buku berhasil ditambah'),
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

  void detailBuku(String kodeBuku) {
    showDialog(
      context: context,
      builder: (context) {
        final buku =
            daftarBuku.firstWhere((buku) => buku['kode_buku'] == kodeBuku);
        final TextEditingController judulController =
            TextEditingController(text: buku['judul']);
        final TextEditingController penulisController =
            TextEditingController(text: buku['penulis']);
        final TextEditingController penerbitController =
            TextEditingController(text: buku['penerbit']);
        final TextEditingController kategoriController =
            TextEditingController(text: buku['kategori']);
        final TextEditingController tahunController =
            TextEditingController(text: buku['tahun']);
        final TextEditingController stokController =
            TextEditingController(text: buku['stok']);

        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // buat lebar penuh
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 40.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Detail Buku',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: judulController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Judul Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penulisController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Penulis Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penerbitController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Penerbit Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.print, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kategoriController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Kategori Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.menu_open_outlined, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tahunController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Tahun Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.calendar_month, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Stok",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.library_books_rounded,
                            color: Colors.blue),
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
                          child: const Text('Tutup'),
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

  // Fungsi untuk mengedit buku
  void editBuku(String kodeBuku) {
    showDialog(
      context: context,
      builder: (context) {
        final buku =
            daftarBuku.firstWhere((buku) => buku['kode_buku'] == kodeBuku);
        final TextEditingController judulController =
            TextEditingController(text: buku['judul']);
        final TextEditingController penulisController =
            TextEditingController(text: buku['penulis']);
        final TextEditingController penerbitController =
            TextEditingController(text: buku['penerbit']);
        final TextEditingController kategoriController =
            TextEditingController(text: buku['kategori']);
        final TextEditingController tahunController =
            TextEditingController(text: buku['tahun']);
        final TextEditingController stokController =
            TextEditingController(text: buku['stok']);

        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // buat lebar penuh
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 40.0, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Edit Buku',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: judulController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Judul Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penulisController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Penulis Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: penerbitController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Penerbit Buku",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.print, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: kategoriController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Kategori Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.menu_open_outlined, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tahunController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Tahun Buku",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.calendar_month, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Stok",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.library_books_rounded,
                            color: Colors.blue),
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
                            if (judulController.text.isEmpty ||
                                penulisController.text.isEmpty ||
                                penerbitController.text.isEmpty ||
                                kategoriController.text.isEmpty ||
                                tahunController.text.isEmpty ||
                                stokController.text.isEmpty) {
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
                                    "http://localhost/uasml/api/buku?id=$kodeBuku"),
                                body: {
                                  "judul": judulController.text,
                                  "penulis": penulisController.text,
                                  "penerbit": penerbitController.text,
                                  "kategori": kategoriController.text,
                                  "tahun": tahunController.text,
                                  "stok": stokController.text
                                });
                            if (response.statusCode == 200) {
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data buku berhasil diubah'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Buku',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    tambahBuku();
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
                  child: const Text('Tambah Buku'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabel Daftar Buku
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : daftarBuku.isEmpty
                      ? const Center(child: Text('Tidak ada data tersedia'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(80.0),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                              4: FlexColumnWidth(),
                              5: FlexColumnWidth(),
                              6: FlexColumnWidth(),
                              7: FixedColumnWidth(150.0),
                            },
                            children: [
                              // Header Tabel
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.blue),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kode',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Judul',
                                        textAlign: TextAlign.start),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Penulis',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Penerbit',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kategori',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Tahun',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Stok',
                                        textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Aksi',
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                              // Data Buku
                              ...daftarBuku.map((buku) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['kode_buku']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['judul']!,
                                          textAlign: TextAlign.start),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['penulis']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['penerbit']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['kategori']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['tahun']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(buku['stok']!,
                                          textAlign: TextAlign.center),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.info,
                                              color: Colors.amber),
                                          onPressed: () =>
                                              detailBuku(buku['kode_buku']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () =>
                                              editBuku(buku['kode_buku']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              deleteBuku(buku['kode_buku']!),
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
