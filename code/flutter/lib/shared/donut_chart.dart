// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Donut chart example. This is a simple pie chart with a hole in the middle.
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DonutPieChart extends StatelessWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  DonutPieChart(this.seriesList, bool bool, {this.animate = true});

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart<Object>(
      seriesList,
      animate: animate,
      // Configure the width of the pie slices to 60px. The remaining space in
      // the chart will be left as a hole in the center.
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [new charts.ArcLabelDecorator()],
      ),
      // behaviors: [
      //   new charts.DatumLegend(
      //     position: charts.BehaviorPosition.end,
      //     outsideJustification: charts.OutsideJustification.endDrawArea,
      //     horizontalFirst: false,
      //     desiredMaxRows: 2,
      //     cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
      //     showMeasures: true,
      //   )
      // ],
    );
  }
}
