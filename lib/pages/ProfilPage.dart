import 'package:flutter/material.dart';
import 'package:my_daily_tasks/components/profilCard.dart';
import 'package:my_daily_tasks/pages/Profil_IdentityPage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        backgroundColor: Colors.amber[100],
        title: const Text(
          "Profil",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              // image profil
              Image.asset(
                "lib/photos/avatar.png",
                height: 125,
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  "Ajouter les stats de l'avatar \nsur son niveau et ses récompenses",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Container with 8 squares
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: const [
                ProfilCard(
                  icon: Icons.palette_rounded,
                  label: 'Identité',
                  route: IdentityPage()),
                ProfilCard(
                    icon: Icons.settings_suggest,
                    label: 'Catégories',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.task_alt,
                    label: 'Activités',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.query_stats,
                    label: 'Statistiques',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.person_search,
                    label: 'Avatar',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.star,
                    label: 'Succès',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.share,
                    label: 'Partager',
                    route: IdentityPage()),
                ProfilCard(
                    icon: Icons.settings,
                    label: 'Paramètre',
                    route: IdentityPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}