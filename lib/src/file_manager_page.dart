import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});


  @override
  // ignore: library_private_types_in_public_api
  _FileManagerPageState createState() => _FileManagerPageState();
}


class _FileManagerPageState extends State<FileManagerPage> {
  List<FileSystemEntity> _files = [];
  Directory? _documentsDir;
  bool _isLoading = true;


  // Supported file extensions
  final List<String> _supportedExtensions = ['.txt', '.csv', '.json'];


  @override
  void initState() {
    super.initState();
    _loadFiles();
  }


  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });


    try {
      _documentsDir = await getApplicationDocumentsDirectory();
      final allEntities = _documentsDir!.listSync();
     
      // Filter to only show files (not directories) with supported extensions
      setState(() {
        _files = allEntities.where((entity) {
          if (entity is! File) return false;
          final extension = entity.path.split('.').last.toLowerCase();
          return _supportedExtensions.contains('.$extension');
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading files: $e')),
        );
      }
    }
  }


  Future<void> _createNewFile() async {
    // Show dialog to select file type
    final fileType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Text File (.txt)'),
              onTap: () => Navigator.pop(context, 'txt'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV File (.csv)'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON File (.json)'),
              onTap: () => Navigator.pop(context, 'json'),
            ),
          ],
        ),
      ),
    );


    if (fileType == null) return;


    // Get filename
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter filename (without extension)'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'myfile',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );


    if (result == null || result.isEmpty) return;


    final fileName = '$result.$fileType';
    final file = File('${_documentsDir!.path}/$fileName');


    // Check if file already exists
    if (await file.exists()) {
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('File exists'),
          content: Text('File "$fileName" already exists. Overwrite?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );


      if (overwrite != true) return;
    }


    // Create file with default content based on type
    String defaultContent = '';
    switch (fileType) {
      case 'txt':
        defaultContent = 'This is a new text file.\nYou can edit this content.';
        break;
      case 'csv':
        defaultContent = 'Name,Age,City\nJohn,25,New York\nJane,30,London';
        break;
      case 'json':
        defaultContent = '{\n  "name": "Example",\n  "value": 123\n}';
        break;
    }


    try {
      await file.writeAsString(defaultContent);
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File "$fileName" created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating file: $e')),
        );
      }
    }
  }


  Future<void> _deleteFile(FileSystemEntity file) async {
    final fileName = file.path.split('/').last;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );


    if (confirm == true) {
      try {
        await file.delete();
        _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File "$fileName" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting file: $e')),
          );
        }
      }
    }
  }


  Future<void> _renameFile(File file) async {
    final oldName = file.path.split('/').last;
    final nameController = TextEditingController(text: oldName.split('.').first);
    final extension = oldName.split('.').last;


    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'filename',
            suffixText: '.$extension',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );


    if (newName == null || newName.isEmpty) return;


    try {
      final newPath = '${file.parent.path}/$newName.$extension';
      await file.rename(newPath);
      _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File renamed to "$newName.$extension"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error renaming file: $e')),
        );
      }
    }
  }


  Future<void> _openFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
   
    if (!mounted) return;
   
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(file: file, extension: extension),
      ),
    );
  }


  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'txt':
        return Icons.text_fields;
      case 'csv':
        return Icons.table_chart;
      case 'json':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        backgroundColor: Colors.greenAccent.shade400,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFile,
        child: const Icon(Icons.add),
        tooltip: 'Create New File',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const Center(child: Text('No files found'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final name = file.path.split('/').last;
                    final extension = name.split('.').last.toLowerCase();
                   
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getFileIcon(extension),
                          color: Colors.greenAccent.shade400,
                        ),
                        title: Text(name),
                        subtitle: Text(
                          '${(file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                        ),
                        onTap: () => _openFile(file),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _renameFile(file),
                              tooltip: 'Rename',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteFile(file),
                              tooltip: 'Delete',
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


// File Viewer Screen
class FileViewerScreen extends StatefulWidget {
  final File file;
  final String extension;


  const FileViewerScreen({
    super.key,
    required this.file,
    required this.extension,
  });


  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}


class _FileViewerScreenState extends State<FileViewerScreen> {
  String _content = '';
  bool _isLoading = true;
  bool _isEditing = false;
  late TextEditingController _editorController;


  @override
  void initState() {
    super.initState();
    _loadFile();
  }


  Future<void> _loadFile() async {
    try {
      final content = await widget.file.readAsString();
      setState(() {
        _content = content;
        _editorController = TextEditingController(text: content);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error reading file: $e';
        _isLoading = false;
      });
    }
  }


  Future<void> _saveFile() async {
    try {
      await widget.file.writeAsString(_editorController.text);
      setState(() {
        _isEditing = false;
        _content = _editorController.text;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }


  Widget _buildViewer() {
    if (widget.extension == 'json') {
      // Pretty print JSON
      try {
        final json = jsonDecode(_content);
        final prettyJson = const JsonEncoder.withIndent('  ').convert(json);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            prettyJson,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      } catch (e) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text('Invalid JSON: $e'),
        );
      }
    } else if (widget.extension == 'csv') {
      // Display CSV as table
      final lines = _content.split('\n');
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: lines.isNotEmpty
                ? lines.first.split(',').map((header) {
                    return DataColumn(label: Text(header.trim()));
                  }).toList()
                : [],
            rows: lines.length > 1
                ? lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
                    final cells = line.split(',');
                    return DataRow(
                      cells: cells.map((cell) {
                        return DataCell(Text(cell.trim()));
                      }).toList(),
                    );
                  }).toList()
                : [],
          ),
        ),
      );
    } else {
      // Plain text viewer
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _content,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        backgroundColor: Colors.greenAccent.shade400,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveFile,
              tooltip: 'Save',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _editorController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              : _buildViewer(),
    );
  }


  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }
}
