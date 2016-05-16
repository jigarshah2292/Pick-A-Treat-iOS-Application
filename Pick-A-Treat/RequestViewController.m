//
//  RequestViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/18/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "RequestViewController.h"
#import <MapKit/MapKit.h>
#import "MapPinAnnotation.h"

@interface RequestViewController (){
    CLLocationDegrees destLat;
    CLLocationDegrees destLng;
}
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end

@implementation RequestViewController

@synthesize requestLocation,username;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFGeoPoint *locationObject = requestLocation;
    destLat = locationObject.latitude;
    destLng = locationObject.longitude;
    
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = destLat;
    ctrpoint.longitude = destLng;
    
    CLLocation * LocationAtual = [[CLLocation alloc]initWithLatitude:destLat longitude:destLng];
    
    
    MapPinAnnotation* pinAnnotation =
    [[MapPinAnnotation alloc] initWithCoordinates:ctrpoint
                                        placeName:nil
                                      description:nil];
    [self.map addAnnotation:pinAnnotation];
    
    MKCoordinateSpan span; span.latitudeDelta = .002;
    span.longitudeDelta = .002;
    //the .002 here represents the actual height and width delta
    MKCoordinateRegion region;
    region.center = LocationAtual.coordinate; region.span = span;
    [self.map setRegion:region animated:TRUE];
    
    //NSLog(@"HI %@",username);
}
- (IBAction)pickUpFood:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"Deleting post request object %@", object.objectId);
                PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
                
                // Retrieve the object by id
                [query getObjectInBackgroundWithId:object.objectId
                                             block:^(PFObject *object, NSError *error) {
                                                 // Now let's update it with some new data. In this case, only cheatMode and score
                                                 // will get sent to the cloud. playerName hasn't changed.
                                                 object[@"receiverResponded"]=[[PFUser currentUser]username];
                                                 [object saveInBackground];
                                             }];
                
                CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(destLat, destLng);
                MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
                MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
                
                //Call apple maps and send the locations to that
                NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
                [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
                
                [endingItem openInMapsWithLaunchOptions:launchOptions];

                
            }
            //[self.postRequestBtn setTitle:@"Post Request" forState:UIControlStateNormal];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
