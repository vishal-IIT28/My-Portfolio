import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/services/database_service.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _supabase.fetchTable('projects');
      setState(() => _projects = projects);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProjectForm([Map<String, dynamic>? project]) {
    showDialog(
      context: context,
      builder: (context) => _ProjectFormDialog(
        project: project,
        onSaved: () {
          _fetchProjects();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteProject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.bgGlass,
        title: const Text('Delete Project', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this project?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.deleteRecord('projects', id);
        _fetchProjects();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppConstants.gold));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return Card(
            color: AppConstants.bgGlass,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(project['title'] ?? 'No Title', style: const TextStyle(color: Colors.white)),
              subtitle: Text(project['category'] ?? '', style: const TextStyle(color: AppConstants.gold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProjectForm(project),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProject(project['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.gold,
        onPressed: () => _showProjectForm(),
        child: const Icon(Icons.add, color: AppConstants.bgDeep),
      ),
    );
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final Map<String, dynamic>? project;
  final VoidCallback onSaved;

  const _ProjectFormDialog({this.project, required this.onSaved});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _imgUrlCtrl;
  late TextEditingController _pdfUrlCtrl;
  String _category = 'software';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.project?['title'] ?? '');
    _descCtrl = TextEditingController(text: widget.project?['description'] ?? '');
    _githubCtrl = TextEditingController(text: widget.project?['github_url'] ?? '');
    _imgUrlCtrl = TextEditingController(text: widget.project?['image_url'] ?? '');
    _pdfUrlCtrl = TextEditingController(text: widget.project?['pdf_url'] ?? '');
    if (widget.project?['category'] != null) {
      _category = widget.project!['category'];
    }
  }

  Future<void> _uploadMedia(TextEditingController controller, String bucket) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(withData: true);
      if (result != null && result.files.single.bytes != null) {
        setState(() => _isSaving = true);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final url = await SupabaseService().uploadFile(bucket, fileName, result.files.single.bytes!);
        setState(() {
          controller.text = url;
          _isSaving = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded!'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    final data = {
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'category': _category,
      'github_url': _githubCtrl.text,
      'image_url': _imgUrlCtrl.text,
      'pdf_url': _pdfUrlCtrl.text,
    };

    try {
      if (widget.project == null) {
        await SupabaseService().createRecord('projects', data);
      } else {
        await SupabaseService().updateRecord('projects', widget.project!['id'], data);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.bgDeep,
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project', style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white54)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white54)),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: AppConstants.bgDeep,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white54)),
                  items: const [
                    DropdownMenuItem(value: 'software', child: Text('Software')),
                    DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                    DropdownMenuItem(value: 'robotics', child: Text('Robotics')),
                  ],
                  onChanged: (v) => setState(() => _category = v!),
                ),
                TextFormField(
                  controller: _githubCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'GitHub URL', labelStyle: TextStyle(color: Colors.white54)),
                ),
                TextFormField(
                  controller: _imgUrlCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Image URL', 
                    labelStyle: const TextStyle(color: Colors.white54),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.upload_file, color: AppConstants.gold),
                      onPressed: () => _uploadMedia(_imgUrlCtrl, 'portfolio_images'),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _pdfUrlCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'PDF URL', 
                    labelStyle: const TextStyle(color: Colors.white54),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.upload_file, color: AppConstants.gold),
                      onPressed: () => _uploadMedia(_pdfUrlCtrl, 'portfolio_pdfs'),
                    ),
                  ),
                ),
                // Note: Actual file upload via file picker could be added here, 
                // but for simplicity we rely on manual URL or a separate media tab.
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.gold),
          child: _isSaving ? const CircularProgressIndicator() : const Text('Save', style: TextStyle(color: AppConstants.bgDeep)),
        ),
      ],
    );
  }
}
