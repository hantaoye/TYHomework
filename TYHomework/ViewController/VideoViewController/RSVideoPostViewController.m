//
//  RSVideoPostViewController.m
//  FITogether
//
//  Created by closure on 3/5/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSVideoPostViewController.h"
#import "TYAccount.h"
#import "RSProgressHUD.h"
#import "RSVideoAccess.h"
#import "RSTrackViewController.h"
#import "UIImage+TY.h"

@interface RSVideoPostViewController ()

@end

@implementation RSVideoPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _desc = @"";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareVideo:(id)sender {
    if (_asset == nil) {
        return;
    }
    TYAccount *author = [[TYShareStorage shareStorage] account];
    RSVideo *video = [[RSVideo alloc] initWithID:0];
    [video setDesc:_desc];
    NSArray *filtertags = [_tags filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RSPhotoTag *tag, NSDictionary *bindings) {
        return tag.tagName != nil && ![tag.tagName isEqualToString:@""];
    }]];

    [video setTags:filtertags];
    [video setAuthor:author];
    [video setVideoAsset:_asset];
    [RSProgressHUD show];
    __weak __typeof(self) weakSelf = self;
    
    id block = ^{
        [RSVideoAccess create:video action:^(RSVideo *v, NSError *error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"发送失败>...<"];
                    UIButton *btn = sender;
                    btn.enabled = YES;
                });
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:RSTrackViewControllerDidPostPhotoNotification  object:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showSuccessWithStatus:@"发送成功~"];
                    [weakSelf performSegueWithIdentifier:@"unwindToVideoViewController" sender:weakSelf];
                });
            }
        }];
    };
    
    if (_previewImage) {
        NSData *data = [_previewImage compressPhoto];
        [video setImageData:data];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 2), block);
    } else {
        [RSVideo generateImage:_asset action:^(UIImage *image, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:[error localizedDescription]];
                });
            } else {
                NSData *data = [_previewImage compressPhoto];
                [video setImageData:data];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 2), block);
            }
        }];
    }
}
@end
