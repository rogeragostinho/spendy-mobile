import 'package:flutter/material.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> expense;
  final List<dynamic> groupMembers;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.groupMembers,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late List<dynamic> participants;

  @override
  void initState() {
    super.initState();

    // assume que backend já devolve participants
    participants = widget.expense["users"] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense["description"] ?? "Despesa")),
      body: Column(
        children: [
          ListTile(
            title: const Text("Valor"),
            subtitle: Text("${widget.expense["amount"]}"),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Participantes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(p["name"] ?? "Utilizador"),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ListView(
                children: widget.groupMembers.map((member) {
                  return ListTile(
                    title: Text(member["name"]),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      // aqui depois vais chamar:
                      // POST /expenses/{id}/addMember

                      setState(() {
                        participants.add(member);
                      });

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
