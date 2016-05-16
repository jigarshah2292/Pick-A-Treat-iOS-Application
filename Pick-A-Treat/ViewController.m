//
//  ViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/9/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//
#import <Parse/Parse.h>

#import "ViewController.h"

@interface ViewController ()
{
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation ViewController
- (IBAction)logInBtn:(id)sender {
    if([self.username.text  isEqual: @""]){
        NSLog(@"EMPTY LOGIN");
        UIAlertView *emptyCheckAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect input" message:@"Please enter all the values" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emptyCheckAlert show];
    }
    else {
        [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text
                                        block:^(PFUser *user, NSError *error) {
        if (user) {
            NSLog(@"SUCCESS LOGIN");
            [self performSegueWithIdentifier:@"loginUserSegue" sender:self];
            
        } else {
            NSLog(@"FAILED LOGIN");
            UIAlertView *logInErrorAlert = [[UIAlertView alloc] initWithTitle:@"Login error" message:@"Please try again with valid credentials" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [logInErrorAlert show];
            self.username.text = @"";
            self.password.text = @"";
        }
        }];

    }
    
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    
}

- (IBAction)signUpBtn:(id)sender {
    
    if([self.username.text  isEqual: @""]){
        NSLog(@"EMPTY SIGNUP");
        UIAlertView *emptyCheckAlert = [[UIAlertView alloc] initWithTitle:@"Incorrect input" message:@"Please enter all the values" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emptyCheckAlert show];
    }
    else {
        PFUser *user = [PFUser user];
        user.username = self.username.text;
        user.password = self.password.text;
        //user.email = @"email@example.com";
        
        // other fields can be set just like with PFObject
        //user[@"phone"] = @"415-392-0202";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"SUCCESSFUL SIGNUP");
                UIAlertView *signUpSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have succesfully registered. Thank you." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [signUpSuccessAlert show];
                [self performSegueWithIdentifier:@"loginUser" sender:self];
            } else {
                NSLog(@"FAILED SIGNUP");
                UIAlertView *signUpErrorAlert = [[UIAlertView alloc] initWithTitle:@"Signup error" message:@"Username already in use. Please try a different username" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [signUpErrorAlert show];
            }
        }];
    }
    
    

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*PFObject *testObject = [PFObject objectWithClassName:@"Person"];
    testObject[@"Name"] = @"Jigar";
    [testObject saveInBackground];
     */
    //ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    //[self.view addSubview:adView];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    
    loginButton.frame=CGRectMake(132.0, 380.0, 80.0, 40.0);
    [self.view addSubview:loginButton];
    
    //self.view.contentSize=CGSizeMake(306,400.0);
    
    loginButton.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%@ logged out",currentUser.username);
    if (currentUser.username != nil) {
        NSLog(@"CURRENT USER");
        [self performSegueWithIdentifier:@"loginUserSegue" sender:self];
    } else {
        // show the signup or login screen
    }
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        _bannerIsVisible = YES;
    }
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        _bannerIsVisible = NO;
    }
}

@end
