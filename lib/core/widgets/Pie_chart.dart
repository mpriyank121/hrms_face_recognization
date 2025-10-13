import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> dataMap; // data label and values
  final List<Color> colorList; // colors for slices
  final String centerText; // text displayed in center of pie
  final double chartRadius;
  final bool showLegend;
  final bool showChartValues;
  final TextStyle centerTextStyle;
  final double ringStrokeWidth;

  const PieChartWidget({
    Key? key,
    required this.dataMap,
    required this.colorList,
    this.centerText = '',
    this.chartRadius = 100,
    this.showLegend = true,
    this.showChartValues = true,
    this.ringStrokeWidth = 20, required ChartType chartType, required this.centerTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      colorList: colorList,
      chartRadius: chartRadius,
      chartType: ChartType.ring,
      ringStrokeWidth: ringStrokeWidth,

      baseChartColor: Colors.transparent,
      centerText: centerText,
      centerTextStyle: centerTextStyle,
      legendOptions: LegendOptions(
        showLegends: showLegend,
        legendPosition: LegendPosition.right,
      ),
      chartValuesOptions: ChartValuesOptions(
        chartValueBackgroundColor: Colors.transparent,
        showChartValues: showChartValues,
        showChartValuesInPercentage: true,
        decimalPlaces: 0,
      ),
    );
  }
}
