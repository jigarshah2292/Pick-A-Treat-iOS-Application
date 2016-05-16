//
//  RequestViewController.h
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/18/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface RequestViewController : UIViewController <CLLocationManagerDelegate>

@property id requestLocation;

@property (strong, nonatomic) NSString *username;

@end
