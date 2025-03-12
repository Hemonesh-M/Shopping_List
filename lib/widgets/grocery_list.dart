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
  var isLoading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try{
    // Uri url = Uri.https('firebaseio.com', 'Shopping-list.json');
    // Uri url = Uri.https('abc.firebaseio.com', 'Shopping-list.json');
    Uri url = Uri.https('shopping-list-faf8f-default-rtdb.firebaseio.com',
        'Shopping-list.json');
    final response = await https.get(url);
    // print(response.statusCode);
    if(response.body=="null"){
      setState(() {
        isLoading=false;
      });
      return;
    }
    if (response.statusCode >= 400) {
      setState(() {
        error = "Failed to get Data try again Later.";
      });
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
    setState(() {
      for (final item in tempList) {
        groceryItems.add(item);
      }
      // groceryItems=tempList;
      isLoading = false;
    });
    }
    catch(err){
      setState(() {
        error = "Something Went Wrong!!!  Try again Later.";
      });
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
        groceryItems.insert(index,item);
        // groceryItems.add(item);
      });
      if(!context.mounted){
        return;
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Could Not delete ${item.name} from server",textScaler:TextScaler.linear(2) ,)));
    }
    else{
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("${item.name} was deleted from server",textScaler:TextScaler.linear(2) ,)));

    }
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
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
    Widget selectScreen() {
      if (error != null) {
        return Center(child: Text(error!));
      } else if (isLoading) {
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      }
      return groceryItems.isEmpty
          ? Center(
              child: Text(
                "No Items In List , click to add more",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )
          : listView;
    }

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
        body: selectScreen());
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
