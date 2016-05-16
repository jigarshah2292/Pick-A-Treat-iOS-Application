//
//  ViewController.h
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/9/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController<ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

