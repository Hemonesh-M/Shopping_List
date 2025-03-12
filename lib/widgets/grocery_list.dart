import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as https;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});
  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  late Future<List<GroceryItem>> _loadedItems;
  String? error;
  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    Uri url = Uri.https(
        'shopping-list-faf8f-default-rtdb.firebaseio.com', 'Shopping-list.json');
    try{
    final response = await https.get(url);
    if (response.statusCode >= 400) {
      throw Exception("Failed to Fetch Data");
    }
    final Map<String, dynamic> listData = jsonDecode(response.body);
    List<GroceryItem> tempList = [];
    for (final item in listData.entries) {
      final cat = categories.entries.firstWhere((catItem) {
        if (catItem.value.title == item.value['category']) {
          return true;
        } else {
          return false;
        }
      });
      tempList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: cat.value));
    }
    return tempList;
    } 
    catch (err){
      throw Exception("Could NOT Sent Reuqest To fetch Data");
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) return;
    setState(() {
      groceryItems.add(newItem);
    });
  }

  void removeItem(GroceryItem item) async {
    int index = groceryItems.indexOf(item);
    setState(() {
      groceryItems.remove(item);
    });
    Uri url = Uri.https('shopping-list-faf8f-default-rtdb.firebaseio.com',
        'Shopping-list/${item.id}.json');
    final response = await https.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        groceryItems.insert(index, item);
        // groceryItems.add(item);
      });
      if (!context.mounted) {
        return;
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Could Not delete ${item.name} from server",
        textScaler: TextScaler.linear(2),
      )));
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "${item.name} was deleted from server",
        textScaler: TextScaler.linear(2),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
              onPressed: () {
                _addItem();
              },
              icon: const Icon(Icons.add_box))
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                // "Something Went Wrong!!!  Try again Later.",
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No Items In List , click to add more",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            );
          }
          return ListView.builder(
            itemCount: groceryItems.length,
            itemBuilder: (context, idx) {
              GroceryItem item = groceryItems[idx];
              return Dismissible(
                key: ValueKey(item.id),
                onDismissed: (direction) {
                  removeItem(item);
                },
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: item.category.color,
                  ),
                  title: Text(item.name),
                  trailing: Text(item.quantity.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ignore: camel_case_types
// class listViewBuilder extends StatelessWidget {
//   const listViewBuilder({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         itemCount: groceryItems.length,
//         itemBuilder: (context, idx) {
//           GroceryItem item = groceryItems[idx];
//           return Column(
//             children: [
//               Column(
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(Icons.rectangle, color: item.category.color),
//                       const SizedBox(
//                         width: 5,
//                       ),
//                       Text(
//                         item.name,
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                       Expanded(
//                         child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Text("${item.quantity}",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headlineMedium),
//                             ]),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   )
//                 ],
//               ),
//             ],
//           );
//         });
//   }
// }

// ignore: camel_case_types
// class listViewBuilderWithTiles extends StatelessWidget {
//   const listViewBuilderWithTiles({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//         itemCount: noOfItems,
//         itemBuilder: (context, idx) {
//           GroceryItem item = groceryItems[idx];
//           return ListTile(
//             leading: Container(
//               width: 24,
//               height: 24,
//               color: item.category.color,
//             ),
//             title: Text(item.name),
//             trailing: Text(item.quantity.toString()),
//           );
//         });
//   }
// }

// class SingleChild extends StatelessWidget {
//   const SingleChild({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(10),
//       scrollDirection: Axis.vertical,
//       child: Column(
//         children: [
//           for (GroceryItem item in groceryItems)
//             Column(
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Icon(Icons.rectangle, color: item.category.color),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       item.name,
//                       style: Theme.of(context).textTheme.headlineMedium,
//                     ),
//                     Expanded(
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text("${item.quantity}",
//                                 style:
//                                     Theme.of(context).textTheme.headlineMedium),
//                           ]),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 )
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }
