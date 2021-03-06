import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class WebblenAppBar {
  Widget basicAppBar(String appBarTitle, BuildContext context) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title:
          MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: Fonts().textW700(appBarTitle, 20.0, Colors.black, TextAlign.center)),
      leading: BackButton(color: Colors.black),
    );
  }

  Widget homeAppBar(Widget leadingWidget, Widget logo, Widget trailingWidget) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.dark,
      backgroundColor: Colors.white,
      title: logo,
      leading: leadingWidget,
      actions: <Widget>[trailingWidget],
    );
  }

  Widget pagingAppBar(BuildContext context, String appBarTitle, String nextButtonTitle, VoidCallback prevPage, VoidCallback nextPage) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, Colors.black, TextAlign.center),
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.black, size: 16.0),
        onPressed: prevPage,
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 16.0, right: 16.0),
          child: GestureDetector(
            onTap: nextPage,
            child: Fonts().textW500(nextButtonTitle, 18.0, Colors.black, TextAlign.right),
          ),
        ),
      ],
    );
  }

  Widget newEventAppBar(BuildContext context, String appBarTitle, String communityName, String cancelHeader, VoidCallback cancelAction) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, Colors.black, TextAlign.center),
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.times, color: Colors.black, size: 16.0),
        onPressed: () {
          ShowAlertDialogService().showCancelDialog(context, cancelHeader, cancelAction);
        },
      ),
      bottom: PreferredSize(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: FlatColors.iosOffWhite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Divider(
                height: 2.0,
                thickness: 0,
                color: Colors.black12,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
                child: Fonts().textW500(communityName, 14.0, Colors.black54, TextAlign.center),
              )
            ],
          ),
        ),
        preferredSize: Size.fromHeight(12.0),
      ),
    );
  }

  Widget actionAppBar(String appBarTitle, Widget actionWidget) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(appBarTitle, 20.0, Colors.black, TextAlign.center),
      leading: BackButton(color: Colors.black),
      actions: <Widget>[actionWidget],
    );
  }

  // ** APP BAR
}

class FABBottomAppBarItem {
  IconData iconData;
  String text;
  FABBottomAppBarItem({this.iconData, this.text});
}

class FABBottomAppBar extends StatefulWidget {
  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height: 55.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabItem({FABBottomAppBarItem item, int index, ValueChanged<int> onPressed}) {
    Color color = _selectedIndex == index ? FlatColors.webblenRed : FlatColors.lightAmericanGray;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: GestureDetector(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: widget.iconSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize + 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      color: widget.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items,
      ),
    );
  }
}
