import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ecotrecko/login/presentation/home_page.dart'; // Verify if this path is correct to import the home page

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({
    super.key,
  });

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  sendFriendRequest(BuildContext context) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
              Positioned(
                top: 10,
                right: 30,
                child: Row(
                  children: [
                    SizedBox(height:40),
                    IconButton(
                      icon: Icon(
                        Ionicons.arrow_back_circle_outline,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 30,
                      ),
                      onPressed: () => navigateToHomePage(context),
                    ),
                    GestureDetector(
                      onTap: () => navigateToHomePage(context),
                      child: Text(
                        'Go Back To Homepage',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "OI",
                          // username,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: "FredokaRegular",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 120,
                left: MediaQuery.of(context).size.width / 2 - 75,
                child: Container(
                  width: 150,
                  height: 60,
                  decoration: BoxDecoration(
                     color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "2",
                          
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            'Friends',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary,
                                fontFamily: "FredokaRegular",
                              ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "?",
                            // score.toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            'Score',
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary,
                                fontFamily: "FredokaRegular",
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Ionicons.lock_closed_outline,
                    size: 50,
                    color:Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "This profile is private.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            
                          title: Text('Friend Request Sent', style: Theme.of(context).textTheme.labelMedium),
                          content: Text('Your friend request has been sent!', style: Theme.of(context).textTheme.headlineSmall),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK',  style: Theme.of(context).textTheme.headlineSmall),
                              onPressed: () {
                                Navigator.of(context).pop(); // Fecha o diálogo
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.background,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Ionicons.person_add_outline,
                          size: 35,
                          color:Theme.of(context).colorScheme.onSecondary,
                        ),
                        Text(
                          "Add friend",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontFamily: "FredokaRegular",
                          ),
                        ),
                      ],
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
}
