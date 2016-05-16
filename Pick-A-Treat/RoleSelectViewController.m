//
//  RoleSelectViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/11/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "RoleSelectViewController.h"
#import <Parse/Parse.h>

@interface RoleSelectViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *selectSwitch;

@end

@implementation RoleSelectViewController
@synthesize backButton;

//Just a check method. Not needed.
- (IBAction)switchAction:(id)sender {
    if (self.selectSwitch.on) {
        NSLog(@"ON");
    }
    else {
        NSLog(@"OFF");
    }
}
- (IBAction)nextBtn:(id)sender {
    if (self.selectSwitch.on) {
        NSLog(@"GIVE");
        PFQuery *query = [PFQuery queryWithClassName:@"ContributorRequest"];
        [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
        PFObject *object = [query getFirstObject];
        if (object==nil) {
            [self performSegueWithIdentifier:@"addFoodDetailsSegue" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"giverSegue" sender:self];
        }
    }
    else {
        NSLog(@"TAKE");
        [self performSegueWithIdentifier:@"takerSegue" sender:self];
    }
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
*/

@end
