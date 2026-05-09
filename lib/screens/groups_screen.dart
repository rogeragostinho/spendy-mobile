import 'package:flutter/material.dart';
import 'package:spendy_mobile/screens/group_detail_screen.dart';
import '../services/group_service.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService groupService = GroupService();

  late Future<List<dynamic>> groupsFuture;

  @override
  void initState() {
    super.initState();
    groupsFuture = groupService.getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grupos")),
      body: FutureBuilder<List<dynamic>>(
        future: groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(child: Text("Nenhum grupo encontrado"));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return ListTile(
                title: Text(group["name"]),
                subtitle: Text("ID: ${group["id"]}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(group: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
