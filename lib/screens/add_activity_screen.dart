import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final judulController = TextEditingController();
  final mataKuliahController = TextEditingController();
  final catatanController = TextEditingController();
  final firestoreService = FirestoreService();

  String selectedKategori = "Tugas";
  String selectedStatus = "Belum Dimulai";
  DateTime? selectedDate;

  final List<String> daftarKategori = [
    "Tugas",
    "Praktikum",
    "Proyek",
    "Presentasi",
    "Seminar",
    "Organisasi",
    "Lainnya"
  ];

  final List<String> daftarStatus = [
    "Belum Dimulai",
    "Sedang Dikerjakan",
    "Revisi",
    "Selesai"
  ];

  // FocusNode untuk mendeteksi kapan input sedang aktif (diklik)
  final FocusNode _judulFocus = FocusNode();
  final FocusNode _matkulFocus = FocusNode();
  final FocusNode _catatanFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Memicu pembangunan ulang widget saat status fokus berubah agar ikon hilang/muncul secara dinamis
    _judulFocus.addListener(() => setState(() {}));
    _matkulFocus.addListener(() => setState(() {}));
    _catatanFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    judulController.dispose();
    mataKuliahController.dispose();
    catatanController.dispose();
    _judulFocus.dispose();
    _matkulFocus.dispose();
    _catatanFocus.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required FocusNode focusNode,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      // Ikon otomatis disembunyikan (null) jika TextField sedang mendapatkan fokus (diklik)
      prefixIcon: focusNode.hasFocus ? null : Icon(prefixIcon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Aktivitas"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: judulController,
                        focusNode: _judulFocus,
                        decoration: _buildInputDecoration(
                          label: "Nama Aktivitas",
                          hint: "Contoh: Laporan Praktikum, Rapat, dsb",
                          prefixIcon: Icons.assignment_outlined,
                          focusNode: _judulFocus,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: mataKuliahController,
                        focusNode: _matkulFocus,
                        decoration: _buildInputDecoration(
                          label: "Mata Kuliah / Kegiatan",
                          hint: "Contoh: Pemrograman Bergerak, HIMANIKA, dsb",
                          prefixIcon: Icons.book_outlined,
                          focusNode: _matkulFocus,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Dropdown Kategori dibuat melebar penuh seperti TextField
                      DropdownButtonFormField<String>(
                        value: selectedKategori,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Kategori",
                          prefixIcon: const Icon(Icons.category_outlined, color: Colors.indigo),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: daftarKategori.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedKategori = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dropdown Status dibuat melebar penuh seperti TextField
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Status",
                          prefixIcon: const Icon(Icons.star_border_rounded, color: Colors.indigo),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: daftarStatus.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2035),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.indigo,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Deadline",
                        prefixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.indigo),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        selectedDate == null
                            ? "Pilih Tanggal Deadline"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: TextStyle(
                          color: selectedDate == null ? Colors.grey.shade600 : Colors.black,
                          fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: catatanController,
                    focusNode: _catatanFocus,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Catatan Tambahan",
                      hintText: "Contoh: Membawa laptop, revisi bab 2, dsb",
                      prefixIcon: _catatanFocus.hasFocus
                          ? null
                          : const Padding(
                              padding: EdgeInsets.only(bottom: 60),
                              child: Icon(Icons.notes_rounded, color: Colors.indigo),
                            ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (judulController.text.trim().isEmpty ||
                        mataKuliahController.text.trim().isEmpty ||
                        selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Lengkapi data terlebih dahulu"),
                            ],
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    await firestoreService.addActivity(
                      judul: judulController.text.trim(),
                      mataKuliah: mataKuliahController.text.trim(),
                      kategori: selectedKategori,
                      status: selectedStatus,
                      deadline: "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      catatan: catatanController.text.trim(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Aktivitas berhasil ditambahkan"),
                          ],
                        ),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );

                    judulController.clear();
                    mataKuliahController.clear();
                    catatanController.clear();

                    setState(() {
                      selectedKategori = "Tugas";
                      selectedStatus = "Belum Dimulai";
                      selectedDate = null;
                    });
                  },
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text(
                    "Simpan Aktivitas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}