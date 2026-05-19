import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/services/database_service.dart';

class EducationTab extends StatefulWidget {
  const EducationTab({super.key});

  @override
  State<EducationTab> createState() => _EducationTabState();
}

class _EducationTabState extends State<EducationTab> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _education = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final education = await _supabase.fetchTable('education');
      setState(() {
        _education = education;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForm([Map<String, dynamic>? item]) {
    final titleCtrl = TextEditingController(text: item?['title'] ?? '');
    final descCtrl = TextEditingController(text: item?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.bgDeep,
        title: Text(item == null ? 'Add Achievement/Education' : 'Edit Achievement/Education', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title (e.g. GPA, JEE Rank)')),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Value/Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold),
            onPressed: () async {
              try {
                final data = {'title': titleCtrl.text, 'description': descCtrl.text};
                if (item == null) {
                  await _supabase.createRecord('education', data);
                } else {
                  await _supabase.updateRecord('education', item['id'], data);
                }
                if (mounted) Navigator.pop(context);
                _fetchData();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), backgroundColor: Colors.green));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Save', style: TextStyle(color: AppConstants.bgDeep)),
          )
        ],
      ),
    );
  }

  Future<void> _deleteRecord(String id) async {
    try {
      await _supabase.deleteRecord('education', id);
      _fetchData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppConstants.gold));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _education.length,
        itemBuilder: (context, index) {
          final item = _education[index];
          return Card(
            color: AppConstants.bgGlass,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(item['title'] ?? '', style: const TextStyle(color: Colors.white)),
              subtitle: Text(item['description'] ?? '', style: const TextStyle(color: Colors.white54)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(item)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteRecord(item['id'])),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.gold,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: AppConstants.bgDeep),
      ),
    );
  }
}
