//
//  AddFoodDetailsViewController.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/28/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "AddFoodDetailsViewController.h"
#import "DonorViewController.h"
#import <Parse/Parse.h>

@interface AddFoodDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;


@end

@implementation AddFoodDetailsViewController
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}
- (IBAction)logoutButton:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"logoutUserSegue" sender:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"giverSegue"]) {
        DonorViewController *dvc = [segue destinationViewController];
        dvc.foodName = self.nameTextField.text;
        dvc.noOfPeople = self.quantityTextField.text;
    }
    
 
}


@end
