//
//  TYWirteNoteViewController.m
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYWirteNoteViewController.h"
#import "TYPlaceholderTextView.h"
#import "TYNote.h"
#import "TYNoteDao.h"

@interface TYWirteNoteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *drawImageButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet TYPlaceholderTextView *textView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;

@property (strong, nonatomic) TYNoteDao *dao;
@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSString *drawIamgeURL;
@property (copy, nonatomic) NSString *audioURL;

@end

@implementation TYWirteNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    _dao = [TYNoteDao sharedDao];
}

- (IBAction)pressedVideoButton:(UIButton *)sender {
}
- (IBAction)pressedPhotoButton:(UIButton *)sender {
}
- (IBAction)drawButton:(UIButton *)sender {
}
- (IBAction)pressedAudioButton:(UIButton *)sender {
}

- (IBAction)pressedSaveButton:(UIBarButtonItem *)sender {
    if (!_titleTextField.text.length) {
        [RSProgressHUD showWithStatus:@"请输出标题"];
        return;
    }
    
    if (!_textView.text.length && !_videoPath && !_imageURL && !_drawIamgeURL && !_audioURL) {
        [RSProgressHUD showWithStatus:@"请选择填充内容"];
    }
    
    [_dao insertNoteWithID:0 title:_titleTextField.text desc:_textView.text videoPagth:_videoPath imageURL:_imageURL drawImageURL:_drawIamgeURL audioURL:_audioURL action:^(TYNote *note) {
        run(^{
            [RSProgressHUD showSuccessWithStatus:@"保存成功"];
#warning 进入首页
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
