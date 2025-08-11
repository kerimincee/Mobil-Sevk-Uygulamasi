import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'api_helper.dart';

class SevkEkleSayfasi extends StatefulWidget {
  @override
  _SevkEkleSayfasiState createState() => _SevkEkleSayfasiState();
}

class _SevkEkleSayfasiState extends State<SevkEkleSayfasi> {
  final _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController belgeNoController = TextEditingController();
  final TextEditingController miktarController = TextEditingController();
  final TextEditingController birimFiyatController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();
  final TextEditingController barkodController = TextEditingController();

  Map<String, dynamic>? seciliGonderenDepo;
  Map<String, dynamic>? seciliAliciDepo;
  Map<String, dynamic>? seciliUrun;

  List<Map<String, dynamic>> depolar = [];
  List<Map<String, dynamic>> urunler = [];

  List<Map<String, dynamic>> secilenUrunler = [];

  bool loadingDepolar = false;
  bool loadingUrunler = false;

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
    fetchDepolar();
  }

  @override
  void dispose() {
    belgeNoController.dispose();
    miktarController.dispose();
    birimFiyatController.dispose();
    aciklamaController.dispose();
    barkodController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchDepolar() async {
    if (!mounted) return;
    setState(() => loadingDepolar = true);
    try {
      final uri = await ApiHelper.buildUri('/api/depolar');
      var response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        List data = json.decode(response.body);
        setState(() {
          depolar = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Depo fetch error: $e');
    } finally {
      if (mounted) {
        setState(() => loadingDepolar = false);
      }
    }
  }

  Future<void> fetchUrunler(String depoNo) async {
    if (!mounted) return;
    setState(() => loadingUrunler = true);
    try {
      final uri = await ApiHelper.buildUri('/api/urunler', {'depono': depoNo});
      var response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        List data = json.decode(response.body);
        setState(() {
          urunler = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Ürün fetch error: $e');
    } finally {
      if (mounted) {
        setState(() => loadingUrunler = false);
      }
    }
  }

  Future<void> showDepoSecModal({required bool gonderen}) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warehouse, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      gonderen ? 'Gönderen Depo Seç' : 'Alıcı Depo Seç',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: loadingDepolar
                    ? Center(
                        child: CircularProgressIndicator(color: primaryGreen),
                      )
                    : ListView.builder(
                        itemCount: depolar.length,
                        itemBuilder: (context, index) {
                          var depo = depolar[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.warehouse,
                                color: primaryGreen,
                              ),
                              title: Text(
                                depo['dep_adi'] ?? 'Depo Adı',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Depo No: ${depo['dep_no']}'),
                              onTap: () {
                                setState(() {
                                  if (gonderen) {
                                    seciliGonderenDepo = depo;
                                    seciliUrun = null;
                                    urunler.clear();
                                    fetchUrunler(depo['dep_no'].toString());
                                  } else {
                                    seciliAliciDepo = depo;
                                  }
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> showUrunSecModal() async {
  List<Map<String, dynamic>> filteredUrunler = List.from(urunler);
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Başlık ve Arama İkonu
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Ürün Seç',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isSearching ? Icons.close : Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isSearching = !isSearching;
                            if (!isSearching) {
                              searchController.clear();
                              filteredUrunler = List.from(urunler);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Arama Kutusu Animasyonlu
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: isSearching ? 60 : 0,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: isSearching
                      ? TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Ürün ara...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredUrunler = urunler
                                  .where((urun) => (urun['sto_isim'] ?? '')
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        )
                      : null,
                ),

                // Ürün Listesi
                Expanded(
                  child: loadingUrunler
                      ? Center(
                          child: CircularProgressIndicator(color: primaryGreen),
                        )
                      : filteredUrunler.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Sonuç bulunamadı',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredUrunler.length,
                              itemBuilder: (context, index) {
                                var urun = filteredUrunler[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    leading: Icon(Icons.inventory, color: primaryGreen),
                                    title: Text(
                                      urun['sto_isim'] ?? 'Ürün Adı',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text('Ürün Kodu: ${urun['sto_kod']}'),
                                    onTap: () {
                                      setState(() {
                                        seciliUrun = urun;
                                      });
                                      Navigator.pop(context);
                                      showUrunDetayModal();
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
  Future<void> showUrunDetayModal() async {
    miktarController.clear();
    birimFiyatController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          seciliUrun?['sto_isim'] ?? 'Ürün Ekle',
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
                SizedBox(height: 20),
                // Miktar alanı:
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: miktarController,
                        decoration: InputDecoration(
                          labelText: 'Miktar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.scale, color: primaryGreen),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      seciliUrun?['birim_ad'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Birim fiyat alanı eskisi gibi kalsın
                TextField(
                  controller: birimFiyatController,
                  decoration: InputDecoration(
                    labelText: 'Birim Fiyat',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: _getCurrencyIcon(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('İptal'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final miktar = double.tryParse(miktarController.text);
                          final birimFiyat = double.tryParse(
                            birimFiyatController.text,
                          );
                          if (miktar == null || miktar <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Geçerli miktar girin'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (birimFiyat == null || birimFiyat < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Geçerli birim fiyat girin'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);

                          setState(() {
                            secilenUrunler.add({
                              'urun': seciliUrun,
                              'miktar': miktar,
                              'birimFiyat': birimFiyat,
                            });
                            seciliUrun = null;
                            miktarController.clear();
                            birimFiyatController.clear();
                          });
                        },
                        child: Text('Listeye Ekle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> tumunuSevkKaydet() async {
    if (!mounted) return;
    if (belgeNoController.text.isEmpty ||
        int.tryParse(belgeNoController.text) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçerli belge no girin'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (seciliGonderenDepo == null || seciliAliciDepo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderen ve alıcı depo seçin'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (secilenUrunler.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('En az bir ürün ekleyin'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    bool hataVar = false;

    for (var item in secilenUrunler) {
      final urun = item['urun'];
      final miktar = item['miktar'];
      final birimFiyat = item['birimFiyat'];

      final payload = {
        'belge_no': int.parse(belgeNoController.text),
        'gonderen_depo_no': seciliGonderenDepo!['dep_no'],
        'alici_depo_no': seciliAliciDepo!['dep_no'],
        'urun_kod': urun['sto_kod'],
        'miktar': miktar,
        'birim_fiyat': birimFiyat,
        'aciklama': aciklamaController.text,
      };

      try {
        final uri = await ApiHelper.buildUri('/api/sevk_ekle');
        var response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );

        if (response.statusCode != 201) {
          hataVar = true;
          var hata = json.decode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hata: ${hata['error']} (Ürün: ${urun['sto_isim']})',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
        }
      } catch (e) {
        hataVar = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sunucuya bağlanılamıyor (Ürün: ${urun['sto_isim']})',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      }
    }

    if (!hataVar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tüm sevkler başarıyla kaydedildi'),
          backgroundColor: primaryGreen,
        ),
      );
      setState(() {
        secilenUrunler.clear();
        belgeNoController.clear();
        aciklamaController.clear();
        seciliGonderenDepo = null;
        seciliAliciDepo = null;
        seciliUrun = null;
      });
    }
  }

  Future<void> barkodIleUrunGetir(String barkod) async {
    if (!mounted) return;
    try {
      final uri = await ApiHelper.buildUri('/api/stoklar/barkod/$barkod');
      final response = await http.get(uri);
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          seciliUrun = {
            'sto_kod': data['sto_kod'],
            'sto_isim': data['sto_isim'],
            'birim_ad': data['birim_ad'] ?? '',
            'doviz_cinsi': data['doviz_cinsi'],
          };
        });
        if (mounted) {
          showUrunDetayModal();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${data['sto_isim']} ürünü seçildi'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      } else if (mounted) {
        final hata = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${hata['error']}'),
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

  void _showAciklamaModal() {
    final _aciklamaController = TextEditingController(
      text: aciklamaController.text,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
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
                      Icon(Icons.description, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Açıklama Ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _aciklamaController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Sevk açıklamasını buraya yazın...',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('İptal'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            aciklamaController.text = _aciklamaController.text;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 2; i++)
            Container(
              width: 12,
              height: 12,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentPage ? primaryGreen : Colors.grey[300],
              ),
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
        title: Text('Depolar Arası Sevk'),
        toolbarHeight: 120,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final barcode = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => BarkodOkuyucuSayfasi()),
              );
              if (barcode != null) {
                await barkodIleUrunGetir(barcode);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                secilenUrunler.clear();
                belgeNoController.clear();
                aciklamaController.clear();
                seciliGonderenDepo = null;
                seciliAliciDepo = null;
                seciliUrun = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                // 1. Sayfa: Genel Bilgiler
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Detay Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Genel bilgiler',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Form Fields
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildFormField(
                                label: 'Tarih :',
                                value: '28.07.2025',
                                isEditable: false,
                              ),

                              _buildFormField(
                                label: 'Evrak sıra :',
                                value: 'Otomatik',
                                isEditable: false,
                              ),
                              _buildFormField(
                                label: 'Kaynak depo :',
                                value: seciliGonderenDepo?['dep_adi'] ?? '',
                                isEditable: false,
                                onTap: () => showDepoSecModal(gonderen: true),
                              ),
                              _buildFormField(
                                label: 'Hedef depo :',
                                value: seciliAliciDepo?['dep_adi'] ?? '',
                                isEditable: false,
                                onTap: () => showDepoSecModal(gonderen: false),
                              ),

                              _buildFormField(
                                label: 'Belge Tarihi :',
                                value: '28.07.2025',
                                isEditable: false,
                              ),
                              _buildFormField(
                                label: 'Belge no :',
                                controller: belgeNoController,
                                isEditable: true,
                                keyboardType: TextInputType.number,
                              ),
                              _buildFormField(
                                label: 'Firma no :',
                                value: 'BYKOZ LTD. ŞTİ.',
                                isEditable: false,
                              ),
                              _buildFormField(
                                label: 'Şube no :',
                                value: 'ANA MERKEZ',
                                isEditable: false,
                              ),
                              _buildFormField(
                                label: 'Açıklama :',
                                value: aciklamaController.text,
                                isEditable: false,
                                onTap: () => _showAciklamaModal(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Sayfa: Ürünler
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ürün Seçimi
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.inventory, color: primaryGreen),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ürün Seçimi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: showUrunSecModal,
                                icon: Icon(Icons.add),
                                label: Text('Ürün Ekle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Seçilen Ürünler Listesi
                      if (secilenUrunler.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.list, color: primaryGreen),
                                    SizedBox(width: 8),
                                    Text(
                                      'Seçilen Ürünler',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                ...secilenUrunler.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final urun = item['urun'];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                urun['sto_isim'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                              Text(
                                                'Kod: ${urun['sto_kod']}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Miktar: ${item['miktar']} | Birim Fiyat: ${item['birimFiyat']}',
                                                style: TextStyle(
                                                  color: primaryGreen,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              secilenUrunler.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 20),

                      // Kaydet Butonu
                      if (secilenUrunler.isNotEmpty)
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: tumunuSevkKaydet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Sevk Kaydet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    String? value,
    TextEditingController? controller,
    required bool isEditable,
    TextInputType? keyboardType,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditable
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: value?.isNotEmpty == true
                            ? Colors.blue[50]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        value ?? '',
                        style: TextStyle(
                          color: value?.isNotEmpty == true
                              ? Colors.blue[700]
                              : Colors.grey[600],
                          fontWeight: value?.isNotEmpty == true
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Icon _getCurrencyIcon() {
    final cins = seciliUrun?['doviz_cinsi'];
    if (cins == 1)
      return const Icon(Icons.attach_money, color: Colors.green); // $
    if (cins == 2) return const Icon(Icons.euro, color: Colors.blue); // €
    // 0 veya null ise TL
    return const Icon(Icons.currency_lira, color: Colors.orange); // ₺
  }
}

class BarkodOkuyucuSayfasi extends StatefulWidget {
  @override
  _BarkodOkuyucuSayfasiState createState() => _BarkodOkuyucuSayfasiState();
}

class _BarkodOkuyucuSayfasiState extends State<BarkodOkuyucuSayfasi> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final TextEditingController manuelBarkodController = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    manuelBarkodController.dispose();
    super.dispose();
  }

  void barkodSecildi(String code) {
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barkod Oku'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final code = barcodes.first.rawValue ?? '';
                  if (code.isNotEmpty) {
                    barkodSecildi(code);
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: manuelBarkodController,
              decoration: InputDecoration(
                labelText: 'Manuel Barkod Gir',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF2E7D32)),
                  onPressed: () {
                    final kod = manuelBarkodController.text.trim();
                    if (kod.isNotEmpty) {
                      barkodSecildi(kod);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
