import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/coming_soon_page.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';

import 'package:ecotrecko/login/theme_page.dart';
import 'package:ecotrecko/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static TextEditingController newPasswordController = TextEditingController();
  
  void privacyButtonPressed() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(
              '''Privacy Policy
==============

Last updated: July 15, 2024

This Privacy Policy describes Our policies and procedures on the collection,
use and disclosure of Your information when You use the Service and tells You
about Your privacy rights and how the law protects You.

We use Your Personal data to provide and improve the Service. By using the
Service, You agree to the collection and use of information in accordance with
this Privacy Policy. This Privacy Policy has been created with the help of the
Privacy Policy Generator.

Interpretation and Definitions
------------------------------

Interpretation
~~~~~~~~~~~~~~

The words of which the initial letter is capitalized have meanings defined
under the following conditions. The following definitions shall have the same
meaning regardless of whether they appear in singular or in plural.

Definitions
~~~~~~~~~~~

For the purposes of this Privacy Policy:

  * Account means a unique account created for You to access our Service or
    parts of our Service.

  * Affiliate means an entity that controls, is controlled by or is under
    common control with a party, where "control" means ownership of 50% or
    more of the shares, equity interest or other securities entitled to vote
    for election of directors or other managing authority.

  * Application refers to EcoTrecko, the software program provided by the
    Company.

  * Company (referred to as either "the Company", "We", "Us" or "Our" in this
    Agreement) refers to Green++, Universidade Nova de Lisboa.

  * Cookies are small files that are placed on Your computer, mobile device or
    any other device by a website, containing the details of Your browsing
    history on that website among its many uses.

  * Country refers to: Portugal

  * Device means any device that can access the Service such as a computer, a
    cellphone or a digital tablet.

  * Personal Data is any information that relates to an identified or
    identifiable individual.

  * Service refers to the Application or the Website or both.

  * Service Provider means any natural or legal person who processes the data
    on behalf of the Company. It refers to third-party companies or
    individuals employed by the Company to facilitate the Service, to provide
    the Service on behalf of the Company, to perform services related to the
    Service or to assist the Company in analyzing how the Service is used.

  * Usage Data refers to data collected automatically, either generated by the
    use of the Service or from the Service infrastructure itself (for example,
    the duration of a page visit).

  * Website refers to EcoTrecko, accessible from
    <https://ecotrecko.nw.r.appspot.com/>

  * You means the individual accessing or using the Service, or the company,
    or other legal entity on behalf of which such individual is accessing or
    using the Service, as applicable.


Collecting and Using Your Personal Data
---------------------------------------

Types of Data Collected
~~~~~~~~~~~~~~~~~~~~~~~

Personal Data
*************

While using Our Service, We may ask You to provide Us with certain personally
identifiable information that can be used to contact or identify You.
Personally identifiable information may include, but is not limited to:

  * Email address

  * First name and last name

  * Phone number

  * Usage Data


Usage Data
**********

Usage Data is collected automatically when using the Service.

Usage Data may include information such as Your Device's Internet Protocol
address (e.g. IP address), browser type, browser version, the pages of our
Service that You visit, the time and date of Your visit, the time spent on
those pages, unique device identifiers and other diagnostic data.

When You access the Service by or through a mobile device, We may collect
certain information automatically, including, but not limited to, the type of
mobile device You use, Your mobile device unique ID, the IP address of Your
mobile device, Your mobile operating system, the type of mobile Internet
browser You use, unique device identifiers and other diagnostic data.

We may also collect information that Your browser sends whenever You visit our
Service or when You access the Service by or through a mobile device.

Information Collected while Using the Application
*************************************************

While using Our Application, in order to provide features of Our Application,
We may collect, with Your prior permission:

  * Information regarding your location

  * Pictures and other information from your Device's camera and photo library


We use this information to provide features of Our Service, to improve and
customize Our Service. The information may be uploaded to the Company's
servers and/or a Service Provider's server or it may be simply stored on Your
device.

You can enable or disable access to this information at any time, through Your
Device settings.

Tracking Technologies and Cookies
*********************************

We use Cookies and similar tracking technologies to track the activity on Our
Service and store certain information. Tracking technologies used are beacons,
tags, and scripts to collect and track information and to improve and analyze
Our Service. The technologies We use may include:


Cookies can be "Persistent" or "Session" Cookies. Persistent Cookies remain on
Your personal computer or mobile device when You go offline, while Session
Cookies are deleted as soon as You close Your web browser. You can learn more
about cookies on the TermsFeed website article.

We use both Session and Persistent Cookies for the purposes set out below:

  * Necessary / Essential Cookies

    Type: Session Cookies

    Administered by: Us

    Purpose: These Cookies are essential to provide You with services
    available through the Website and to enable You to use some of its
    features. They help to authenticate users and prevent fraudulent use of
    user accounts. Without these Cookies, the services that You have asked for
    cannot be provided, and We only use these Cookies to provide You with
    those services.

  * Cookies Policy / Notice Acceptance Cookies

    Type: Persistent Cookies

    Administered by: Us

    Purpose: These Cookies identify if users have accepted the use of cookies
    on the Website.

  * Functionality Cookies

    Type: Persistent Cookies

    Administered by: Us

    Purpose: These Cookies allow us to remember choices You make when You use
    the Website, such as remembering your login details or language
    preference. The purpose of these Cookies is to provide You with a more
    personal experience and to avoid You having to re-enter your preferences
    every time You use the Website.

For more information about the cookies we use and your choices regarding
cookies, please visit our Cookies Policy or the Cookies section of our Privacy
Policy.

Use of Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~

The Company may use Personal Data for the following purposes:

  * To provide and maintain our Service , including to monitor the usage of
    our Service.

  * To manage Your Account: to manage Your registration as a user of the
    Service. The Personal Data You provide can give You access to different
    functionalities of the Service that are available to You as a registered
    user.

  * For the performance of a contract: the development, compliance and
    undertaking of the purchase contract for the products, items or services
    You have purchased or of any other contract with Us through the Service.

  * To contact You: To contact You by email, telephone calls, SMS, or other
    equivalent forms of electronic communication, such as a mobile
    application's push notifications regarding updates or informative
    communications related to the functionalities, products or contracted
    services, including the security updates, when necessary or reasonable for
    their implementation.

  * To provide You with news, special offers and general information about
    other goods, services and events which we offer that are similar to those
    that you have already purchased or enquired about unless You have opted
    not to receive such information.

  * To manage Your requests: To attend and manage Your requests to Us.

  * For business transfers: We may use Your information to evaluate or conduct
    a merger, divestiture, restructuring, reorganization, dissolution, or
    other sale or transfer of some or all of Our assets, whether as a going
    concern or as part of bankruptcy, liquidation, or similar proceeding, in
    which Personal Data held by Us about our Service users is among the assets
    transferred.

  * For other purposes : We may use Your information for other purposes, such
    as data analysis, identifying usage trends, determining the effectiveness
    of our promotional campaigns and to evaluate and improve our Service,
    products, services, marketing and your experience.


We may share Your personal information in the following situations:

  * With Service Providers: We may share Your personal information with
    Service Providers to monitor and analyze the use of our Service, to
    contact You.
  * For business transfers: We may share or transfer Your personal information
    in connection with, or during negotiations of, any merger, sale of Company
    assets, financing, or acquisition of all or a portion of Our business to
    another company.
  * With Affiliates: We may share Your information with Our affiliates, in
    which case we will require those affiliates to honor this Privacy Policy.
    Affiliates include Our parent company and any other subsidiaries, joint
    venture partners or other companies that We control or that are under
    common control with Us.
  * With business partners: We may share Your information with Our business
    partners to offer You certain products, services or promotions.
  * With other users: when You share personal information or otherwise
    interact in the public areas with other users, such information may be
    viewed by all users and may be publicly distributed outside.
  * With Your consent : We may disclose Your personal information for any
    other purpose with Your consent.

Retention of Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Company will retain Your Personal Data only for as long as is necessary
for the purposes set out in this Privacy Policy. We will retain and use Your
Personal Data to the extent necessary to comply with our legal obligations
(for example, if we are required to retain your data to comply with applicable
laws), resolve disputes, and enforce our legal agreements and policies.

The Company will also retain Usage Data for internal analysis purposes. Usage
Data is generally retained for a shorter period of time, except when this data
is used to strengthen the security or to improve the functionality of Our
Service, or We are legally obligated to retain this data for longer time
periods.

Transfer of Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Your information, including Personal Data, is processed at the Company's
operating offices and in any other places where the parties involved in the
processing are located. It means that this information may be transferred to —
and maintained on — computers located outside of Your state, province, country
or other governmental jurisdiction where the data protection laws may differ
than those from Your jurisdiction.

Your consent to this Privacy Policy followed by Your submission of such
information represents Your agreement to that transfer.

The Company will take all steps reasonably necessary to ensure that Your data
is treated securely and in accordance with this Privacy Policy and no transfer
of Your Personal Data will take place to an organization or a country unless
there are adequate controls in place including the security of Your data and
other personal information.

Delete Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~

You have the right to delete or request that We assist in deleting the
Personal Data that We have collected about You.

Our Service may give You the ability to delete certain information about You
from within the Service.

You may update, amend, or delete Your information at any time by signing in to
Your Account, if you have one, and visiting the account settings section that
allows you to manage Your personal information. You may also contact Us to
request access to, correct, or delete any personal information that You have
provided to Us.

Please note, however, that We may need to retain certain information when we
have a legal obligation or lawful basis to do so.

Disclosure of Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Business Transactions
*********************

If the Company is involved in a merger, acquisition or asset sale, Your
Personal Data may be transferred. We will provide notice before Your Personal
Data is transferred and becomes subject to a different Privacy Policy.

Law enforcement
***************

Under certain circumstances, the Company may be required to disclose Your
Personal Data if required to do so by law or in response to valid requests by
public authorities (e.g. a court or a government agency).

Other legal requirements
************************

The Company may disclose Your Personal Data in the good faith belief that such
action is necessary to:

  * Comply with a legal obligation
  * Protect and defend the rights or property of the Company
  * Prevent or investigate possible wrongdoing in connection with the Service
  * Protect the personal safety of Users of the Service or the public
  * Protect against legal liability

Security of Your Personal Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The security of Your Personal Data is important to Us, but remember that no
method of transmission over the Internet, or method of electronic storage is
100% secure. While We strive to use commercially acceptable means to protect
Your Personal Data, We cannot guarantee its absolute security.


Links to Other Websites
-----------------------

Our Service may contain links to other websites that are not operated by Us.
If You click on a third party link, You will be directed to that third party's
site. We strongly advise You to review the Privacy Policy of every site You
visit.

We have no control over and assume no responsibility for the content, privacy
policies or practices of any third party sites or services.

Changes to this Privacy Policy
------------------------------

We may update Our Privacy Policy from time to time. We will notify You of any
changes by posting the new Privacy Policy on this page.

We will let You know via email and/or a prominent notice on Our Service, prior
to the change becoming effective and update the "Last updated" date at the top
of this Privacy Policy.

You are advised to review this Privacy Policy periodically for any changes.
Changes to this Privacy Policy are effective when they are posted on this
page.

Contact Us
----------

If you have any questions about this Privacy Policy, You can contact us:

  * By email: ecotrecko@gmail.com
''', style: TextStyle(color: Theme.of(context).colorScheme.onTertiary, fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.onTertiary, fontFamily: "FredokaRegular")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void profileButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void themeButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemePage(),
      ),
    );
  }

  void comingSoonButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComingSoonPage(),
      ),
    );
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    bool pwCompliant = Authentication.isPasswordCompliant(newPassword);

    if (!pwCompliant) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Invalid password format!"),
          );
        },
      );
      return false;
    } else if (await User.updatePassword(oldPassword, newPassword)) {
      // username, password, newPassword, confirmation)) {
      return true;
    } else {
      return false;
    }
  }

  void showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String currentPassword = '';
    String newPassword = '';
    String confirmation = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Change Password',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall, // Alterando a cor do label para branco
                    errorStyle: Theme.of(context)
                        .textTheme
                        .displayLarge, // Alterando a cor do texto de erro para vermelho
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    hintStyle: Theme.of(context).textTheme.headlineSmall,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  onSaved: (value) => currentPassword = value ?? '',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: Theme.of(context)
                          .textTheme
                          .headlineSmall, // Alterando a cor do label para branco
                      errorStyle: Theme.of(context).textTheme.displayLarge,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      hintStyle: Theme.of(context).textTheme.headlineSmall,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password';
                      }
                      return null;
                    },
                    onSaved: (value) => newPassword = value ?? '',
                  ),
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall, // Alterando a cor do label para branco
                    errorStyle: Theme.of(context).textTheme.displayLarge,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    hintStyle: Theme.of(context).textTheme.headlineSmall,
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onSaved: (value) => confirmation = value ?? '',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: Theme.of(context).textTheme.headlineSmall),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit',
                  style: Theme.of(context).textTheme.headlineSmall),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final response =
                      await updatePassword(currentPassword, newPassword);
                  showDialog(
                    context: context,
                    builder: (context) {
                      if (response) {
                        return AlertDialog(
                          title: const Text('Response'),
                          content: const Text("Password changed successfully"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                newPasswordController.clear();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: const Text('Response'),
                          content: const Text(
                              "Couldn't change password. Please try again."),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Ionicons.settings_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                buildSettingsSection(context,
                    title: 'Account Settings',
                    settings: [
                      buildSettingsTile(
                        context,
                        icon: Ionicons.person_outline,
                        title: 'Edit Profile',
                        onTap: profileButtonPressed,
                      ),
                      buildSettingsTile(
                        context,
                        icon: Ionicons.key_outline,
                        title: 'Change Password',
                        onTap: () => showChangePasswordDialog(context),
                      ),
                      buildSettingsTile(
                        context,
                        icon: Ionicons.lock_closed_outline,
                        title: 'Privacy & Security',
                        onTap: privacyButtonPressed,
                      ),
                    ]),
                const SizedBox(height: 24),
                buildSettingsSection(context, title: 'App Settings', settings: [
                  buildSettingsTile(
                    context,
                    icon: Ionicons.color_palette_outline,
                    title: 'Theme',
                    onTap: themeButtonPressed,
                  ),
                ]),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Ionicons.arrow_back_circle_outline,
                            color: Theme.of(context).colorScheme.onTertiary,
                            size: 30,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsSection(BuildContext context,
      {required String title, required List<Widget> settings}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 16),
        Column(
          children: settings,
        ),
      ],
    );
  }

  Widget buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.onTertiary),
          title: Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          onTap: onTap,
        ),
        Divider(color: Theme.of(context).colorScheme.onTertiary),
      ],
    );
  }
}
