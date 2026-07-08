import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8FAFC),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            const Text(

              "Profile",

              style: TextStyle(

                fontSize: 34,

                fontWeight:
                FontWeight.bold,

                color:
                Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 30),

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(24),

              decoration: BoxDecoration(

                gradient:
                const LinearGradient(

                  colors: [

                    Color(0xFF2563EB),

                    Color(0xFF1D4ED8),
                  ],
                ),

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: [

                  BoxShadow(

                    color:
                    Colors.blue.withOpacity(0.25),

                    blurRadius: 25,

                    offset:
                    const Offset(0, 12),
                  ),
                ],
              ),

              child: Column(

                children: [

                  Container(

                    width: 90,

                    height: 90,

                    decoration: BoxDecoration(

                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(30),
                    ),

                    child: const Icon(

                      Icons.person_rounded,

                      size: 50,

                      color:
                      Color(0xFF2563EB),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(

                    "CashSwap User",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 24,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(

                    "Trusted Exchange Member",

                    style: TextStyle(

                      color: Colors.white70,

                      fontSize: 15,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(

              children: [

                Expanded(

                  child: buildStatCard(

                    title:
                    "Completed",

                    value:
                    "12",

                    icon:
                    Icons.check_circle,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(

                  child: buildStatCard(

                    title:
                    "Rating",

                    value:
                    "4.9",

                    icon:
                    Icons.star,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 16),

            Row(

              children: [

                Expanded(

                  child: buildStatCard(

                    title:
                    "Requests",

                    value:
                    "27",

                    icon:
                    Icons.swap_horiz,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(

                  child: buildStatCard(

                    title:
                    "Trust",

                    value:
                    "High",

                    icon:
                    Icons.verified,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 35),

            const Text(

              "Account Settings",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color:
                Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 20),

            buildMenuTile(

              icon:
              Icons.notifications_rounded,

              title:
              "Notifications",
            ),

            buildMenuTile(

              icon:
              Icons.lock_rounded,

              title:
              "Privacy & Security",
            ),

            buildMenuTile(

              icon:
              Icons.history_rounded,

              title:
              "Transaction History",
            ),

            buildMenuTile(

              icon:
              Icons.help_outline_rounded,

              title:
              "Help & Support",
            ),

          ],
        ),
      ),
    );
  }

  Widget buildStatCard({

    required String title,

    required String value,

    required IconData icon,
  }) {

    return Container(

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(25),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 15,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(

            icon,

            color:
            const Color(0xFF2563EB),

            size: 30,
          ),

          const SizedBox(height: 15),

          Text(

            value,

            style: const TextStyle(

              fontSize: 28,

              fontWeight:
              FontWeight.bold,

              color:
              Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 5),

          Text(

            title,

            style: const TextStyle(

              color: Colors.grey,

              fontSize: 15,
            ),
          ),

        ],
      ),
    );
  }

  Widget buildMenuTile({

    required IconData icon,

    required String title,
  }) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.04),

            blurRadius: 12,
          ),
        ],
      ),

      child: ListTile(

        leading: Container(

          padding:
          const EdgeInsets.all(10),

          decoration: BoxDecoration(

            color:
            const Color(0xFFDBEAFE),

            borderRadius:
            BorderRadius.circular(14),
          ),

          child: Icon(

            icon,

            color:
            const Color(0xFF2563EB),
          ),
        ),

        title: Text(

          title,

          style: const TextStyle(

            fontWeight:
            FontWeight.w600,

            color:
            Color(0xFF0F172A),
          ),
        ),

        trailing: const Icon(

          Icons.arrow_forward_ios_rounded,

          size: 18,
        ),
      ),
    );
  }
}