import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:covid19_tracker/model/countries.dart';
import 'package:covid19_tracker/screens/country_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Uitls.dart';

class OurSearchDelegate extends SearchDelegate {
  final List<Countries> countriesList;
  final int typeShow;

  OurSearchDelegate({this.countriesList, this.typeShow}) {
    this.countriesList.sort((c1, c2) {
      if (this.typeShow == 0) {
        return c2.active.compareTo(c2.active);
      } else if (this.typeShow == 1) {
        return c2.recovered.compareTo(c2.recovered);
      } else if (this.typeShow == 2) {
        return c2.deaths.compareTo(c1.deaths);
      } else {
        return c2.confirmed.compareTo(c1.confirmed);
      }
    });
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear_all), onPressed: () => query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
        children: countriesList
            .where((element) =>
                element.country.toLowerCase().contains(query.toLowerCase()))
            .map<Widget>((e) => ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CountryScreen(
                        country: e,
                      ),
                    ),
                  ),
                  leading: e.countryCode.length == 2
                      ? CountryPickerUtils.getDefaultFlagImage(
                          Country(isoCode: e.countryCode))
                      : Text(''),
                  title: Text(e.country),
                  subtitle: Text(
                      '${Utils.formatNumber(typeShow == -1 ? e.confirmed : (typeShow == 0 ? e.active : (typeShow == 1 ? e.recovered : e.deaths)))}'),
                ))
            .toList());
  }

  // final formatter = NumberFormat.decimalPattern('en-US');
}
