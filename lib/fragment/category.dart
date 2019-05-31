import 'package:flutter/material.dart';
import 'package:reader_flutter/bean/category.dart';
import 'package:reader_flutter/util/http_manager.dart';
import 'package:reader_flutter/view/category_item.dart';
import 'package:reader_flutter/view/load.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with AutomaticKeepAliveClientMixin {
  List<MyCategory> categories = [];

  @override
  void initState() {
    super.initState();
    getCategoryData().then((map) {
      setState(() {
        if (map == null || map['data'].length == 0) {
        } else
          for (int i = 0; i < map['data'].length; i++) {
            categories.add(MyCategory.fromMap(map['data'][i]));
          }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return categories.length == 0
        ? LoadingPage()
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return categoryItem(context, index, categories[index]);
            },
            itemCount: categories.length,
          );
  }

  @override
  bool get wantKeepAlive => true;
}
