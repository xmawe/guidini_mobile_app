import 'package:flutter/material.dart';
import '../utils/string_utils.dart';
import '../widgets/chat/chat_header.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testNames = [
      'Mohamed Jahid',
      'Ahmed El Yassifi',
      'Mohamed Ibrahim',
      'Karim Idriss',
      'Yasmine Alami',
      'John Doe',
      'A B',
      ' ',
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Avatars'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Avatar Tests'),
              Tab(text: 'Header Test'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab - Avatar tests
            ListView.builder(
              itemCount: testNames.length,
              itemBuilder: (context, index) {
                final name = testNames[index];
                final initials = StringUtils.getInitials(name);
                
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: Colors.pink[700],
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Initials: $initials',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Second tab - Header test
            Column(
              children: [
                ChatHeader(
                  userName: 'Ahmed El Yassifi',
                  userLocation: 'Unknown location',
                  rating: 4.5,
                  isOnline: true,
                ),
                const Divider(),
                ChatHeader(
                  userName: 'Mohamed Jahid',
                  userLocation: 'Marrakech, Morocco',
                  rating: 4.8,
                  isOnline: false,
                ),
                const Divider(),
                ChatHeader(
                  userName: 'J D',
                  userLocation: 'Casablanca, Morocco',
                  rating: 4.2,
                  isOnline: true,
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }
} 