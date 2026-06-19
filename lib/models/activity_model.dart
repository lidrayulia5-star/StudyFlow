class Activity {
  final String id;
  final String judul;
  final String mataKuliah;
  final String kategori;
  final String status;
  final String deadline;
  final String catatan;

  Activity({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.kategori,
    required this.status,
    required this.deadline,
    required this.catatan,
  });

  factory Activity.fromMap(String documentId, Map<String, dynamic> data) {
    return Activity(
      id: documentId,
      judul: data['judul'] ?? '',
      mataKuliah: data['mataKuliah'] ?? '',
      kategori: data['kategori'] ?? '',
      status: data['status'] ?? '',
      deadline: data['deadline'] ?? '',
      catatan: data['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'mataKuliah': mataKuliah,
      'kategori': kategori,
      'status': status,
      'deadline': deadline,
      'catatan': catatan,
    };
  }
}