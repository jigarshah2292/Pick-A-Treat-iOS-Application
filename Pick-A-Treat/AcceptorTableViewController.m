//
//  AcceptorTableViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/14/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "AcceptorTableViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "RequestViewController.h"

@interface AcceptorTableViewController () {
    NSMutableArray *usernameList;  //Type String
    NSMutableArray *distanceList;
    NSMutableArray *durationList;
    NSMutableArray *locationList;
    NSMutableArray *foodList;
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    bool flag;
}

@end

@implementation AcceptorTableViewController
- (id)init
{
    self = [super init];
    if (self)
    {
        flag = true;
    }
    return self;
}

- (IBAction)logoutBtn:(id)sender {
    PFUser *currentUser = [PFUser currentUser]; // this will now be nil
    NSLog(@"%@ logged out",currentUser.username);
    [PFUser logOut];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self performSegueWithIdentifier:@"logoutUserSegue" sender:self];
}

-(void) viewDidAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize objects
    usernameList = [[NSMutableArray alloc]init];
    distanceList = [[NSMutableArray alloc]init];
    durationList = [[NSMutableArray alloc]init];
    locationList = [[NSMutableArray alloc]init];
    foodList = [[NSMutableArray alloc]init];;
    
    //Find self location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    //[locationManager startUpdatingLocation];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCalled) userInfo:nil repeats:NO];
    //[timer fire];
}

-(void)timerCalled {
    NSLog(@"Timer Called");
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //Stop updating location to limit the frquency of update
    //[locationManager stopUpdatingLocation];
    
    // Assigning the last object as the current location of the device
    CLLocation *sourceLocation = [locations lastObject];
    CLLocationDegrees sourceLat = sourceLocation.coordinate.latitude;
    CLLocationDegrees sourceLng = sourceLocation.coordinate.longitude;
    NSLog(@"lat%f - lon%f", sourceLat , sourceLng);
    
    
    
    //Code for updating
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"ReceiverLocation"];
    [query1 whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    PFObject *obj = [query1 getFirstObject];
    
            // The find succeeded.
            if (obj!= 0) {
                
                    PFQuery *query = [PFQuery queryWithClassName:@"ReceiverLocation"];
                
                    // Retrieve the object by id
                    [query getObjectInBackgroundWithId:obj.objectId block:^(PFObject *object, NSError *error) {
                        
                        if (!error) {
                            object[@"location"]=[PFGeoPoint geoPointWithLatitude:sourceLat longitude:sourceLng];
                            [object saveInBackground];
                        }
                        else{
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                            
                        }
                    }];
                
                
            
            } else {
                PFObject *driverLocation = [PFObject objectWithClassName:@"ReceiverLocation"];
                driverLocation[@"username"] = [[PFUser currentUser]username];
                driverLocation[@"location"] = [PFGeoPoint geoPointWithLatitude:sourceLat longitude:sourceLng];
                [driverLocation saveInBackground];
                
            }
    
    
    
    
    
    
    
    //Code for updating table
    PFQuery *query2 = [PFQuery queryWithClassName:@"ContributorRequest"];
    
    // Interested in locations near user.
    [query2 whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:latitude longitude:longitude]];
    
    // Limit what could be a lot of points.
    query2.limit = 10;
    
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            
            //Empty the list everytime update location is called and update with new nearby requests
            [usernameList removeAllObjects];
            [distanceList removeAllObjects];
            [durationList removeAllObjects];
            [locationList removeAllObjects];
            [foodList removeAllObjects];
            
            // Must to initialize the two arrays here because viewDidLoad is called before the constructor
            
            for (PFObject *object in objects) {
                
                //To check whether any person is already fetching the food. Do not add it to the table
                if (object[@"receiverResponded"]==nil) {
                
                [usernameList addObject:object[@"username"]];
                [locationList addObject:object[@"location"]];
                    [foodList addObject:object[@"foodName"]];
                PFGeoPoint *locationObject = object[@"location"];
                CLLocationDegrees destLat = locationObject.latitude;
                CLLocationDegrees destLng = locationObject.longitude;
                //CLLocation *contributorLocation = [location initWithLatitude:lat longitude:lng];
                //[CLLocationCoordinate2D
                //CLLocation *acceptorLocation = [location initWithLatitude:latitude longitude:longitude];
                //CLLocationDistance distance = [contributorLocation distanceFromLocation:location];
                // distance is a double representing the distance in meters
                //[distanceList addObject:[NSNumber numberWithDouble:distance]];
                NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=%f,%f&destinations=%f,%f&key=AIzaSyCWKeFXj_HmZrPp06Mx19UuhdqUhi3eDlA",sourceLat,sourceLng,destLat,destLng];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                
                NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                NSError *jsonParsingError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
                NSDictionary *jsonMap = json[@"rows"];
                NSString *distance = [[[jsonMap valueForKeyPath:@"elements.distance.text"] objectAtIndex:0]objectAtIndex:0];
                NSString *duration = [[[jsonMap valueForKeyPath:@"elements.duration.text"]objectAtIndex:0]objectAtIndex:0];
                NSLog(@"%@", [distance class]);

                //Ternary operation to check for null objects in case of junk values
                [distanceList addObject:(distance == [NSNull null])?@"NA":distance];
                [durationList addObject:(duration == [NSNull null])?@"NA":duration];
                }
            }
            self.tableView.reloadData;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [locationManager stopUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return usernameList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    //cell.textLabel.text = usernameList[indexPath.row];
    cell.textLabel.text = [usernameList[indexPath.row] stringByAppendingString:[NSString stringWithFormat:@" - Collect %@ from %@ away",foodList[indexPath.row],distanceList[indexPath.row]]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   // NSString *test = usernameList[[self.tableView.indexPathForSelectedRow row]];
    if ([segue.identifier  isEqual: @"ViewRequestSegue"]) {
        RequestViewController *rvc = [segue destinationViewController];
        rvc.requestLocation = locationList[[self.tableView.indexPathForSelectedRow row]];
        rvc.username = usernameList[[self.tableView.indexPathForSelectedRow row]];
    }
}


@end
