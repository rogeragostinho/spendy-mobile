import 'package:flutter/material.dart';
import 'package:spendy_mobile/services/expense_service.dart';

class CreateExpenseScreen extends StatefulWidget {
  final int groupId;
  final List<dynamic> members;

  const CreateExpenseScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final Set<int> selectedMembers = {};

  void toggleMember(int memberId) {
    setState(() {
      if (selectedMembers.contains(memberId)) {
        selectedMembers.remove(memberId);
      } else {
        selectedMembers.add(memberId);
      }
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void submitExpense() async {
    final description = descriptionController.text.trim();
    final amount = double.tryParse(amountController.text.trim());

    if (description.isEmpty || amount == null || selectedMembers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preenche todos os campos")));
      return;
    }

    final service = ExpenseService();

    try {
      final data = await service.createExpense(
        groupId: widget.groupId,
        description: description,
        amount: amount,
        memberIds: selectedMembers.toList(),
      );

      final participants = data["participants"]; // 👈 AQUI É A CHAVE CERTA

      Navigator.pop(context, {
        "success": true,
        "participants": participants,
        "expense": data["expense"],
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Despesa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Descrição",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Valor",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Participantes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  final member = widget.members[index];
                  final memberId = member["id"];

                  return CheckboxListTile(
                    title: Text(member["name"]),
                    value: selectedMembers.contains(memberId),
                    onChanged: (_) => toggleMember(memberId),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitExpense,
                child: const Text("Criar despesa"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
