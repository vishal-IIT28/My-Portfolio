import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/services/database_service.dart';

class SkillsExperienceTab extends StatefulWidget {
  const SkillsExperienceTab({super.key});

  @override
  State<SkillsExperienceTab> createState() => _SkillsExperienceTabState();
}

class _SkillsExperienceTabState extends State<SkillsExperienceTab> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _skills = [];
  List<Map<String, dynamic>> _experiences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final skills = await _supabase.fetchTable('skills');
      final experiences = await _supabase.fetchTable('experiences');
      setState(() {
        _skills = skills;
        _experiences = experiences;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSkillForm([Map<String, dynamic>? skill]) {
    final nameCtrl = TextEditingController(text: skill?['skill_name'] ?? '');
    final catCtrl = TextEditingController(text: skill?['category'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.bgDeep,
        title: Text(skill == null ? 'Add Skill' : 'Edit Skill', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Skill Name')),
            TextField(controller: catCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold),
            onPressed: () async {
              try {
                final data = {'skill_name': nameCtrl.text, 'category': catCtrl.text};
                if (skill == null) {
                  await _supabase.createRecord('skills', data);
                } else {
                  await _supabase.updateRecord('skills', skill['id'], data);
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

  void _showExperienceForm([Map<String, dynamic>? exp]) {
    final roleCtrl = TextEditingController(text: exp?['role'] ?? '');
    final companyCtrl = TextEditingController(text: exp?['company'] ?? '');
    final periodCtrl = TextEditingController(text: exp?['period'] ?? '');
    final descCtrl = TextEditingController(text: exp?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.bgDeep,
        title: Text(exp == null ? 'Add Experience' : 'Edit Experience', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: roleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: companyCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: periodCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Period (e.g. May 2024 - Jul 2024)')),
              TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold),
            onPressed: () async {
              try {
                final data = {'role': roleCtrl.text, 'company': companyCtrl.text, 'period': periodCtrl.text, 'description': descCtrl.text};
                if (exp == null) {
                  await _supabase.createRecord('experiences', data);
                } else {
                  await _supabase.updateRecord('experiences', exp['id'], data);
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

  Future<void> _deleteRecord(String table, String id) async {
    try {
      await _supabase.deleteRecord(table, id);
      _fetchData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppConstants.gold));

    return Row(
      children: [
        // Skills Column
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Skills', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Skill'),
                      onPressed: () => _showSkillForm(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold, foregroundColor: AppConstants.bgDeep),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _skills.length,
                  itemBuilder: (context, index) {
                    final skill = _skills[index];
                    return Card(
                      color: AppConstants.bgGlass,
                      child: ListTile(
                        title: Text(skill['skill_name'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(skill['category'] ?? '', style: const TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showSkillForm(skill)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteRecord('skills', skill['id'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: AppConstants.glassBorder),
        // Experiences Column
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Experience', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Exp'),
                      onPressed: () => _showExperienceForm(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold, foregroundColor: AppConstants.bgDeep),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _experiences.length,
                  itemBuilder: (context, index) {
                    final exp = _experiences[index];
                    return Card(
                      color: AppConstants.bgGlass,
                      child: ListTile(
                        title: Text(exp['role'] ?? '', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${exp['company']} | ${exp['period']}', style: const TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showExperienceForm(exp)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteRecord('experiences', exp['id'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
