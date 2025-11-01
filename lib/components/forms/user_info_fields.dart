import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../models/class_users.dart';
import '../../responsive.dart';
import '../input/input_drop_down.dart';
import '../input/input_field.dart';

class UserInfoFields extends StatefulWidget {
  final User user;
  const UserInfoFields({super.key, required this.user});

  @override
  State<UserInfoFields> createState() => _UserInfoFieldsState();
}

class _UserInfoFieldsState extends State<UserInfoFields> {
  // Controllers scoped to the state
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();
  final _entityDescController = TextEditingController();
  final _representedCountryController = TextEditingController();
  final _countryLocatedController = TextEditingController();


  // Dropdown values
  String _selectedRole = '';

  final List<String> role = [
    'client','admin','adviser',
  ];
  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _fullNameController.text = widget.user.fullName;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phoneNumber;
    _idController.text = widget.user.id;
    _entityDescController.text = widget.user.fullAddress;
    _representedCountryController.text = widget.user.representedCountry;
    _countryLocatedController.text = widget.user.countryLocated;
    getUserInfo();
  }
  String userRole = '';
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "User Details: ${widget.user.id}",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    CloseButton()
                  ],
                ),
                // Profile & Actions for desktop
                if (Responsive.isDesktop(context)) ...[
                  const Divider(),
                  const SizedBox(height: defaultPadding),
                ],
                const SizedBox(height: defaultPadding),

                Row(spacing: defaultPadding,
                  children: [
                    Expanded(child: Inputfield(
                      inputTitle: 'Full Name',
                      inputHintText: 'Enter full name',
                      textController: _fullNameController,
                      textObscure: false,
                      isreadOnly: true,
                    )),
                   Expanded(child:  Inputfield(
                     inputTitle: 'Email',
                     inputHintText: 'Enter email address',
                     textController: _emailController,
                     textObscure: false,
                     isreadOnly: true,
                   )),

                  ],
                ),

                const SizedBox(height: defaultPadding),

                Row(spacing: defaultPadding,
                  children: [
                    userRole.toLowerCase().contains("admin")?
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 12,
                          ),
                          const Text('User Role',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          InputDropDown(
                            value: _selectedRole,
                            items: role,
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                        ],
                      ),
                    ):Expanded(child:  Inputfield(
                      inputTitle: 'User Role',
                      inputHintText: 'User Role',
                      textController: TextEditingController(text: widget.user.role),
                      textObscure: false,
                      isreadOnly: true,
                    )),
                    Expanded(child:  Inputfield(
                      inputTitle: 'Phone Number',
                      inputHintText: 'Enter phone number',
                      textController: _phoneController,
                      textObscure: false,
                      isreadOnly: true,
                    ))
                  ],
                ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        const SizedBox(height: defaultPadding + 8),
                        Text("Address",style:TextStyle(fontWeight:FontWeight.w700)),
                        const SizedBox(height: defaultPadding),
                        Text(widget.user.fullAddress),

                      ]),


                const SizedBox(height: 40),
                if(userRole.toLowerCase().contains("admin"))
                // Submit button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // TODO: Save logic
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )),
    );
  }

  double _fieldWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Responsive.isDesktop(context) ? width / 5 : width / 2.3;
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.blue),
        onPressed: onTap,
      ),
    );
  }
}
