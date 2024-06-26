import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_splim/service/priceservice.dart';
import 'package:flutter_splim/dto/PriceDTO.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter_splim/provider/userprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_splim/service/preferservice.dart';
import 'package:flutter_splim/dto/UserDTO.dart';
import 'package:flutter_splim/dto/PreferDTO.dart';

class ShoppingResultPage extends StatefulWidget {
  final String itemname;
  final String kindname;
  final String rankname;

  ShoppingResultPage({required this.itemname, required this.kindname, required this.rankname});

  @override
  _ShoppingResultPageState createState() => _ShoppingResultPageState();
}

class _ShoppingResultPageState extends State<ShoppingResultPage> {
  late DataTable dataTable;
  final PriceService priceService = PriceService();
  List<PriceDTO> searchData = [];
  List<FlSpot> spots = [];
  bool isLoading = true;
  UserDTO? user;
  final PreferService preferService = PreferService();
  PreferDTO? preferDTO;

  @override
  void initState() {
    super.initState();
    dataTable = DataTable(
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
      ],
      rows: [],
    );
    updateDataTable();
    user = Provider.of<UserProvider>(context, listen: false).user;
    if(user != null)
      fetchPreference();
  }

  Future<void> fetchPreference() async {
    PreferService preferService = PreferService();
    PreferDTO? result = await preferService.getPreference(user!.id, widget.itemname);
    setState(() {
      preferDTO = result;
    });
  }

  void updateDataTable() async {
      try {
        searchData = await priceService.fetchSearchdata(
            widget.itemname,
            widget.kindname,
            widget.rankname
        );
        setState((){
          dataTable = DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black26),
            border: TableBorder.all(
              width: 3.0,
              color: Colors.black12,
            ),
            columns: [
              DataColumn(label: Expanded(child: Text('날짜', textAlign: TextAlign.center, style: TextStyle(fontSize: 12),),)),
              DataColumn(label: Expanded(child: Text('가격(원)', textAlign: TextAlign.center , style: TextStyle(fontSize: 12)), )),
              DataColumn(label: Expanded(child: Text('등락률(%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
            ],
            rows: searchData.map((price) {
              Color textColor;
              if (price.value > 0) {
                textColor = Colors.red;
              } else if (price.value < 0) {
                textColor = Colors.blue;
              } else {
                textColor = Colors.black;
              }
              return DataRow(
                cells: [
                  DataCell(Text(price.regday, textAlign: TextAlign.center)),
                  DataCell(Text(price.dpr1, textAlign: TextAlign.center)),
                  DataCell(Text(price.value.toString()+"%", textAlign: TextAlign.center, style: TextStyle(color: textColor),)),
                ],
              );
            }).toList(),
          );

          spots = _getSpots(searchData);

          setState(() {
            isLoading = false;
          });
        });
      } catch (e) {
        print('Failed to load search data: $e');
      }
  }

  @override
  Widget build(BuildContext context) {
    String rankName = searchData.isNotEmpty && searchData[0].rankName != null ? "등급: " + searchData[0].rankName+", ": "";
    String kindName = searchData.isNotEmpty && searchData[0].kindName != null ? "종류: " + searchData[0].kindName + ", ": "";
    String unit = searchData.isNotEmpty && searchData[0].unit != null ? "단위: " + searchData[0].unit : "";

    List<Widget> _buildAppBarActions() {
      List<Widget> actions = [];

      if (user != null) {
        actions.addAll([
          TextButton(
            onPressed:() async{
              if (preferDTO != null) {
                if (preferDTO!.prefer != 0) {
                  setState(() {
                    preferDTO!.prefer = 0;
                  });
                  await preferService.updatePrefer(preferDTO!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('선호 명단에 추가되었습니다.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이미 선호 식재료에 있습니다.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preference data not loaded yet.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }

            } , child: Text("선호",
            style: TextStyle(color: Colors.green),
          ),
          ),

          TextButton(
            onPressed:() async{
              if (preferDTO != null) {
                if (preferDTO!.prefer != 2) {
                  setState(() {
                    preferDTO!.prefer = 2;
                  });
                  await preferService.updatePrefer(preferDTO!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('차단 명단에 추가되었습니다.'),
                      backgroundColor: Colors.red[200],
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('이미 차단된 식재료 입니다.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preference data not loaded yet.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } , child: Text("차단",
            style: TextStyle(color: Colors.red),
          ),

          ),
        ]);
      }

      return actions;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.itemname}', style: TextStyle(fontSize: 25),),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.grey[100],
        actions: _buildAppBarActions(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중이면 로딩 표시
          : ListView(
        children: [
          SizedBox(height: 20,),
          Center(
            child: Text(
              "$kindName$rankName$unit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: dataTable,
            ),
          ),
          SizedBox(height: 20),
          _buildLineChart(searchData),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<PriceDTO> searchData) {
    double maxY = _calculateMaxY(searchData);
    double minY = _calculateMinY(searchData);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _getSpots(searchData.reversed.toList()),
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 4,
                isStrokeCapRound: false,
                belowBarData: BarAreaData(show: true, color: Colors.lightBlue.withOpacity(0.3)),
              ),
            ],
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 30,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: rightTitleWidgets,
                    reservedSize: 28,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,

                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black, width: 1)),
            minX: 0,
            maxX: searchData.length.toDouble() - 1,
            minY: minY,
            maxY: maxY,
          ),
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    double maxY = _calculateMaxY(searchData);
    double minY = _calculateMinY(searchData);
    double result = maxY - minY;
    String text = "";

    String truncateToOneDecimal(double number) {
      String numberStr = (number.toDouble() / 1000).toString();
      int decimalIndex = numberStr.indexOf('.');
      if (decimalIndex != -1 && decimalIndex + 2 < numberStr.length) {
        return numberStr.substring(0, decimalIndex + 2) + "k";
      } else {
        return numberStr + "k";
      }
    }

    if (result <= 100) {
      if (value.toInt() % 50 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else if (result <= 1000) {
      if (value.toInt() % 200 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else if (result <= 5000) {
      if (value.toInt() % 1000 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    } else {
      if (value.toInt() % 10000 == 0) {
        text = truncateToOneDecimal(value);
      } else {
        text = "";
      }
    }

    return SideTitleWidget(
      axisSide: AxisSide.left, // 왼쪽에 배치
      child: Text(text, style: style, textAlign: TextAlign.left),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    int dataSize = searchData.length;
    if (dataSize > 0) {
      // searchData에서 regday 값을 가져옵니다.
      List<PriceDTO> reverse = searchData.reversed.toList();
      String regday = reverse[value.toInt()].regday.substring(5,10).replaceAll("-", "/");
      // 가져온 regday 값을 사용하여 텍스트 위젯 생성
      text = Text(regday, style: style);
    } else {
      // searchData가 비어있을 경우 빈 텍스트 반환
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text = "";

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  double _calculateMaxY(List<PriceDTO> searchData) {
    if(searchData != null && searchData.isNotEmpty){
      double maxDpr1 = double.parse(searchData[0].dpr1.replaceAll(",", ""));

      for(int i = 1; i < searchData.length; i++){
        double num = double.parse(searchData[i].dpr1.replaceAll(",", ""));

        if(num > maxDpr1){
          maxDpr1 = num;
        }
      }

      return maxDpr1 * 1.03; //
    }else{
      return 1.0;
    }

  }

  double _calculateMinY(List<PriceDTO> searchData) {
    if(searchData != null && searchData.isNotEmpty){
      double minDpr1 = double.parse(searchData[0].dpr1.replaceAll(",", ""));

      for(int i = 1; i < searchData.length; i++){
        double num = double.parse(searchData[i].dpr1.replaceAll(",", ""));

        if(num < minDpr1){
          minDpr1 = num;
        }
      }

      return minDpr1 * 0.95;
    }else{
      return 0.0;
    }

  }

  List<FlSpot> _getSpots(List<PriceDTO> searchData) {
    List<FlSpot> spots = [];
    for (int i = searchData.length-1; i >= 0; i--) {
      spots.add(FlSpot(i.toDouble(), double.parse(searchData[i].dpr1.replaceAll(",", ""))));
    }
    return spots;
  }

}
