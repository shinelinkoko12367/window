import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage(String text, {super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<String> itemList = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
    'Item 7',
    'Item 8',
    'Item 9',
    'Item 10',
    'Item 11',
    'Item 12',
    'Item 13',
    'Item 14',
    'Item 15',
  ];
  @override
  Widget build(BuildContext context) {
    final columns = 3;
    final rows = 5;
    return Scaffold(
      body: SafeArea(
          child: GridView.count(
        crossAxisCount: columns, // Number of items in each row (columns)
        children: List.generate(rows * columns, (index) {
          return Container(
            color: Colors.amber,
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(itemList[index]),
            ),
          );
        }),
      )),
    );
  }
}
