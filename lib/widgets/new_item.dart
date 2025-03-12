// import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';
// import 'package:shopping_list/models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  var isSending=false;
  final formKey = GlobalKey<FormState>();
  String enteredName = "";
  int enteredQuantity = 1;
  // String enteredCategory = "";
  Category enteredCategory = categories[Categories.fruit]!;

  void _saveItem() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isSending=true;
      Uri url = Uri.https('shopping-list-faf8f-default-rtdb.firebaseio.com',
          'Shopping-list.json');
      // print("entered valus is $enteredName");
      final response =await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: jsonEncode({
            "name": enteredName,
            "quantity": enteredQuantity,
            "category": enteredCategory.title
          }));
      final Map<String,dynamic> dResp=json.decode(response.body);
      if (!context.mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(
        GroceryItem(id:dResp['name']! ,category: enteredCategory,name: enteredName,quantity:enteredQuantity )
      );
    }
  }

  void _reset() {
    formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    print("Building NewItem widget");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              // keyboardType: TextInputType.name,
              onSaved: (newValue) {
                enteredName = newValue!;
              },
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length <= 1 ||
                    value.trim().length > 50) {
                  return "Name Must be Between 2 to 50 characters long";
                } else {
                  return null;
                }
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    onSaved: (newValue) {
                      enteredQuantity = int.parse(newValue!);
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Quantity"),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0) {
                        return "Quantity Must be valid positive number";
                      } else {
                        return null;
                      }
                    },
                    initialValue: 1.toString(),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                      value: enteredCategory,
                      decoration: const InputDecoration(
                        label: Text("Category"),
                      ),
                      onSaved: (newValue) {
                        setState(() {
                          enteredCategory = newValue!;
                        });
                      },
                      items: [
                        for (final cats in categories.entries)
                          DropdownMenuItem(
                            value: cats.value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: cats.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(cats.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        return;
                      }),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: isSending?null: _reset, child: const Text("Reset")),
                ElevatedButton(
                    onPressed: isSending? null : _saveItem, child: isSending? const Center(child: CircularProgressIndicator()) :Text("Submit"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
