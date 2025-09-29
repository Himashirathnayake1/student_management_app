import 'package:flutter/material.dart';
import 'package:sql_student_management_system/data/database_helper.dart';
import 'package:sql_student_management_system/models/student.dart';

class AddEditStudentPage extends StatefulWidget {
  final Student? student;
  AddEditStudentPage({this.student});

  @override
  _AddEditStudentPageState createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _courseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _ageController = TextEditingController(
      text: widget.student?.age?.toString() ?? '',
    );
    _courseController = TextEditingController(
      text: widget.student?.course ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final age =
        _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null;
    final course =
        _courseController.text.trim().isNotEmpty
            ? _courseController.text.trim()
            : null;

    if (widget.student == null) {
      // Add new
      await DatabaseHelper.instance.create(
        Student(name: name, email: email, age: age ?? 0, course: course ?? ''),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Student added successfully')));
    } else {
      // Update existing
      await DatabaseHelper.instance.update(
        widget.student!.copyWith(
          name: name,
          email: email,
          age: age ?? 0,
          course: course ?? '',
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Student updated successfully')));
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Student' : 'Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final age = int.tryParse(v);
                  if (age == null || age < 16 || age > 100)
                    return 'Age must be between 16–100';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(labelText: 'Course'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEditing ? Colors.blue : Colors.green,
                      ),
                      onPressed: _saveStudent,
                      child: Text(isEditing ? 'Update' : 'Save'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
