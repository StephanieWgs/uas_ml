import 'package:flutter/material.dart';
import 'buku.dart';
import 'pinjaman.dart';
import 'member.dart';
import 'main.dart';
import 'pengembalian.dart';
import 'historypinjaman.dart';
import 'historypengembalian.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 42, 74, 139),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Widget _getBodyContent() {
    switch (_currentIndex) {
      case 0:
        return const Buku();
      case 1:
        return const Pinjaman();
      case 2:
        return const Pengembalian();
      case 3:
        return const Member();
      case 4:
        return const HistoryPinjaman();
      case 5:
        return const HistoryPengembalian();
      default:
        return const Center(child: Text("Halaman Tidak Diketahui"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo2.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              'Cincai Library',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
              ),
              child: const Text(
                "Menu",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.blue.shade800),
              title: const Text("Buku"),
              onTap: () => setState(() {
                _currentIndex = 0;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue.shade800),
              title: const Text("Pinjaman"),
              onTap: () => setState(() {
                _currentIndex = 1;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              leading:
                  Icon(Icons.reset_tv_rounded, color: Colors.blue.shade800),
              title: const Text("Pengembalian"),
              onTap: () => setState(() {
                _currentIndex = 2;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue.shade800),
              title: const Text("Member"),
              onTap: () => setState(() {
                _currentIndex = 3;
                Navigator.pop(context);
              }),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue.shade800),
              title: const Text("History Pinjaman"),
              onTap: () => setState(() {
                _currentIndex = 4;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue.shade800),
              title: const Text("History Pengembalian"),
              onTap: () => setState(() {
                _currentIndex = 5;
                Navigator.pop(context);
              }),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: const Text("Logout"),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                // Hapus data sesi pengguna
                await prefs.remove('kode_pustakawan');

                // Kembali ke halaman login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
            ),
          ],
        ),
      ),
      body: _getBodyContent(), // Update body content based on current index
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey.shade500,
        currentIndex: _currentIndex > 2 ? 0 : _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Buku",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Pinjaman",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reset_tv_rounded),
            label: "Pengembalian",
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
