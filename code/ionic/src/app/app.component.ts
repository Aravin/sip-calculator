import { Component } from '@angular/core';

import { Platform } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss']
})
export class AppComponent {
  public appPages = [
    {
      title: 'SIP Calculator',
      url: '/home',
      icon: 'calculator'
    },
    {
      title: 'Lump Sum Calculator',
      url: '/lumpsum',
      icon: 'cash'
    },
    // {
    //   title: 'Settings',
    //   url: '/settings',
    //   icon: 'cog'
    // },
    // {
    //   title: 'Share this App',
    //   url: '/share',
    //   icon: 'share'
    // },
    // {
    //   title: 'Rate this App',
    //   url: 'https://learn.vrdnation.com/',
    //   icon: 'star'
    // },
    // {
    //   title: 'Feedback',
    //   url: '/feedback',
    //   icon: 'send'
    // },
    {
      title: 'About Us',
      url: '/about',
      icon: 'information-circle'
    }
  ];

  constructor(
    private platform: Platform,
    private splashScreen: SplashScreen,
    private statusBar: StatusBar
  ) {
    this.initializeApp();
  }

  initializeApp() {
    this.platform.ready().then(() => {
      this.statusBar.styleDefault();
      this.splashScreen.hide();
    });
  }
}
