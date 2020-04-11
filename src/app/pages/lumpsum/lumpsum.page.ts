import { Component, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { ChartOptions, ChartType, ChartDataSets } from 'chart.js';

@Component({
  selector: 'app-lumpsum',
  templateUrl: './lumpsum.page.html',
  styleUrls: ['./lumpsum.page.scss'],
})
export class LumpsumPage implements OnInit {

  lumpsumForm: FormGroup;
  sip = 0;
  totalAmount = 0;

  public barChartOptions: ChartOptions = {
    responsive: true,
    scales: {
      yAxes: [{
          ticks: {
              beginAtZero: true
          }
      }]
    },
    tooltips: {
      enabled: false,
    }
  };
  public barChartType: ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[] = [];

  constructor( private formBuilder: FormBuilder) {}

  ngOnInit() {
    this.lumpsumForm = this.formBuilder.group({
      amount: ['', [Validators.required, Validators.min(1), Validators.max(999999999)]],
      duration: ['', [Validators.required, Validators.min(1), Validators.max(100)]],
      rateOfReturn: ['', [Validators.required, Validators.min(1), Validators.max(100)]],
    });
  }

  calculateLumpsum() {

    this.barChartData = [];

    // getting values from form
    const amount: number = this.lumpsumForm.value.amount;
    const duration: number = this.lumpsumForm.value.duration;
    const rateOfReturn: number = this.lumpsumForm.value.rateOfReturn;

    if (!amount || !duration || !rateOfReturn) {
      return;
    }

    const r = rateOfReturn / 100 / 1;

    this.sip = amount * (Math.pow(1 + r, 1 * duration));
    this.sip = parseFloat(this.sip.toFixed(2));

    this.totalAmount = amount;

    this.barChartData.push(...[
      { data: [this.totalAmount], label: 'Total Investments', backgroundColor: ['#721af0'], hoverBackgroundColor:  ['#6200EE']},
      { data: [this.sip], label: 'SIP Returns', backgroundColor: ['#1cdecb'], hoverBackgroundColor:  ['#03DAC5'] }]);
  }

}
