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
  bool isFetching = false;
  String? fetchError;

  Future<List<String>> borderCountries(List<String> countryCodes) async {
    if (countryCodes.isEmpty) return [];

    List<String> borderNames = [];

    for (String code in countryCodes) {
      try {
        final uri = Uri.parse('https://restcountries.com/v3.1/alpha/$code');
        final response = await get(uri);

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          borderNames.add(jsonData.first['name']['common']);
        }
      } catch (e) {
        borderNames.add(code);
      }
    }

    return borderNames;
  }

  Future<void> fetchData(String countryName) async {
    if (countryName.isEmpty) return;

    setState(() {
      isFetching = true;
      errorMessage = '';
      fetchError = null;
    });

    try {
      final uri = Uri.parse('https://restcountries.com/v3.1/name/$countryName');
      final countriesResponse = await get(uri);

      if (countriesResponse.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(countriesResponse.body);
        final List<CountryListItem> newCountry = await Future.wait(
          jsonData.map<Future<CountryListItem>>((json) async {
            List<String> borderCodes =
                (json['borders'] as List?)?.cast<String>() ?? [];
            List<String> borderNames = await borderCountries(borderCodes);

            return CountryListItem(
              country: json['name']['common'],
              capital:
                  (json['capital'] as List?)?.isNotEmpty == true
                      ? json['capital'][0]
                      : 'Unknown',
              region: json['region'],
              area: json['area'].toDouble(),
              population: json['population'],
              flag: json['flag'],
              borders: borderNames,
            );
          }),
        );

        setState(() {
          countries = newCountry;
          errorMessage = '';
          isFetching = false;
        });
      } else if (countriesResponse.statusCode == 404) {
        setState(() {
          countries = [];
          errorMessage =
              'Could not found - $countryName\nTry another country :)';
          isFetching = false;
        });
      } else {
        throw Exception('Response code: ${countriesResponse.statusCode}');
      }
    } catch (error) {
      setState(() {
        fetchError = 'Response error: ${error.toString()}';
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content;
    if (isFetching) {
      content = Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(),
        ),
      );
    } else if (fetchError != null) {
      content = Center(child: Text(fetchError!, textAlign: TextAlign.center));
    } else {
      content = Column(
        children: [
          //Input country name & button
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
          //Check if country exist
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  textAlign: TextAlign.center,
                  errorMessage,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          Expanded(
            //ListView coz there couple countries with the same name (India, America, China etc)
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
                      SizedBox(height: 10),
                      if (countries[index].borders.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Borders:'),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                countries[index].borders.join(', '),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Search Countries'))),
      body: content,
    );
  }
}
