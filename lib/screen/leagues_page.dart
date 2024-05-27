import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:respoooonsi/screen/teams_page.dart';
import 'dart:convert';

class LeagueListPage extends StatefulWidget {
  @override
  LeagueListPageState createState() => LeagueListPageState();
}

class LeagueListPageState extends State<LeagueListPage> {
  List<dynamic> _leagues = [];

  Future<void> _fetchLeagues() async {
    try {
      final response = await http.get(Uri.parse('https://go-football-api-v44dfgjgyq-et.a.run.app/'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('League data fetched: $jsonData');
        setState(() {
          _leagues = jsonData['Data'] ?? [];
        });
      } else {
        print('Failed to load leagues: ${response.statusCode}');
        throw Exception('Failed to load leagues');
      }
    } catch (e) {
      print('Error fetching leagues: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLeagues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('League List'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: _leagues.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _leagues.length,
        itemBuilder: (context, index) {
          final league = _leagues[index];
          final leagueName = league['leagueName'] ?? 'Unknown League';
          final country = league['country'] ?? 'Unknown Country';
          final logoUrl = league['logoLeagueUrl'] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamScreen(leagueId: league['idLeague']),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    logoUrl.isNotEmpty
                        ? Image.network(
                      logoUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    )
                        : Icon(Icons.sports_soccer),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leagueName,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            country,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
