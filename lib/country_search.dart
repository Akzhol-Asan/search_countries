import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_work_37/models/countries_list_item.dart';
import 'package:http/http.dart';

class CountrySearch extends StatefulWidget {
  const CountrySearch({super.key});

  @override
  State<CountrySearch> createState() => _CountrySearchState();
}

class _CountrySearchState extends State<CountrySearch> {
  List<CountryListItem> countries = [];
  TextEditingController search = TextEditingController();
  String errorMessage = '';

  Future<void> fetchData(String countryName) async {
    if (countryName.isEmpty) return;
    final uri = Uri.parse('https://restcountries.com/v3.1/name/$countryName');
    final response = await get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final newCountry =
          jsonData
              .map(
                (json) => CountryListItem(
                  country: json['name']['common'],
                  capital:
                      (json['capital'] as List).isNotEmpty
                          ? json['capital'][0]
                          : 'Unknown',
                  region: json['region'],
                  area: json['area'].toDouble(),
                  population: json['population'],
                  flag: json['flag'],
                ),
              )
              .toList();
      setState(() {
        countries = newCountry;
        errorMessage = '';
      });
    } else if (response.statusCode == 404) {
      setState(() {
        countries = [];
        errorMessage = 'Could not found this country';
      });
    } else {
      setState(() {
        errorMessage = 'unknown error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Search Countries'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: search,
                    decoration: InputDecoration(labelText: 'Enter country'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    fetchData(search.text.trim());
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  '404 country not found!\ntry again :)',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: countries.length,
              separatorBuilder: (ctx, index) => Divider(),
              itemBuilder:
                  (ctx, index) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Country:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].country,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Capital:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].capital,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Region:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].region,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Area:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].area.toString(),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Population:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].population.toString(),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Flag:'),
                          SizedBox(width: 5),
                          Text(
                            countries[index].flag,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
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
