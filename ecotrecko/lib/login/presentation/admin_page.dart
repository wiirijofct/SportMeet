// ignore_for_file: use_build_context_synchronously

import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<StatefulWidget> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<Map<String, Map<String, dynamic>>> _users;
  Map<String, Map<String, dynamic>> users = {};
  Map<String, Map<String, dynamic>> filteredUsers = {};
  late Future<Map<String, dynamic>> _permissions;
  late Future<Map<String, dynamic>> _adminInfo;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _permissions = Authentication.getPermissions();
    _users = User.getUserListMgmt();
    _adminInfo = User.getInfo();
    _searchController.addListener(_filterUsers);
  }

  Future<Future> _deleteButtonPressed(String username) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            'Delete $username',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          content: Text(
            'Are you sure you want to delete $username?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await Authentication.deleteAccount(username)) {
                  Navigator.of(context).pop(true);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        title: const Text('Success'),
                        content: const Text('User deleted successfully'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {
                    _users = User.getUserListMgmt();
                    users.remove(username);
                    _filterUsers();
                  });
                } else {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        title: const Text('Error'),
                        content: const Text('Failed to delete user'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                'Yes',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'No',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Future> _editButtonPressed(
      String username, Map<String, dynamic> data) async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = data['name'];
    final TextEditingController emailController = TextEditingController();
    emailController.text = data['email'];
    final TextEditingController phoneController = TextEditingController();
    phoneController.text = data['phoneNumber'];
    final TextEditingController countryCodeController = TextEditingController();
    countryCodeController.text = data['countryCode'];
    String profileStatus = data['isProfilePublic'] ? 'Public' : 'Private';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            'Edit $username',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                style: const TextStyle(color: Colors.black, fontSize: 15),
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  hintText: data['name'],
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: data['email'],
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CountryCodePicker(
                    onChanged: (value) {
                      setState(() {
                        countryCodeController.text = value.toString();
                      });
                    },
                    closeIcon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onTertiary,
                      size: 20,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    barrierColor: Theme.of(context).colorScheme.onPrimary,
                    initialSelection: data['countryCode'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    showFlag: false,
                    dialogBackgroundColor:
                        Theme.of(context).colorScheme.background,
                    dialogTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                    ),
                    searchDecoration: InputDecoration(
                        prefixIconColor:
                            Theme.of(context).colorScheme.onTertiary,
                        suffixIconColor:
                            Theme.of(context).colorScheme.onTertiary,
                        labelText: 'Country',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontSize: 16,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontSize: 16,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ))),
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              StatefulBuilder(builder: (context, setState) {
                return DropdownButton(
                  iconDisabledColor: Theme.of(context).colorScheme.onTertiary,
                  iconEnabledColor: Theme.of(context).colorScheme.onTertiary,
                  dropdownColor: Theme.of(context).colorScheme.onPrimary,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  value: profileStatus,
                  items: const [
                    DropdownMenuItem(
                      value: 'Public',
                      child: Text(
                        'Public',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Private',
                      child: Text('Private',
                          style: TextStyle(color: Colors.black, fontSize: 15)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      profileStatus = value!;
                    });
                  },
                );
              })
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await User.updateInfo(
                    username,
                    emailController.text,
                    nameController.text,
                    countryCodeController.text,
                    phoneController.text,
                    profileStatus)) {
                  Navigator.of(context).pop(true);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Success'),
                        content:
                            const Text('User properties updated successfully'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {
                    _users = User.getUserListMgmt();
                  });
                } else {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to update user info'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                'Save',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _unbanButtonPressed(String username) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text(
              'Unban $username?',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            content: Text("Are you sure you want to unban $username?"),
            actions: [
              TextButton(
                onPressed: () async {
                  if (await User.unban(username)) {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('User unbanned successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Failed to unban user'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text("I'm sure"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),
            ],
          );
        });
  }

  Future<Future<bool?>> _banButtonPressed(
      String username, Map<String, dynamic> data) async {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    const String permanent = "PERMANENT";
    const String temporary = "TEMPORARY";
    String? banType;
    const String fmt = 'dd-MM-yyyy HH:mm';
    int? banHours = 24;
    DateTime defaultUntil = DateTime.now().add(Duration(hours: banHours));
    dateController.text = DateFormat(fmt).format(defaultUntil);
    int banUntilmicroSecs = defaultUntil.microsecondsSinceEpoch;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text(
              'Ban $username',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 230),
                child: TextField(
                  controller: reasonController,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Ban Reason',
                    labelStyle: Theme.of(context).textTheme.headlineSmall,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    DropdownButton<String>(
                      iconDisabledColor:
                          Theme.of(context).colorScheme.onTertiary,
                      iconEnabledColor:
                          Theme.of(context).colorScheme.onTertiary,
                      dropdownColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      hint: Text(banType ?? "Ban Type",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "FredokaRegular",
                              color: Theme.of(context).colorScheme.onTertiary)),
                      items: [
                        DropdownMenuItem<String>(
                          value: temporary,
                          child: Text(temporary,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "FredokaRegular",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                        ),
                        DropdownMenuItem<String>(
                          value: permanent,
                          child: Text(permanent,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "FredokaRegular",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          banType = value!;
                        });
                      },
                    ),
                    if (banType == temporary)
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Ionicons.calendar_clear_outline,
                                color:
                                    Theme.of(context).colorScheme.onTertiary),
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  var datePlusCurrTime = pickedDate.add(
                                      Duration(
                                          hours: DateTime.now().hour,
                                          minutes: DateTime.now().minute));
                                  dateController.text =
                                      DateFormat(fmt).format(datePlusCurrTime);
                                  banUntilmicroSecs =
                                      datePlusCurrTime.microsecondsSinceEpoch;
                                  banHours = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          DropdownButton(
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "FredokaRegular",
                                color:
                                    Theme.of(context).colorScheme.onTertiary),
                            iconDisabledColor:
                                Theme.of(context).colorScheme.onTertiary,
                            iconEnabledColor:
                                Theme.of(context).colorScheme.onTertiary,
                            dropdownColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            hint: const Text("Ban for..."),
                            value: banHours,
                            items: [
                              const DropdownMenuItem(
                                value: 2,
                                child: Text('2 hours'),
                              ),
                              const DropdownMenuItem(
                                value: 6,
                                child: Text('6 hours'),
                              ),
                              const DropdownMenuItem(
                                value: 12,
                                child: Text('12 hours'),
                              ),
                              for (int i = 24; i <= 168; i += 24)
                                DropdownMenuItem(
                                  value: i,
                                  child: Text((i / 24).toString() +
                                      (i ~/ 24 == 1 ? " day" : " days")),
                                )
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  banHours = value;
                                  var banUntil = DateTime.now()
                                      .add(Duration(hours: banHours!));
                                  dateController.text =
                                      DateFormat(fmt).format(banUntil);
                                  banUntilmicroSecs =
                                      banUntil.microsecondsSinceEpoch;
                                });
                              }
                            },
                          ),
                        ],
                      )
                  ])),
              const SizedBox(height: 16),
              if (banType == temporary)
                TextFormField(
                  readOnly: true,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 15),
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Banned until',
                    labelStyle: TextStyle(
                      fontFamily: "FredokaRegular",
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    hintText: 'fmt',
                  ),
                ),
            ])),
            actions: [
              TextButton(
                onPressed: () async {
                  if (await User.ban(username, banUntilmicroSecs, banType!,
                      reasonController.text)) {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          title: const Text('Success'),
                          content: const Text('User banned successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          title: const Text('Error'),
                          content: const Text('Failed to ban user'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Ban',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future _permissionsButtonPressed(String username, int userPermCode,
      int userRoleCode, bool canEditRoles) async {
    var updatedUsers = await _users;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        int permCode = userPermCode;
        int roleCode = userRoleCode;
        int adminRoleCode = User.info['roleCode'];

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Text(
              'Permissions for $username\nCode: $permCode',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            content: Column(children: [
              if (adminRoleCode >= roleCode && canEditRoles)
                DropdownButton(
                  iconDisabledColor: Theme.of(context).colorScheme.onTertiary,
                  iconEnabledColor: Theme.of(context).colorScheme.onTertiary,
                  // dropdownColor: Theme.of(context).colorScheme.onPrimary,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  value: roleCode,
                  items: [
                    const DropdownMenuItem(
                      value: 0,
                      child: Text(
                        'Standard User',
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    if (adminRoleCode >= 100)
                      const DropdownMenuItem(
                        value: 100,
                        child: Text(
                          'Back Office',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    if (adminRoleCode >= 200)
                      const DropdownMenuItem(
                        value: 200,
                        child: Text('Admin',
                            style:
                                TextStyle(color: Colors.black, fontSize: 15)),
                      ),
                    if (adminRoleCode >= 300)
                      const DropdownMenuItem(
                        value: 300,
                        child: Text('Sudo',
                            style:
                                TextStyle(color: Colors.black, fontSize: 15)),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      roleCode = value!;
                    });
                  },
                ),
              Expanded(
                  child: SingleChildScrollView(
                child: FutureBuilder<Map<String, dynamic>>(
                    future: _permissions,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!.entries
                              .map((entry) => CheckboxListTile(
                                    title: Text(
                                      entry.key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    checkColor: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    hoverColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    activeColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    value: permCode & entry.value != 0,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value!) {
                                          permCode |= entry.value;
                                        } else {
                                          permCode &= ~entry.value;
                                        }
                                      });
                                    },
                                  ))
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    }),
              ))
            ]),
            actions: [
              TextButton(
                onPressed: () async {
                  if (await User.updatePermissions(username, permCode) &&
                      await User.updateRole(username, roleCode)) {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          title: const Text('Success'),
                          content:
                              const Text('Permissions updated successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {
                      updatedUsers[username]!['permissionCode'] = permCode;
                      updatedUsers[username]!['roleCode'] = roleCode;
                      _users = Future.value(updatedUsers);
                    });
                  } else {
                    return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          title: const Text('Error'),
                          content:
                              const Text('Failed to update user permissions'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Future _logsButtonPressed(String username) async {
    List<Map<String, dynamic>> logs = await User.getLogs(username);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: Text(
            'Logs for $username',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('City')),
                    DataColumn(label: Text('Host')),
                    DataColumn(label: Text('IP')),
                    DataColumn(label: Text('Success')),
                    DataColumn(label: Text('Time')),
                  ],
                  rows: logs
                      .map((log) => DataRow(cells: [
                            DataCell(Text(log['city'] ?? "No City")),
                            DataCell(Text(log['host'])),
                            DataCell(Text(log['ip'])),
                            DataCell(Text(log['success'].toString())),
                            DataCell(Text(DateFormat('dd-MM-yyyy HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    log['time']['seconds'] * 1000)))),
                          ]))
                      .toList(),
                ),
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future _statsButtonPressed(String username) async {
    print("TODO");
  }

  Row _statsButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _statsButtonPressed(username);
        },
        child: Icon(
          Ionicons.stats_chart_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _logsButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _logsButtonPressed(username);
        },
        child: Icon(
          Ionicons.receipt_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _editButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _editButtonPressed(username, data);
        },
        child: Icon(
          Icons.edit_outlined,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _permissionsButton(
      String username, Map<String, dynamic> data, bool canEditRoles) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _permissionsButtonPressed(
              username, data['permissionCode'], data['roleCode'], canEditRoles);
        },
        child: Icon(
          Ionicons.hand_right_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _banButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _banButtonPressed(username, data);
        },
        child: Icon(
          Ionicons.ban_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _unbanButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _unbanButtonPressed(username);
        },
        child: Icon(
          Ionicons.bandage_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  Row _deleteButton(String username, Map<String, dynamic> data) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _deleteButtonPressed(username);
        },
        child: Icon(
          Ionicons.trash_outline,
          color: Theme.of(context).colorScheme.onTertiary,
          size: 20,
        ),
      ),
    ]);
  }

  bool _checkPermissions(int perm) {
    var info = User.info;

    return ((info['permissionCode'] & 1) != 0 ||
        (info['permissionCode'] & perm) != 0);
  }

  List<ListTile> _buildList(
      Map<String, Map<String, dynamic>> userMap, Map<String, dynamic> perms) {
    return userMap.entries
        .map((entry) => ListTile(
              title: Text(entry.key,
                  style: Theme.of(context).textTheme.labelMedium),
              subtitle: Text(
                  "\t${entry.value['name']}\n\t\t${entry.value['email']}\n\t\t${entry.value['countryCode']} ${entry.value['phoneNumber']}",
                  style: Theme.of(context).textTheme.bodySmall),
              trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // if (_checkPermissions(perms['VIEW_STATS']))
                    //   _statsButton(entry.key, entry.value),
                    if (_checkPermissions(perms['VIEW_LOGS']))
                      _logsButton(entry.key, entry.value),
                    if (_checkPermissions(perms['EDIT_PERMS']))
                      _permissionsButton(entry.key, entry.value,
                          _checkPermissions(perms['EDIT_ROLES'])),
                    if (_checkPermissions(perms['EDIT_OTHERS']))
                      _editButton(entry.key, entry.value),
                    if (_checkPermissions(perms['BAN']) &&
                        entry.value['status'] != "BANNED")
                      _banButton(entry.key, entry.value),
                    if (_checkPermissions(perms['UNBAN']) &&
                        entry.value['status'] == "BANNED")
                      _unbanButton(entry.key, entry.value),
                    if (_checkPermissions(perms['REMOVE_OTHERS']))
                      _deleteButton(entry.key, entry.value),
                  ]),
            ))
        .toList();
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _adminInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.background,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.build_outline,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Admin Panel',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Ionicons.arrow_back_circle_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                      size: 30,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              suffixIconColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              prefixIconColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              hintText: 'Search users',
                              hintStyle: TextStyle(
                                fontFamily: 'FredokaRegular',
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                              ),
                              prefixIcon: Icon(
                                Ionicons.search_outline,
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 20,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'FredokaRegular',
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                            child: SingleChildScrollView(
                                child: FutureBuilder<List<dynamic>>(
                                    future: Future.wait([_users, _permissions]),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        users = snapshot.data![0];
                                        if (filteredUsers.isEmpty) {
                                          filteredUsers = users;
                                        }

                                        var permissionsData = snapshot.data![1];
                                        return Column(
                                          children: _buildList(
                                              filteredUsers, permissionsData),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      }
                                      return const CircularProgressIndicator();
                                    }))),
                      ]),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredUsers = Map.fromEntries(users.entries.where((entry) =>
          entry.key.toLowerCase().contains(query) ||
          entry.value['name'].toLowerCase().contains(query) ||
          entry.value['email'].toLowerCase().contains(query) ||
          entry.value['phoneNumber'].toLowerCase().contains(query)));
    });
  }
}
