import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:reader_flutter/bean/list.dart';
import 'package:reader_flutter/util/http_manager.dart';
import 'package:reader_flutter/view/book_list_item.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  List<String> _kindsTitles = ["最新发布", "本周最热", "最多收藏", "小编推荐"];
  List<String> _Kinds = ["new", "hot", "collect", "commend"];

//  List<String> _sexs = ["男", "女"];
  String _curKind = 'new';
  String _curSex = "man";
  int _curPage = 1;
  List<BookList> _bookLists = [];
  final _scrollController = ScrollController();
  GlobalKey<EasyRefreshState> _easyRefreshKey = GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  bool _noMore = false;

  _getListData() {
    getListData(_curSex, _curKind, _curPage).then((map) {
      setState(() {
        if (map == null || map['data'].length == 0) {
          _noMore = true;
        } else
          for (int i = 0; i < map['data'].length; i++) {
            _noMore = false;
            _bookLists.add(BookList.fromMap(map['data'][i]));
          }
      });
    });
  }

  Iterable<Widget> get _kindSelects sync* {
    for (String kind in _Kinds) {
      yield Padding(
        padding: EdgeInsets.only(right: 5, top: 10),
        child: ChoiceChip(
          selectedColor: Colors.blue,
          backgroundColor: Colors.redAccent,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          label: Text(
            _kindsTitles[_Kinds.indexOf(kind)],
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w200, color: Colors.white),
          ),
          selected: _curKind == kind,
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _bookLists.clear();
                _curKind = kind;
                _getListData();
                print(_curKind);
              }
            });
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getListData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.white70,
            width: 100,
            child: Column(
//              children: _Kinds.map((kind) {
//                return MyRadioListTile(
//                    selected: _curKind == kind,
//                    title: Text(_kindsTitle[_Kinds.indexOf(kind)]),
//                    value: kind,
//                    groupValue: this._curKind,
//                    onChanged: (v) {
//                      this.setState(() {
//                        _bookLists.clear();
//                        _curKind = v;
//                        _getListData();
//                        print(_curKind);
//                      });
//                    });
//              }).toList(),
              children: _kindSelects.toList(),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white10,
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width - 200,
                      child: CupertinoSegmentedControl(
                        onValueChanged: (v) {
                          this.setState(() {
                            _bookLists.clear();
                            _curSex = v;
                            _getListData();
                            print(_curSex);
                          });
                        },
                        groupValue: this._curSex,
                        children: {
                          'man': Text('男'),
                          'lady': Text('女'),
                        },
                      )),
                  Expanded(
                    child: EasyRefresh(
                      key: _easyRefreshKey,
                      refreshHeader: ClassicsHeader(
                        moreInfoColor: Colors.black,
                        bgColor: Colors.white10,
                        textColor: Colors.black,
                        key: _headerKey,
                        refreshText: "用力一点",
                        refreshReadyText: "释放",
                        refreshingText: "刷新中",
                        refreshedText: "刷新完成",
                        moreInfo: "上次刷新: %T",
                        showMore: true,
                      ),
                      refreshFooter: ClassicsFooter(
                        moreInfoColor: Colors.black,
                        bgColor: Colors.white10,
                        textColor: Colors.black,
                        key: _footerKey,
                        loadText: "用力一点",
                        loadReadyText: "释放",
                        loadingText: "加载中",
                        loadedText: "加载完成",
                        noMoreText: _noMore ? "没有更多了" : "",
                        moreInfo: "上次加载：%T",
                        showMore: true,
                      ),
                      child: ListView.separated(
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          return bookListItem(
                              context, index, _bookLists[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return new Divider(
                            height: 1.0,
                            color: Colors.black12,
                          );
                        },
                        itemCount: _bookLists.length,
                      ),
                      onRefresh: () async {
                        _bookLists.clear();
                        _curPage = 1;
                        _getListData();
                      },
                      loadMore: () async {
                        _curPage++;
                        _getListData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
