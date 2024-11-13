import 'package:flutter/material.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
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
                  Theme.of(context).colorScheme.primary, // Dark green
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Icon(
                      Ionicons.information_circle_outline,
                      size: 40,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'About Us',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ]),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Track your Eco Choices, Amplify Green Voices.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                      'We aim to fulfill the growing need to monitor and improve ecological habits in a user-friendly and interactive manner. EcoTrecko educates society to make more conscious, environmentally-friendly choices, fostering positive impacts at both individual and collective levels.',
                      style: Theme.of(context).textTheme.displayMedium),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'The Team',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://www.linkedin.com/in/fc-carvalho/'),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage(
                                'lib/images/team/FilipeCarvalho.jpeg'),
                          ),
                          SizedBox(height: 8),
                          Text('Filipe Carvalho',
                              style: Theme.of(context).textTheme.displaySmall),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://www.linkedin.com/in/joana-matias-400b152a0/'),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage:
                                AssetImage('lib/images/team/JoanaMatias.jpeg'),
                          ),
                          SizedBox(height: 8),
                          Text('Joana Matias',
                              style: Theme.of(context).textTheme.displaySmall),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://www.linkedin.com/in/joao-brilha-37498b19b/'),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage:
                                AssetImage('lib/images/team/JoaoBrilha.jpeg'),
                          ),
                          SizedBox(height: 8),
                          Text('João Brilha',
                              style: Theme.of(context).textTheme.displaySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.linkedin.com/in/rita-martins-76533b225/'),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  'lib/images/team/RitaMartins.jpeg'),
                            ),
                            SizedBox(height: 8),
                            Text('Rita Martins',
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL(
                            'https://www.linkedin.com/in/yaroslav-hayduk-a1a563206/'),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  'lib/images/team/YaroslavHayduk.jpeg'),
                            ),
                            SizedBox(height: 8),
                            Text('Yaroslav Hayduk',
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
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
}
