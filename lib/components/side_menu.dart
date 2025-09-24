import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth.dart';
import '../constants.dart';
import '../responsive.dart';

class SideMenu extends StatefulWidget {
  final int pageIndex;
  final String image;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;

  const SideMenu({
    super.key,
    required this.pageIndex,
    required this.onItemTapped,
    required this.onTitleTapped, required this.image,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
  String userRole = '';
  String userName = '';
  String userImage = '';
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
      userName = "${prefs.getString('first_name')} ${prefs.getString('last_name')}";
      userImage = prefs.getString('role') ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: secondaryColor,
        child: Stack(
          children: [
            ListView(
              children: [
                DrawerHeader(
                  child: Container(
                    alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 24,horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              )
            ]),
        child: Row(
          spacing: 8,
          children: [
            Container(
              padding:EdgeInsets.all(12),
              child:  Image.asset(
                "assets/images/logo.png",
                height: 42,
              ),),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Migrantifly 1.0",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  "© Emnac Tech",style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ],
        )),
                ),
                DrawerListTile(
                  title: "Dashboard",
                  svgSrc: "assets/icons/dashboard.svg",
                  press: () {
                    widget.onItemTapped(0);
                    widget.onTitleTapped("Dashboard"); // Pass the title when tapped
                  },
                  isActive: widget.pageIndex == 0,
                ),
                if (userRole.toLowerCase() != "client")
                DrawerListTile(
                  title: "Users",
                  svgSrc: "assets/icons/users.svg",
                  press: () {
                    widget.onItemTapped(1);
                    widget.onTitleTapped("Users");
                  },
                  isActive: widget.pageIndex == 1,
                ),
                if (userRole.toLowerCase() != "client")
                  DrawerListTile(
                  title: "Applications",
                  svgSrc: "assets/icons/applications.svg",
                  press: () {
                    widget.onItemTapped(2);
                    widget.onTitleTapped("Applications");
                  },
                  isActive: widget.pageIndex == 2,
                ), if (!Responsive.isMobile(context) && userRole.toLowerCase() != "client")
                  DrawerListTile(
                    title: "Calendar",
                    svgSrc: "assets/icons/calendar.svg",
                    press: () {
                      widget.onItemTapped(3);
                      widget.onTitleTapped("Calendar");
                    },
                    isActive: widget.pageIndex == 3,
                  ),
                if (userRole.toLowerCase() != "client")
                  DrawerListTile(
                  title: "Consultations",
                  svgSrc: "assets/icons/consultations.svg",
                  press: () {
                    widget.onItemTapped(4);
                    widget.onTitleTapped("Consultations");
                  },
                  isActive: widget.pageIndex == 4,
                ),
                if (userRole.toLowerCase() != "client")
                  DrawerListTile(
                  title: "Documents",
                  svgSrc: "assets/icons/documents.svg",
                  press: () {
                    widget.onItemTapped(5);
                    widget.onTitleTapped("Documents");
                  },
                  isActive: widget.pageIndex == 5,
                ),
                if (userRole.toLowerCase() == "admin")
                DrawerListTile(
                  title: "Transactions",
                  svgSrc: "assets/icons/transactions.svg",
                  press: () {
                    widget.onItemTapped(8);
                    widget.onTitleTapped("Transactions");
                  },
                  isActive: widget.pageIndex == 8,
                ),

                SizedBox(
                  height: 110,
                )
              ],
            ),
            Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Column(
                  spacing: 8,
                  children: [
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tileColor: Colors.red.withOpacity(0.2),
                    onTap: (){signOut(context: context);},
                    leading:
                    Icon(Icons.logout_rounded,color: Colors.red,size: 24,)
                   ,
                    title: Text(
                      "Log Out",
                      style: TextStyle(
                        color:Colors.red,
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                            )
                          ]),
                      child: Row(
                        spacing: 8,
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  )
                                ]),child: CachedNetworkImage(
                            alignment:Alignment.topCenter,
                            imageUrl: widget.image,
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52,
                            placeholder: (context, url) =>Icon(Icons.person_rounded, size: 100),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.person_rounded, size: 42),
                          ),),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                userRole,
                              )
                            ],
                          ),
                        ],
                      ))
                ],))
          ],
        ));
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.isActive,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? Color(0XFF2F80ED).withOpacity(0.2) : null,
        onTap: press,
        leading: SvgPicture.asset(
          svgSrc,
          colorFilter: ColorFilter.mode(
              isActive ? Colors.blue : Colors.black54, BlendMode.srcIn),
          height: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
