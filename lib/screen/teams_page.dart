import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:respoooonsi/screen/detail_team_page.dart';
import 'dart:convert';

class TeamScreen extends StatefulWidget {
  final int leagueId;

  TeamScreen({required this.leagueId});

  @override
  TeamScreenState createState() => TeamScreenState();
}

class TeamScreenState extends State<TeamScreen> {
  List<dynamic> _teams = [];
  bool _isLoading = true;

  Future<void> _fetchTeams() async {
    try {
      final response = await http.get(Uri.parse('https://go-football-api-v44dfgjgyq-et.a.run.app/${widget.leagueId}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Team data fetched: $jsonData');
        setState(() {
          _teams = jsonData['Data'] ?? [];
          _isLoading = false;
        });
      } else {
        print('Failed to load teams: ${response.statusCode}');
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Add padding here
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _teams.isEmpty
            ? Center(child: Text('No teams found'))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 8.0, // Spacing between columns
            mainAxisSpacing: 8.0, // Spacing between rows
          ),
          itemCount: _teams.length,
          itemBuilder: (context, index) {
            final team = _teams[index];
            final teamName = team['NameClub'] ?? 'Unknown Team';
            final logoUrl = team['LogoClubUrl'] ?? '';
            final stadiumName = team['StadiumName'] ?? 'Unknown Stadium';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailTeamPage(teamId: team['IdClub'], leagueId: widget.leagueId,),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    logoUrl.isNotEmpty
                        ? Image.network(
                      logoUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    )
                        : Icon(Icons.sports),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teamName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            stadiumName,
                            style: TextStyle(fontSize: 12), // Small font size
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
