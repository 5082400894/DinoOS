import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Contact {
  String name;
  String phone;


  Contact({required this.name, required this.phone});


  // Convert Contact to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }


  // Create Contact from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
}


class ContactPage extends StatefulWidget {
  const ContactPage({super.key});


  @override
  _ContactPageState createState() => _ContactPageState();
}


class _ContactPageState extends State<ContactPage> {
  final List<Contact> _contacts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _storageSize = '0 B';
  static const String _contactsKey = 'contacts_data';


  @override
  void initState() {
    super.initState();
    _loadContacts();
  }


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  // Load contacts from shared_preferences
  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey);
     
      if (contactsJson != null) {
        final List<dynamic> contactsList = json.decode(contactsJson);
        setState(() {
          _contacts.clear();
          _contacts.addAll(
            contactsList.map((contact) => Contact.fromJson(contact as Map<String, dynamic>))
          );
          _updateStorageSize();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Save contacts to shared_preferences
  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = json.encode(
        _contacts.map((contact) => contact.toJson()).toList(),
      );
      await prefs.setString(_contactsKey, contactsJson);
      _updateStorageSize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Calculate storage size of contacts data
  void _updateStorageSize() {
    try {
      final contactsJson = json.encode(
        _contacts.map((contact) => contact.toJson()).toList(),
      );
      final sizeInBytes = utf8.encode(contactsJson).length;
      setState(() {
        _storageSize = _formatBytes(sizeInBytes);
      });
    } catch (e) {
      setState(() {
        _storageSize = 'Error';
      });
    }
  }


  // Format bytes to human-readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }


  void _addContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();


    if (name.isEmpty || phone.isEmpty) return;


    setState(() {
      _contacts.add(Contact(name: name, phone: phone));
      _nameController.clear();
      _phoneController.clear();
    });
   
    await _saveContacts();
  }


  void _deleteContact(int index) async {
    setState(() {
      _contacts.removeAt(index);
    });
   
    await _saveContacts();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Page'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Storage: $_storageSize',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addContact,
              child: Text('Add Contact'),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _contacts.isEmpty
                  ? Center(child: Text('No contacts added yet.'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          child: ListTile(
                            title: Text(contact.name),
                            subtitle: Text(contact.phone),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteContact(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
