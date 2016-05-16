//
//  DonorViewController.h
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/11/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DonorViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    CLLocationManager *locationManager;
}

@property(strong, nonatomic) NSString *foodName;
@property(strong, nonatomic) NSString *noOfPeople;

@end
