import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_activity_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String selectedKategori = "Semua";
  String selectedStatus = "Semua";
  String searchQuery = "";
  final searchController = TextEditingController();
  
  late Stream<QuerySnapshot> _activitiesStream;

  final List<String> daftarKategori = [
    "Semua",
    "Tugas",
    "Praktikum",
    "Proyek",
    "Presentasi",
    "Seminar",
    "Organisasi",
    "Lainnya"
  ];

  final List<String> daftarStatus = [
    "Semua",
    "Belum Dimulai",
    "Sedang Dikerjakan",
    "Revisi",
    "Selesai"
  ];

  @override
  void initState() {
    super.initState();
    _activitiesStream = FirebaseFirestore.instance
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool _cekApakahTerlambat(String deadlineStr, String statusStr) {
    if (statusStr.toLowerCase() == 'selesai') return false;
    
    try {
      final parts = deadlineStr.split('/');
      if (parts.length == 3) {
        final dateDeadline = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final sekarang = DateTime.now();
        final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
        
        return dateDeadline.isBefore(hariIni);
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Daftar Aktivitas",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _activitiesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Terjadi Kesalahan"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          final allData = snapshot.data!.docs;

          final filteredData = allData.where((doc) {
            final cocokKategori = selectedKategori == "Semua" ||
                (doc['kategori'] ?? '').toString().toLowerCase() ==
                    selectedKategori.toLowerCase();

            final cocokStatus = selectedStatus == "Semua" ||
                (doc['status'] ?? '').toString().toLowerCase() ==
                    selectedStatus.toLowerCase();

            return cocokKategori && cocokStatus;
          }).toList();

          final data = filteredData.where((doc) {
            final judul = (doc['judul'] ?? '').toString().toLowerCase();
            return judul.contains(searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Cari aktivitas...",
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedKategori,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Kategori",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: daftarKategori.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedKategori = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Status",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: daftarStatus.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.shade100.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${data.length}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Total Aktivitas Ditemukan",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              "Tidak ada aktivitas ditemukan",
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var activity = data[index];
                          String statusStr = (activity['status'] ?? '').toString().toLowerCase();
                          String deadlineStr = (activity['deadline'] ?? '-').toString();

                          bool lewatDeadline = _cekApakahTerlambat(deadlineStr, statusStr);

                          Color warna = Colors.blue;
                          if (statusStr == "selesai") {
                            warna = Colors.green;
                          } else if (statusStr == "revisi") {
                            warna = Colors.orange;
                          } else if (statusStr == "belum dimulai") {
                            warna = Colors.grey.shade600;
                          } else if (statusStr == "sedang dikerjakan") {
                            warna = Colors.blue;
                          } else if (statusStr == "gagal" || statusStr == "terlambat") {
                            warna = Colors.red;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: lewatDeadline ? Colors.red.shade300 : Colors.grey.shade200,
                                width: lewatDeadline ? 1.5 : 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: lewatDeadline ? Colors.red.shade50 : Colors.indigo.shade50,
                                        child: Icon(
                                          Icons.assignment_outlined,
                                          color: lewatDeadline ? Colors.red.shade700 : Colors.indigo,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activity['judul'] ?? 'Tanpa Judul',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              activity['mataKuliah'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) async {
                                          if (value == "edit") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditActivityScreen(
                                                  docId: activity.id,
                                                  judul: activity['judul'] ?? '',
                                                  mataKuliah: activity['mataKuliah'] ?? '',
                                                  kategori: activity['kategori'] ?? '',
                                                  status: activity['status'] ?? '',
                                                  deadline: activity['deadline'] ?? '',
                                                  catatan: activity['catatan'] ?? '',
                                                ),
                                              ),
                                            );
                                          } else if (value == "hapus") {
                                            bool? konfirmasi = await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("Hapus Aktivitas"),
                                                  content: const Text("Yakin ingin menghapus aktivitas ini?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text("Batal"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text("Hapus"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (konfirmasi == true) {
                                              await FirebaseFirestore.instance
                                                  .collection('activities')
                                                  .doc(activity.id)
                                                  .delete();
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: "edit",
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 20),
                                                SizedBox(width: 10),
                                                Text("Edit"),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: "hapus",
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Hapus",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.layers_outlined, size: 14, color: Colors.indigo),
                                                const SizedBox(width: 4),
                                                Text(
                                                  activity['kategori'] ?? 'Umum',
                                                  style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: lewatDeadline ? Colors.red.shade700 : Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.alarm, size: 14, color: lewatDeadline ? Colors.white : Colors.red),
                                                const SizedBox(width: 4),
                                                Text(
                                                  deadlineStr,
                                                  style: TextStyle(
                                                    fontSize: 11, 
                                                    color: lewatDeadline ? Colors.white : Colors.red, 
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: warna.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          activity['status'] ?? 'Belum Dimulai',
                                          style: TextStyle(
                                            color: warna,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (activity['catatan'] != null &&
                                      activity['catatan'].toString().trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(height: 1, thickness: 0.5),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        activity['catatan'],
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}