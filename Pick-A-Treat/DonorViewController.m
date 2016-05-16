//
//  DonorViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/11/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "DonorViewController.h"
#import <Parse/Parse.h>
#import "MapPinAnnotation.h"
//@import MapKit;

@interface DonorViewController (){
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    Boolean riderRequest;
}
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIButton *postRequestBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;




@end




@implementation DonorViewController

@synthesize foodName, noOfPeople;

- (id)init{
    if ((self = [super init]))
    {
        //This is where you are supposed to initialise anythin you need
        
        
    }
    return self;
}

- (IBAction)logoutBtn:(id)sender {
    [locationManager stopUpdatingLocation];
    PFUser *currentUser = [PFUser currentUser]; // this will now be nil
    NSLog(@"%@ logged out",currentUser.username);
    [PFUser logOut];
    [self performSegueWithIdentifier:@"logoutUserSegue" sender:self];
}

- (IBAction)postRequestBtn:(id)sender {
    if (riderRequest == false) {
    
        PFObject *contributorRequest = [PFObject objectWithClassName:@"ContributorRequest"];
        contributorRequest[@"username"] = [[PFUser currentUser]username];
        contributorRequest[@"location"] = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        contributorRequest[@"foodName"] = foodName;
        contributorRequest[@"noOfPeople"] = noOfPeople;
    
        [contributorRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"SUCCESS");
                [self.postRequestBtn setTitle:@"Cancel Request" forState:UIControlStateNormal];
                riderRequest = true;
            } else {
                NSLog(@"FAILURE");
            }
        }];
    }
    
    if (riderRequest == true) {
        riderRequest = false;
        PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
        [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"Deleting post request object %@", object.objectId);
                    [object deleteInBackground];
                }
                [self.postRequestBtn setTitle:@"Post Request" forState:UIControlStateNormal];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
}


- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (void)viewDidLoad {
    [super viewDidLoad];

    riderRequest = false;
    self.infoLabel.text = @"";
    PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    PFObject *object = [query getFirstObject];
    
    //Async request was causing troubles and setting riderRequest = true;
    //[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (object!=nil) {
            riderRequest = true;
            [self.postRequestBtn setTitle:@"Cancel Request" forState:UIControlStateNormal];
        }
    //}];
    
    //Get current location
    self.map.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //float x = [[[UIDevice currentDevice] systemVersion] floatValue];  //Check iOS version currently used
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    //[locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // Assigning the last object as the current location of the device
    CLLocation *senderLocation = [locations lastObject];
    latitude = senderLocation.coordinate.latitude;
    longitude = senderLocation.coordinate.longitude;
    NSLog(@"lat%f - lon%f", senderLocation.coordinate.latitude, senderLocation.coordinate.longitude);
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            for (PFObject *object in objects) {
                NSString *collectorName = object[@"receiverResponded"];
                
                if(collectorName != nil) {
                    //[self.postRequestBtn setTitle:@"Cancel Request" forState:UIControlStateNormal];
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"ReceiverLocation"];
                    [query whereKey:@"username" equalTo:collectorName];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (!error) {
                        
                            for (PFObject *object in objects) {
                            
                                PFGeoPoint *locationObject = object[@"location"];
                                //NSLog(@"Responded person direection %f",locationObject.latitude);
                                CLLocation *recieverLocation = [[CLLocation alloc] initWithLatitude:locationObject.latitude longitude:locationObject.longitude];
                                
                                CLLocationDistance distance = [senderLocation distanceFromLocation:recieverLocation];
                                CLLocationDistance kilometers = distance / 1000.0;
                                
                                self.infoLabel.text = [NSString stringWithFormat:@"Reciever is %f kms away",kilometers];
                                //[self.postRequestBtn setTitle:@"Cancel Request" forState:UIControlStateNormal];
                                
                                CLLocationCoordinate2D  ctrpoint;
                                ctrpoint.latitude = recieverLocation.coordinate.latitude;
                                ctrpoint.longitude = recieverLocation.coordinate.longitude;
                                
                                
                                MapPinAnnotation* pinAnnotation =
                                [[MapPinAnnotation alloc] initWithCoordinates:ctrpoint
                                                                    placeName:nil
                                                                  description:nil];
                                [self.map addAnnotation:pinAnnotation];
                            }
                        }
                    }];
                }
            }
        }
    }];
    
    
    
    
    
    CLLocationCoordinate2D centre = CLLocationCoordinate2DMake(senderLocation.coordinate.latitude, senderLocation.coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centre, 800, 800);
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 800, 800);
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
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
