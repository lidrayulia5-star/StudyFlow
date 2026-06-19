import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<QuerySnapshot> _dashboardStream;
  late String _quoteHariIni;

  final List<String> _daftarQuotes = [
    "Fokus pada prosesnya, hasil akhir nggak akan mengkhianati usahamu. Semangat kuliahnya!",
    "Satu langkah kecil setiap hari bakal membawa kamu ke kelulusan yang gemilang.",
    "Jangan malas hari ini, masa depanmu yang sukses ditentukan dari apa yang kamu kerjakan sekarang.",
    "Bikin bangga orang tua dan dirimu sendiri. Kamu pasti bisa melewati semester ini!",
    "Tugas sesulit apa pun kalau dicicil pasti selesai juga. Yuk, kurangi prokrastinasi!",
    "Istirahat kalau capek, tapi jangan pernah menyerah ya. Ingat target dan mimpimu!"
  ];

  @override
  void initState() {
    super.initState();
    _dashboardStream = FirebaseFirestore.instance
        .collection('activities')
        .orderBy('createdAt', descending: true)
        .snapshots();
    
    final random = Random();
    _quoteHariIni = _daftarQuotes[random.nextInt(_daftarQuotes.length)];
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            Icon(
              Icons.school,
              color: Colors.indigo.shade700,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              "StudyFlow",
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dashboardStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          final data = snapshot.data!.docs;

          final selesai = data.where((doc) {
            final statusStr = (doc['status'] ?? '').toString().toLowerCase();
            return statusStr == 'selesai';
          }).length;

          final dalamProses = data.length - selesai;

          final deadlineData = List.from(data);
          deadlineData.sort((a, b) {
            final aDeadline = a['deadline'].toString();
            final bDeadline = b['deadline'].toString();
            final aParts = aDeadline.split('/');
            final bParts = bDeadline.split('/');
            final aDate = DateTime(
              int.parse(aParts[2]),
              int.parse(aParts[1]),
              int.parse(aParts[0]),
            );
            final bDate = DateTime(
              int.parse(bParts[2]),
              int.parse(bParts[1]),
              int.parse(bParts[0]),
            );
            return aDate.compareTo(bDate);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade700, Colors.deepPurple.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang",
                              style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Apa yang perlu\ndiselesaikan hari ini?",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.waving_hand_outlined,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _quoteHariIni,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                
                const Text(
                  "Ringkasan Aktivitas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              radius: 22,
                              child: const Icon(Icons.assignment_outlined, color: Colors.blue, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${data.length}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const Text("Total", style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              radius: 22,
                              child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$selesai",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const Text("Selesai", style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              radius: 22,
                              child: const Icon(Icons.pending_actions_outlined, color: Colors.orange, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$dalamProses",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            const Text("Proses", style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.hourglass_top_rounded, color: Colors.indigo, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "Deadline Terdekat",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    if (deadlineData.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainNavigation(initialIndex: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: const [
                            Text("Lihat Semua", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            Icon(Icons.chevron_right, size: 18, color: Colors.indigo),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                deadlineData.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber.shade50,
                              radius: 30,
                              child: const Icon(Icons.auto_awesome_outlined, color: Colors.amber, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Semua tugas aman terkendali!",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tidak ada deadline mendesak, santai dulu sejenak. ✨",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deadlineData.length > 3 ? 3 : deadlineData.length,
                        itemBuilder: (context, index) {
                          final activity = deadlineData[index];
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
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MainNavigation(initialIndex: 1),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                    const SizedBox(height: 14),
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}