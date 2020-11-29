import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BarChartSample2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final double width = 30;
  double colica = 0;
  double fome = 0;
  double sono = 0;
  double dor = 0;
  String link = "911b62e1cc62.ngrok.io";

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex;
  TextEditingController _controller;

  getValues() async {
    try {
      var uri = Uri.http(link, "");
      var response = await http.get(uri);

      colica = jsonDecode(response.body)['colica'].toDouble();
      fome = jsonDecode(response.body)['fome'].toDouble();
      sono = jsonDecode(response.body)['sono'].toDouble();
      dor = jsonDecode(response.body)['dor'].toDouble();

      final barGroup1 = makeGroupData(0, colica);
      final barGroup2 = makeGroupData(1, fome);
      final barGroup3 = makeGroupData(2, sono);
      final barGroup4 = makeGroupData(3, dor);
      print(response.body);

      final items = [
        barGroup1,
        barGroup2,
        barGroup3,
        barGroup4,
      ];

      rawBarGroups = items;

      showingBarGroups = rawBarGroups;
      setState(() {});
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao consultar"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = link;
    final barGroup1 = makeGroupData(0, 0);
    final barGroup2 = makeGroupData(1, 0);
    final barGroup3 = makeGroupData(2, 0);
    final barGroup4 = makeGroupData(3, 0);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 50, 0, 50),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: const Color(0xff2c4260),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TextField(
              controller: _controller,
              onChanged: (String value) async {
                link = value;
                setState(() {});
              },
            ),
            FlatButton(
              child: Text("Atualizar"),
              onPressed: () {
                getValues();
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(
                  width: 38,
                ),
                const Text(
                  'Sintomas',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  'valores',
                  style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BarChart(
                  BarChartData(
                    maxY: 500,
                    barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          getTooltipItem: (_a, _b, _c, _d) => null,
                        ),
                        touchCallback: (response) {
                          if (response.spot == null) {
                            setState(() {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            });
                            return;
                          }

                          touchedGroupIndex =
                              response.spot.touchedBarGroupIndex;

                          setState(() {
                            if (response.touchInput is FlLongPressEnd ||
                                response.touchInput is FlPanEnd) {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            } else {
                              showingBarGroups = List.of(rawBarGroups);
                              if (touchedGroupIndex != -1) {
                                double sum = 0;
                                for (BarChartRodData rod
                                    in showingBarGroups[touchedGroupIndex]
                                        .barRods) {
                                  sum += rod.y;
                                }
                                final avg = sum /
                                    showingBarGroups[touchedGroupIndex]
                                        .barRods
                                        .length;

                                showingBarGroups[touchedGroupIndex] =
                                    showingBarGroups[touchedGroupIndex]
                                        .copyWith(
                                  barRods: showingBarGroups[touchedGroupIndex]
                                      .barRods
                                      .map((rod) {
                                    return rod.copyWith(y: avg);
                                  }).toList(),
                                );
                              }
                            }
                          });
                        }),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return 'Cólica';
                            case 1:
                              return 'Fome';
                            case 2:
                              return 'Sono';
                            case 3:
                              return 'Dor';
                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 32,
                        reservedSize: 14,
                        getTitles: (value) {
                          if (value == 0) {
                            return '0';
                          } else if (value == 30) {
                            return '30';
                          } else if (value == 70) {
                            return '70';
                          } else if (value == 100) {
                            return '100';
                          } else if (value == 200) {
                            return '200';
                          } else if (value == 300) {
                            return '300';
                          } else if (value == 400) {
                            return '400';
                          } else if (value == 500) {
                            return '500';
                          } else {
                            return '';
                          }
                        },
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: showingBarGroups,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('Cólica'),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Text('${colica.toInt()}', textAlign: TextAlign.end),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('Fome'),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Text('${fome.toInt()}', textAlign: TextAlign.end),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('Sono'),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Text('${sono.toInt()}', textAlign: TextAlign.end),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text('Dor'),
                ),
                Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Text('${dor.toInt()}', textAlign: TextAlign.end),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        colors: [leftBarColor],
        width: width,
      ),
    ]);
  }

  Widget makeTransactionsIcon() {
    const double width = 4.5;
    const double space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
