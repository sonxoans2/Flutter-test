import 'package:covid19_tracker/model/countries.dart';
import 'package:covid19_tracker/model/covid19_dashboard.dart';
import 'package:covid19_tracker/services/Uitls.dart';
import 'package:covid19_tracker/services/networking.dart';
import 'package:covid19_tracker/services/search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';

import 'country_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  Covid19Dashboard result;
  AnimationController _controller;
  Animation _curvedAnimation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.bounceOut);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Covid-19 Tracking",
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: OurSearchDelegate(
                        countriesList: result.countries.toList(),
                        typeShow: -1));
              })
        ],
      ),
      body: result == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getData,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverGrid(
                      delegate: SliverChildListDelegate([
                        buildSummerCard(
                            text: 'Confirmed',
                            color: Colors.black,
                            count: result.confirmed,
                            onTap: () {
                              showSearch(
                                  context: context,
                                  delegate: OurSearchDelegate(
                                      countriesList: result.countries.toList(),
                                      typeShow: -1));
                            }),
                        buildSummerCard(
                            text: 'Active',
                            color: Colors.blue,
                            count: result.active,
                            onTap: () {
                              showSearch(
                                  context: context,
                                  delegate: OurSearchDelegate(
                                      countriesList: result.countries.toList(),
                                      typeShow: 0));
                            }),
                        buildSummerCard(
                            text: 'Recovered',
                            color: Colors.green,
                            count: result.recovered,
                            onTap: () {
                              showSearch(
                                  context: context,
                                  delegate: OurSearchDelegate(
                                      countriesList: result.countries.toList(),
                                      typeShow: 1));
                            }),
                        buildSummerCard(
                            text: 'Deaths',
                            color: Colors.red,
                            count: result.deaths,
                            onTap: () {
                              showSearch(
                                  context: context,
                                  delegate: OurSearchDelegate(
                                      countriesList: result.countries.toList(),
                                      typeShow: 2));
                            }),
                      ]),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 1.5)),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: Text('Result date: ${result.date}')),
                    ),
                  ])),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return buildExpansionTile(result.countries[index], index);
                  }, childCount: result.countries.length))
                ],
              ),
              // ListView.builder(
              //     itemCount: result.countries.length,
              //     itemBuilder: (context, index) {
              //       // var item = result.countries[index];
              //       return buildExpansionTile(result.countries[index], index);
              //     }),
            ),
    );
  }

  Widget buildSummerCard({int count, Color color, String text, onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ScaleTransition(
          scale: Tween<double>(begin: 0, end: 1).animate(_curvedAnimation),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    text,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${Utils.formatNumber(count)}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  ListTile buildExpansionTile(Countries item, int index) {
    // return ExpansionTile(
    //   leading: item.countryCode.length == 2
    //       ? CountryPickerUtils.getDefaultFlagImage(
    //           Country(isoCode: item.countryCode))
    //       : Text(''),
    //   title: Text('${item.country}'),
    //   trailing: Text('${formatter.format(item.confirmed)}'),
    //   children: <Widget>[
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8),
    //       child: Row(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: <Widget>[
    //             Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   buildDetailText(
    //                       count: index + 1, color: Colors.black, text: "Rank"),
    //                   buildDetailText(
    //                       count: item.active,
    //                       color: Colors.blue,
    //                       text: "Active"),
    //                   buildDetailText(
    //                       count: item.recovered,
    //                       color: Colors.green,
    //                       text: "Recovered"),
    //                   buildDetailText(
    //                       count: item.deaths,
    //                       color: Colors.red,
    //                       text: "Deaths"),
    //                 ])
    //           ]),
    //     )
    //   ],
    // );

    return ListTile(
      leading: item.countryCode.length == 2
          ? CountryPickerUtils.getDefaultFlagImage(
              Country(isoCode: item.countryCode))
          : Text(''),
      title: Text('${item.country}'),
      trailing: Text('${Utils.formatNumber(item.confirmed)}'),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountryScreen(country: item),
        ),
      ),
      // children: <Widget>[
      //   Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 8),
      //     child: Row(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: <Widget>[
      //           Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: <Widget>[
      //                 buildDetailText(
      //                     count: index + 1, color: Colors.black, text: "Rank"),
      //                 buildDetailText(
      //                     count: item.active,
      //                     color: Colors.blue,
      //                     text: "Active"),
      //                 buildDetailText(
      //                     count: item.recovered,
      //                     color: Colors.green,
      //                     text: "Recovered"),
      //                 buildDetailText(
      //                     count: item.deaths,
      //                     color: Colors.red,
      //                     text: "Deaths"),
      //               ])
      //         ]),
      //   )
      // ],
    );
  }

  Widget buildDetailText({int count, Color color, String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text('$text: ${Utils.formatNumber(count)}',
          style: TextStyle(color: color)),
    );
  }

  Future<void> getData() async {
    Networking networking = Networking();
    Covid19Dashboard _result = await networking.getDashboardData();
    setState(() {
      result = _result;
      if (result != null) {
        _controller.reset();
        _controller.forward();
      }
    });

    return result;
  }
}

// import 'package:covid19_tracker/model/countries.dart';
// import 'package:covid19_tracker/model/covid19_dashboard.dart';
// import 'package:covid19_tracker/services/networking.dart';
// import 'package:flutter/material.dart';
// import 'package:country_pickers/country_pickers.dart';
// import 'package:country_pickers/country.dart';
// import 'package:intl/intl.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key key}) : super(key: key);

//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with SingleTickerProviderStateMixin {
//   Covid19Dashboard data;
//   AnimationController _controller;
//   Animation _curvedAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     );
//     _curvedAnimation =
//         CurvedAnimation(parent: _controller, curve: Curves.bounceInOut);
//     getData();
//     //_controller.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('COVID-19 Dashboard'),
//       ),
//       body: data == null
//           ? Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: getData,
//               child: CustomScrollView(
//                 slivers: <Widget>[
//                   SliverGrid(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.5,
//                     ),
//                     delegate: SliverChildListDelegate([
//                       buildSummerCard(
//                           text: 'Confirmed',
//                           color: Colors.black,
//                           count: data.confirmed),
//                       buildSummerCard(
//                           text: 'Active',
//                           color: Colors.blue,
//                           count: data.active),
//                       buildSummerCard(
//                           text: 'Recovered',
//                           color: Colors.green,
//                           count: data.recovered),
//                       buildSummerCard(
//                           text: 'Deaths',
//                           color: Colors.red,
//                           count: data.deaths),
//                     ]),
//                   ),
//                   SliverList(
//                       delegate: SliverChildListDelegate([
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       child: Center(
//                         child: Text('Result date: ${data.date}'),
//                       ),
//                     )
//                   ])),
//                   SliverList(
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       var item = data.countries[index];
//                       return buildExpansionTile(item, index);
//                     }, childCount: data.countries.length),
//                   )
//                 ],
//               )
//               //  ListView.builder(
//               //     itemCount: data.countries.length,
//               //     itemBuilder: (context, index) {
//               //       var item = data.countries[index];
//               //       return buildExpansionTile(item, index);
//               //     }),
//               ),
//     );
//   }

//   Widget buildSummerCard({int count, Color color, String text}) {
//     return ScaleTransition(
//       scale: Tween<double>(begin: 0, end: 1).animate(_curvedAnimation),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Material(
//             borderRadius: BorderRadius.circular(10),
//             elevation: 10,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: <Widget>[
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${formatter.format(count)}',
//                   style: TextStyle(
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 22,
//                   ),
//                 )
//               ],
//             )),
//       ),
//     );
//   }

//   ExpansionTile buildExpansionTile(Countries item, int index) {
//     return ExpansionTile(
//       leading: item.countryCode.length == 2
//           ? CountryPickerUtils.getDefaultFlagImage(
//               Country(isoCode: item.countryCode))
//           : Text(''),
//       title: Text('${item.country}'),
//       trailing: Text('${formatter.format(item.confirmed)}'),
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 buildDetailText(
//                     color: Colors.black, count: index + 1, text: 'Rank'),
//                 buildDetailText(
//                     color: Colors.blue, count: item.active, text: 'Active'),
//                 buildDetailText(
//                     color: Colors.green,
//                     count: item.recovered,
//                     text: 'Recovered'),
//                 buildDetailText(
//                     color: Colors.red, count: item.deaths, text: 'Deaths'),
//               ]),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget buildDetailText({int count, Color color, String text}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Text(
//         '$text: ${formatter.format(count)}',
//         style: TextStyle(color: color),
//       ),
//     );
//   }

//   Future<void> getData() async {
//     Networking network = Networking();
//     Covid19Dashboard result = await network.getDashboardData();
//     setState(() {
//       data = result;
//       if (data != null) {
//         _controller.reset();
//         _controller.forward();
//       }
//     });
//   }
// }
