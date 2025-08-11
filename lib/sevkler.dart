import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_helper.dart';
import 'ip_input_page.dart';

class SevklerSayfasi extends StatefulWidget {
  @override
  _SevklerSayfasiState createState() => _SevklerSayfasiState();
}

class _SevklerSayfasiState extends State<SevklerSayfasi> {
  List<dynamic> sevkler = [];
  bool loading = false;
  Map<String, String> depotNames = {}; // Cache for depot names

  // Green theme colors
  final Color primaryGreen = Color(0xFF2E7D32);
  final Color lightGreen = Color(0xFF4CAF50);
  final Color darkGreen = Color(0xFF1B5E20);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    fetchSevkler();
    fetchDepotNames();
  }

  Future<void> fetchDepotNames() async {
    if (!mounted) return;
    try {
      final uri = await ApiHelper.buildUri('/api/depolar');
      final response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        final List data = json.decode(response.body);
        setState(() {
          for (var depot in data) {
            depotNames[depot['dep_no'].toString()] =
                depot['dep_adi'] ?? 'Bilinmiyor';
          }
        });
      }
    } catch (e) {
      print('Depot names fetch error: $e');
    }
  }

  Future<void> fetchSevkler() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final uri = await ApiHelper.buildUri('/api/sevkler');
      final response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        final List data = json.decode(response.body);
        setState(() {
          sevkler = data;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevkler yüklenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sunucuya bağlanılamıyor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> sevkSil(String evrakno) async {
    if (!mounted) return;
    try {
      final uri = await ApiHelper.buildUri('/api/sevkler/$evrakno');
      final response = await http.delete(uri);
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevk silindi'),
            backgroundColor: primaryGreen,
          ),
        );
        fetchSevkler();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevk silinirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sunucuya bağlanılamıyor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> sevkGuncelle(
    String evrakno,
    double miktar,
    double birimFiyat,
    String aciklama,
  ) async {
    if (!mounted) return;
    try {
      final uri = await ApiHelper.buildUri('/api/sevkler/$evrakno');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'miktar': miktar,
          'birim_fiyat': birimFiyat,
          'aciklama': aciklama,
        }),
      );
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevk güncellendi'),
            backgroundColor: primaryGreen,
          ),
        );
        fetchSevkler();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sevk güncellenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sunucuya bağlanılamıyor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSevkDetayModal(Map<String, dynamic> sevk) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height;

        return Container(
          height: height * 0.95,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sevk Detayı',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Stok Adı',
                          sevk['urun_ad'] ?? 'Bilinmiyor',
                        ),
                        _buildDetailRow(
                          'Stok ID',
                          sevk['urun_kod']?.toString() ?? '',
                        ),
                        _buildDetailRow(
                          'Evrak No',
                          sevk['evrakno']?.toString() ?? '',
                        ),
                        _buildDetailRow(
                          'Gönderen Depo',
                          _getDepotName(
                            sevk['gonderen_depo']?.toString() ?? '',
                          ),
                        ),
                        _buildDetailRow(
                          'Alıcı Depo',
                          _getDepotName(sevk['alici_depo']?.toString() ?? ''),
                        ),
                        _buildDetailRow(
                          'Miktar',
                          sevk['miktar']?.toString() ?? '',
                        ),
                        _buildDetailRow(
                          'Birim Fiyat',
                          sevk['birim_fiyat']?.toString() ?? '',
                        ),
                        _buildDetailRow(
                          'Tarih',
                          sevk['tarih']?.toString() ?? '',
                        ),
                        if (sevk['aciklama'] != null &&
                            sevk['aciklama'].toString().isNotEmpty)
                          _buildDetailRow(
                            'Açıklama',
                            sevk['aciklama']?.toString() ?? '',
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDepotName(String depotNo) {
    if (depotNo.isEmpty) return '';
    return depotNames[depotNo] ?? 'Depo $depotNo';
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: value.isNotEmpty ? Colors.blue[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: value.isNotEmpty ? Colors.blue[700] : Colors.grey[600],
                  fontWeight: value.isNotEmpty
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuncelleDialog(Map<String, dynamic> sevk) {
    final _miktarController = TextEditingController(
      text: sevk['miktar'].toString(),
    );
    final _birimFiyatController = TextEditingController(
      text: sevk['birim_fiyat'].toString(),
    );
    final _aciklamaController = TextEditingController(
      text: sevk['aciklama'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: primaryGreen),
            SizedBox(width: 8),
            Text('Sevk Güncelle'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _miktarController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Miktar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.scale, color: primaryGreen),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _birimFiyatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Birim Fiyat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.attach_money, color: primaryGreen),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _aciklamaController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.description, color: primaryGreen),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final miktar = double.tryParse(_miktarController.text);
              final birimFiyat = double.tryParse(_birimFiyatController.text);
              final aciklama = _aciklamaController.text;

              if (miktar == null || birimFiyat == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lütfen geçerli değerler girin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              sevkGuncelle(sevk['evrakno'], miktar, birimFiyat, aciklama);
              Navigator.pop(context);
            },
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        title: Text('Sevkler'),
        toolbarHeight: 120,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchSevkler),
          IconButton(
            onPressed:(){
              ApiHelper.resetIp();
              Navigator.push(context, MaterialPageRoute(builder: (context) => IpInputPage()));
              },
            icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : sevkler.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sevk bulunamadı',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sevkler.length,
              itemBuilder: (context, index) {
                final sevk = sevkler[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.inventory, color: primaryGreen),
                    title: Text(
                      '${sevk['urun_ad']} (${sevk['urun_kod']})',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evrak No: ${sevk['evrakno']}'),
                        Text(
                          'Gönderen Depo: ${_getDepotName(sevk['gonderen_depo']?.toString() ?? '')}',
                        ),
                        Text(
                          'Alıcı Depo: ${_getDepotName(sevk['alici_depo']?.toString() ?? '')}',
                        ),
                        Text('Miktar: ${sevk['miktar']}'),
                        Text('Birim Fiyat: ${sevk['birim_fiyat']}'),
                        Text('Tarih: ${sevk['tarih']}'),
                        if (sevk['aciklama'] != null &&
                            sevk['aciklama'].toString().isNotEmpty)
                          Text('Açıklama: ${sevk['aciklama']}'),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _showSevkDetayModal(sevk),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Güncelle',
                          onPressed: () => _showGuncelleDialog(sevk),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Sil',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Sevk Silme'),
                                  ],
                                ),
                                content: Text(
                                  'Emin misiniz? Seçili sevk silinecek.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('İptal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      sevkSil(sevk['evrakno']);
                                    },
                                    child: Text('Sil'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
