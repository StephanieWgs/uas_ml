import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Member extends StatefulWidget {
  const Member({super.key});

  @override
  _MemberState createState() => _MemberState();
}

class _MemberState extends State<Member> {
  List<Map<String, String>> daftarMember = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fungsi untuk mengambil data member
  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/uasml/api/member'));
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          daftarMember =
              List<Map<String, String>>.from(responseData['data'].map((item) {
            return {
              'id_member': item['id_member'].toString(),
              'nama': item['nama'].toString(),
              'alamat': item['alamat'].toString(),
              'email': item['email'].toString(),
              'no_hp': item['no_hp'].toString(),
            };
          }).toList());
          isLoading = false;
        });
      } else {
        setState(() {
          daftarMember = [];
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
  void detailMember(String kodemember) async {
    showDialog(
      context: context,
      builder: (context) {
        final member = daftarMember
            .firstWhere((member) => member['id_member'] == kodemember);
        final TextEditingController namaController =
            TextEditingController(text: member['nama']);
        final TextEditingController alamatController =
            TextEditingController(text: member['alamat']);
        final TextEditingController emailController =
            TextEditingController(text: member['email']);
        final TextEditingController noHpController =
            TextEditingController(text: member['no_hp']);
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
                      'Detail Member $kodemember',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: namaController,
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Nama member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: alamatController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Alamat member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Email member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noHpController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "No HP member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
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

  //Hapus member
  void deleteMember(String kodemember) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Text(
              "Apakah Anda ingin menghapus member dengan NIM $kodemember?"),
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

                // Proses penghapusan member
                final response = await http.delete(
                  Uri.parse('http://localhost/uasml/api/member?id=$kodemember'),
                );

                if (response.statusCode == 200) {
                  // print('Response status: ${response.statusCode}');
                  // print('Response body: ${response.body}');

                  // Update daftar member setelah penghapusan
                  setState(() {
                    daftarMember.removeWhere(
                        (member) => member['id_member'] == kodemember);
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

  // Fungsi untuk tambah member
  void tambahmember() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController idMemberController =
            TextEditingController();
        final TextEditingController namaController = TextEditingController();
        final TextEditingController alamatController = TextEditingController();
        final TextEditingController emailController = TextEditingController();
        final TextEditingController noHpController = TextEditingController();

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
                      'Tambah Member',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: idMemberController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "ID member",
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.card_membership, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: namaController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Nama member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: alamatController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Alamat member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Email member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noHpController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "No Hp member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
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
                            if (idMemberController.text.isEmpty ||
                                namaController.text.isEmpty ||
                                alamatController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                noHpController.text.isEmpty) {
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
                                Uri.parse("http://localhost/uasml/api/member"),
                                body: {
                                  "id_member": idMemberController.text,
                                  "nama": namaController.text,
                                  "alamat": alamatController.text,
                                  "email": emailController.text,
                                  "no_hp": noHpController.text,
                                });
                            if (response.statusCode == 200) {
                              // print('Response status: ${response.statusCode}');
                              // print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Data member berhasil ditambah'),
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
                          child: const Text('Tambah'),
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

  // Fungsi untuk mengedit member
  void editMember(String kodemember) {
    showDialog(
      context: context,
      builder: (context) {
        final member = daftarMember
            .firstWhere((member) => member['id_member'] == kodemember);
        final TextEditingController namaController =
            TextEditingController(text: member['nama']);
        final TextEditingController alamatController =
            TextEditingController(text: member['alamat']);
        final TextEditingController emailController =
            TextEditingController(text: member['email']);
        final TextEditingController noHpController =
            TextEditingController(text: member['no_hp']);
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
                      'Edit Member $kodemember',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: namaController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Nama member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: alamatController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Alamat member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "Email member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: noHpController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: "No HP member",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
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
                            if (namaController.text.isEmpty ||
                                alamatController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                noHpController.text.isEmpty) {
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
                                    "http://localhost/uasml/api/member?id=$kodemember"),
                                body: {
                                  "nama": namaController.text,
                                  "alamat": alamatController.text,
                                  "email": emailController.text,
                                  "no_hp": noHpController.text,
                                });
                            if (response.statusCode == 200) {
                              // print('Response status: ${response.statusCode}');
                              // print('Response body: ${response.body}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Data member berhasil diubah'),
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
                  'Daftar member',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    tambahmember();
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
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabel Daftar member
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : daftarMember.isEmpty
                      ? const Center(child: Text('Tidak ada data tersedia'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.8),
                              1: FlexColumnWidth(1.0),
                              2: FlexColumnWidth(2.0),
                              3: FlexColumnWidth(1.2),
                              4: FlexColumnWidth(),
                            },
                            children: [
                              // Header Tabel
                              const TableRow(
                                decoration: BoxDecoration(color: Colors.blue),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'ID',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Nama',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Email',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'NO HP',
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
                              // Data member
                              ...daftarMember.map((member) {
                                return TableRow(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    color: Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(member['id_member']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(member['nama']!,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(member['email']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(member['no_hp']!,
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
                                          icon: const Icon(Icons.info,
                                              color: Colors.amber),
                                          onPressed: () => detailMember(
                                              member['id_member']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () =>
                                              editMember(member['id_member']!),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => deleteMember(
                                              member['id_member']!),
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
