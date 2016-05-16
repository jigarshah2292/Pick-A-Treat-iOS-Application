//
//  AcceptorTableViewController.h
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/14/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AcceptorTableViewController : UITableViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}
@end
