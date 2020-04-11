import { Component, OnInit  } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ChartOptions, ChartType, ChartDataSets } from 'chart.js';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})

export class HomePage implements OnInit  {

  sipForm: FormGroup;
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
    this.sipForm = this.formBuilder.group({
      amount: ['', [Validators.required, Validators.min(1), Validators.max(999999999)]],
      duration: ['', [Validators.required, Validators.min(1), Validators.max(100)]],
      rateOfReturn: ['', [Validators.required, Validators.min(1), Validators.max(100)]],
    });
  }

  calculateSip() {

    this.barChartData = [];

    // getting values from form
    const amount: number = this.sipForm.value.amount;
    const duration: number = this.sipForm.value.duration;
    const rateOfReturn: number = this.sipForm.value.rateOfReturn;

    if (!amount || !duration || !rateOfReturn) {
      return;
    }

    const r = rateOfReturn / 100 / 12;

    this.sip = amount * ((Math.pow(1 + r, 12 * duration) - 1) / (r)) * (1 + r);
    this.sip = parseFloat(this.sip.toFixed(2));

    this.totalAmount = amount * duration * 12;

    this.barChartData.push(...[
      { data: [this.totalAmount], label: 'Total Investments', backgroundColor: ['#721af0'], hoverBackgroundColor:  ['#6200EE']},
      { data: [this.sip], label: 'SIP Returns', backgroundColor: ['#1cdecb'], hoverBackgroundColor:  ['#03DAC5'] }]);
  }

}
