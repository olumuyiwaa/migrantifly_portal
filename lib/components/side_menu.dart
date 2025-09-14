import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/auth.dart';
import '../constants.dart';
import '../responsive.dart';

class SideMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: secondaryColor,
        child: Stack(
          children: [
            ListView(
              children: [
                DrawerHeader(
                  child: Container(
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
                        imageUrl: image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) =>
                            Image.asset("assets/images/logo.png"),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.person_rounded, size: 100),
                      ),),
                ),
                DrawerListTile(
                  title: "Dashboard",
                  svgSrc: "assets/icons/dashboard.svg",
                  press: () {
                    onItemTapped(0);
                    onTitleTapped("Dashboard"); // Pass the title when tapped
                  },
                  isActive: pageIndex == 0,
                ),
                DrawerListTile(
                  title: "Users",
                  svgSrc: "assets/icons/users.svg",
                  press: () {
                    onItemTapped(1);
                    onTitleTapped("Users");
                  },
                  isActive: pageIndex == 1,
                ),
                DrawerListTile(
                  title: "Applications",
                  svgSrc: "assets/icons/events.svg",
                  press: () {
                    onItemTapped(2);
                    onTitleTapped("Applications");
                  },
                  isActive: pageIndex == 2,
                ), if (!Responsive.isMobile(context))
                  DrawerListTile(
                    title: "Calendar",
                    svgSrc: "assets/icons/calendar.svg",
                    press: () {
                      onItemTapped(3);
                      onTitleTapped("Calendar");
                    },
                    isActive: pageIndex == 3,
                  ),DrawerListTile(
                  title: "Market",
                  svgSrc: "assets/icons/market.svg",
                  press: () {
                    onItemTapped(4);
                    onTitleTapped("Market");
                  },
                  isActive: pageIndex == 4,
                ),
                DrawerListTile(
                  title: "Countries",
                  svgSrc: "assets/icons/countries.svg",
                  press: () {
                    onItemTapped(5);
                    onTitleTapped("Countries");
                  },
                  isActive: pageIndex == 5,
                ),
                DrawerListTile(
                  title: "Transactions",
                  svgSrc: "assets/icons/transactions.svg",
                  press: () {
                    onItemTapped(8);
                    onTitleTapped("Transactions");
                  },
                  isActive: pageIndex == 8,
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
                          Image.asset(
                            "assets/images/logo.png",
                            height: 52,
                          ),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Migrantifly 1.0",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                "© Emnac Tech",
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
