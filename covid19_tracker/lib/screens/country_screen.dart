import 'package:covid19_tracker/model/countries.dart';
import 'package:covid19_tracker/services/Uitls.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

// ignore: must_be_immutable
class CountryScreen extends StatelessWidget {
  Countries country;
  List<charts.Series> seriesList;

  CountryScreen({Key key, this.country, this.seriesList}) : super(key: key) {
    seriesList = _createData();
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Center(child: Text(country.country)),
  //     ),
  //     body: Column(
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 20),
  //           child: Image.network(
  //             'https://www.countryflags.io/${country.countryCode}/flat/64.png',
  //             width: MediaQuery.of(context).size.width / 3,
  //             fit: BoxFit.fill,
  //           ),
  //         ),
  //         buildDetailText(
  //             count: country.confirmed, color: Colors.black, text: "Confirmed"),
  //         buildDetailText(
  //             count: country.active, color: Colors.blue, text: "Active"),
  //         buildDetailText(
  //             count: country.recovered, color: Colors.green, text: "Recovered"),
  //         buildDetailText(
  //             count: country.deaths, color: Colors.red, text: "Deaths"),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // _createData();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          country.country,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              "Confirmed: ${Utils.formatNumber(country.confirmed)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: new charts.PieChart(
              seriesList,
              animate: true,
              animationDuration: Duration(milliseconds: 500),
              behaviors: [
                new charts.DatumLegend(
                    position: charts.BehaviorPosition.bottom,
                    outsideJustification:
                        charts.OutsideJustification.startDrawArea,
                    horizontalFirst: false,
                    desiredMaxRows: 2,
                    cellPadding: new EdgeInsets.all(
                        10), //only(top: 10, right: 10.0, bottom: 10.0),
                    showMeasures: true,
                    legendDefaultMeasure:
                        charts.LegendDefaultMeasure.firstValue,
                    measureFormatter: (num value) {
                      return value == null
                          ? '-'
                          : '${Utils.formatNumber(value)}';
                    }),
              ],
              defaultRenderer: new charts.ArcRendererConfig(
                  arcWidth: 120,
                  arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.auto)
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  List<charts.Series<LinearSales, String>> _createData() {
    print('-=-=-=   _createData');
    int confirmed = country.confirmed;
    int active = country.active;
    int recovered = country.recovered;
    int deaths = country.deaths;

    // print('-=-=-=   confirmed ' + confirmed.toString());
    // print('-=-=-=   active ' + ((active / confirmed) * 100).toStringAsFixed(2));
    // print('-=-=-=   recovered ' + (recovered / confirmed).toStringAsFixed(2));
    // print('-=-=-=   deaths ' + (deaths / confirmed).toStringAsFixed(2));

    var data = [
      new LinearSales(
        (active / confirmed) * 100,
        active,
        "Active",
      ),
      new LinearSales((deaths / confirmed) * 100, deaths, "Deaths"),
      new LinearSales((recovered / confirmed) * 100, recovered, "Recovered"),
    ];

    return [
      new charts.Series<LinearSales, String>(
        id: 'Sales',
        displayName: "Covid 19",
        domainFn: (LinearSales sales, _) => sales.name,
        measureFn: (LinearSales sales, _) => sales.count,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearSales row, _) =>
            '${row.name}\n${row.percent.round()}%',
        // areaColorFn: (datum, index) => charts.Color.fromHex(code: '#ff80a8'),
        // fillColorFn: (datum, index) => charts.Color.black,
        // seriesColor: charts.Color.white

        // fillColorFn: (LinearSales row, _) =>
        //     charts.Color.fromHex(code: '0xFF4CAF50'))
      )
    ];
  }

  // Widget buildDetailText({int count, Color color, String text}) {
  //   return ListTile(
  //     title: Text(
  //       '$text',
  //       style: TextStyle(color: color, fontWeight: FontWeight.bold),
  //     ),
  //     subtitle: Text('${formatter.format(count)}'),
  //   );
  // }
}

class LinearSales {
  String name;
  double percent;
  int count;

  LinearSales(this.percent, this.count, this.name);
}
