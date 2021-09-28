import 'package:firebase_flutter_notes/utilities/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';

class MoreDrawer extends StatefulWidget {
  final User? user;
  const MoreDrawer({Key? key, required this.user}) : super(key: key);

  @override
  _MoreDrawerState createState() => _MoreDrawerState();
}

class _MoreDrawerState extends State<MoreDrawer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Expanded(child: ListView(children: _buildDrawerContent(context))),
            Container(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      Divider(
                        thickness: 2.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text('Choose theme'),
                                ),
                              )),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                // child: Icon(FontAwesomeIcons.moon, size: 20,),
                                child: Consumer<ThemeNotifier>(
                                  builder: (context, notifier, child) =>
                                      GestureDetector(
                                        onTap: (){
                                          notifier.toggleTheme();
                                        },
                                          child: Icon(
                                            Theme.of(context).brightness == Brightness.dark ?
                                    FontAwesomeIcons.sun : FontAwesomeIcons.moon,
                                    size: 20,
                                  )),

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ))),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerContent(BuildContext context) {
    final drawerContent = <Widget>[];
    drawerContent.add(_buildDrawerHeader());
    drawerContent.addAll(_buildDrawerBody(context));
    return drawerContent;
  }

  Widget _buildDrawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(widget.user!.displayName.toString()),
      accountEmail: Text(widget.user!.email.toString()),
      currentAccountPicture: CircleAvatar(
        backgroundImage: widget.user!.photoURL.toString().isNotEmpty
            ? CachedNetworkImageProvider(widget.user!.photoURL.toString())
            : null,
      ),
    );
  }

  List<Widget> _buildDrawerBody(BuildContext context) {
    return <Widget>[
      DrawerListTile(
        iconData: Icons.logout_outlined,
        title: 'Logout',
        onTilePressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  insetPadding: EdgeInsets.all(0),
                  title:
                      Text('Hello , ${widget.user!.displayName.toString()},'),
                  content: Text("Do you want to logout?"),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextButton(
                            child: Text("Yes"),
                            onPressed: () {
                              logoutUser();
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                );
              });
        },
      ),
    ];
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (route) => false);
  }
}

class DrawerListTile extends StatefulWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTilePressed;
  const DrawerListTile(
      {Key? key,
      required this.iconData,
      required this.title,
      required this.onTilePressed})
      : super(key: key);

  @override
  _DrawerListTileState createState() => _DrawerListTileState();
}

class _DrawerListTileState extends State<DrawerListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(widget.iconData),
      title: Text(widget.title, style: TextStyle(fontSize: 16)),
      onTap: widget.onTilePressed,
    );
  }
}
