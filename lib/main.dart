import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ip_input_page.dart';
import 'sevkler.dart';
import 'sevk_ekle_sayfasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String?> _getSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_ip');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depolar Arası Sevk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF2E7D32),
      ),
      routes: {
        '/home': (_) => AnaSayfa(),
        '/ip': (_) => IpInputPage(),
      },
      home: FutureBuilder<String?>(
        future: _getSavedIp(),
        builder: (context, snapshot) {
          print('FutureBuilder state: ${snapshot.connectionState}, data: ${snapshot.data}, error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Hata: ${snapshot.error}')));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return IpInputPage();
          }
          return AnaSayfa();
        },
      ),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _selectedIndex = 0;
  
  // Green theme colors
  final Color primaryGreen = Color(0xFF2E7D32);
  final Color lightGreen = Color(0xFF4CAF50);
  final Color backgroundColor = Color(0xFFF5F5F5);

  static final List<Widget> _pages = [
    SevklerSayfasi(),
    SevkEkleSayfasi(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Sevkler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Sevk Ekle',
            ),
          ],
        ),
      ),
    );
  }
}
