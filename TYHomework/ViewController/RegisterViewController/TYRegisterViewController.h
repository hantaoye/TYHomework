//
//  RSRegisterViewController.h
//  FITogether
//
//  Created by closure on 2/5/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYRegisterViewController : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyPasswordTextField;

@end
