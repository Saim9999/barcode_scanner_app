import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesScreen extends StatefulWidget {
  final List<String> favorites;
  final Function(String) onDelete;

  FavoritesScreen(this.favorites, this.onDelete);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.favorites.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text(widget.favorites[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      widget.onDelete(widget.favorites[index]);
                      Get.back();
                    },
                  ),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}
