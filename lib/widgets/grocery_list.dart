import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  // int noOfItems=groceryItems.length;
  void _addItem() async {
    final GroceryItem? newItem;
    newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) return;
    setState(() {
      groceryItems.add(newItem!);
    });
    // noOfItems=groceryItems.length;
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
            setState(
              () {
                // groceryItems.removeWhere(
                //   (item1) {
                //     if (item1.id == item.id) {
                //       return true;
                //     } else {
                //       return false;
                //     }
                //   },
                // );
                setState(() {
                groceryItems.remove(item);
                });
              },
            );
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
      body: groceryItems.isEmpty?  Center(
        child: Text("No Items In List , click to add more",
        style: Theme.of(context).textTheme.headlineSmall ,
        ),
      ):listView,
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
