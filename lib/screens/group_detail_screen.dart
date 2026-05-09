import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../services/group_service.dart';
import 'package:flutter/services.dart';
import 'create_expense_screen.dart';
import 'expense_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final ExpenseService expenseService = ExpenseService();
  final GroupService groupService = GroupService();

  late Future<List<dynamic>> expensesFuture;
  late Future<List<dynamic>> membersFuture;
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();

    final groupId = widget.group["id"];

    expensesFuture = expenseService.getExpenses(groupId);
    membersFuture = groupService.getMembers(groupId);

    membersFuture.then((data) {
      setState(() {
        members = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.group["name"]),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Despesas"),
              Tab(text: "Membros"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                final inviteCode = widget.group["invite_code"];

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Código de convite"),
                      content: SelectableText(inviteCode ?? "Sem código"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: inviteCode ?? ""),
                            );

                            Navigator.pop(context);
                          },
                          child: const Text("Copiar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Fechar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            /// 📌 DESPESAS
            FutureBuilder<List<dynamic>>(
              future: expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(child: Text("Sem despesas"));
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return ListTile(
                      title: Text(expense["description"] ?? "Sem descrição"),
                      subtitle: Text("Valor: ${expense["amount"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseDetailScreen(
                              expense: expense,
                              groupMembers: members,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            /// 👥 MEMBROS
            FutureBuilder<List<dynamic>>(
              future: membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }

                final members = snapshot.data ?? [];

                if (members.isEmpty) {
                  return const Center(child: Text("Sem membros"));
                }

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(member["name"]),
                      subtitle: Text(member["email"] ?? ""),
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateExpenseScreen(
                  groupId: widget.group["id"],
                  members: members,
                ),
              ),
            );

            if (result != null && result["success"] == true) {
              setState(() {
                expensesFuture = expenseService.getExpenses(widget.group["id"]);
              });
            }
          },
        ),
      ),
    );
  }
}
