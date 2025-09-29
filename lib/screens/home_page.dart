import 'package:flutter/material.dart';
import 'package:sql_student_management_system/models/student.dart';
import 'package:sql_student_management_system/data/database_helper.dart';
import 'package:sql_student_management_system/screens/add_edit_student_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> _students = [];
  List<Student> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshStudents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_students)
          : _students.where((s) => s.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _refreshStudents() async {
    setState(() => _isLoading = true);
    final students = await DatabaseHelper.instance.readAll();
    setState(() {
      _students = students;
      _filtered = List.from(_students);
      _isLoading = false;
    });
  }

  Future<void> _deleteStudent(int id) async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm deletion'),
        content: Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student deleted')),
      );
      await _refreshStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshStudents),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditStudentPage()),
          );
          if (shouldRefresh == true) await _refreshStudents();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildTopInfo(),
              SizedBox(height: 8),
              _buildSearchField(),
              SizedBox(height: 8),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total students: ${_students.length}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (!_isLoading)
          Text('Showing: ${_filtered.length}', style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              )
            : null,
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) {
      return Center(child: Text('No students yet', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _refreshStudents,
      child: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final s = _filtered[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?'),
              ),
              title: Text(s.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.email),
                  SizedBox(height: 4),
                  Text('Age: ${s.age ?? '-'} • Course: ${s.course ?? '-'}'),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final shouldRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditStudentPage(student: s)),
                  );
                  if (shouldRefresh == true) await _refreshStudents();
                },
              ),
              onLongPress: () => _deleteStudent(s.id!),
            ),
          );
        },
      ),
    );
  }
}
