import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../controllers/menu_app_controller.dart';
import '../responsive.dart';

class Header extends StatefulWidget {
  final String title;

  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  const Header({
    Key? key,
    required this.title,
    required this.onItemTapped,
    required this.onTitleTapped,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Row(
            spacing: 8,
            children: [
              SvgPicture.asset(
                "assets/icons/${widget.title.toLowerCase()}.svg",
                color: Colors.grey,height: 24,
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
        if (!Responsive.isMobile(context)) SizedBox(width: 12),
        Expanded(child: SearchField()),
      ],
    );
  }

}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Icon(
              Icons.search_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
