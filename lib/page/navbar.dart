import 'package:flutter/material.dart';
import 'package:project_sarpras11/page/home.dart';
import 'package:project_sarpras11/page/peminjaman.dart';
import 'package:project_sarpras11/page/pengembalian.dart';
import 'package:project_sarpras11/page/riwayat.dart';

class Navbar extends StatefulWidget {
  
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      PeminjamanPage(),
      // PengembalianPage(), 
      const RiwayatPeminjaman(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _selectedIndex == 0
    ? PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
    child: AppBar(
    title: const Text(
      "SISTEM INFORMASI\nSARANA PRASARANA",
      textAlign: TextAlign.left,
      style: TextStyle( fontFamily: 'Arial', fontWeight: FontWeight.bold, fontSize: 18),
    ),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
       actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu),
              onSelected: (String value) {
                if (value == 'logout') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Yakin anda ingin logout?'),
                        actions: [
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () {
                              Navigator.of(context).pop(); 
                            },
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              Navigator.of(context).pop(); 
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],

      )
    )
    : null,

    body: _pages[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF2C3E50),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Peminjaman'),
        // BottomNavigationBarItem(icon: Icon(Icons.assignment_return), label: 'Pengembalian'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      ],
    ),
  );
}

}
