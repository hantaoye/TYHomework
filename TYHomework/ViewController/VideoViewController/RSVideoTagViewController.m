//
//  RSVideoTagViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/5.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "RSVideoTagViewController.h"
#import "DWTagList.h"
#import "RSSearchBarViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RSVideo.h"
#import "RSTag.h"
#import "RSVideoAssetCompressor.h"
#import "RSPlaceholderTextView.h"
#import "RSProgressHUD.h"
#import "RSPasswordEncoder.h"
#import "UIView+Ellipse.h"
#import "RSStatistics.h"
#import "UIImageView+LBBlurredImage.h"
#import "RSPlayerView.h"

@interface RSVideoTagViewController () <DWTagListDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@property (weak, nonatomic) IBOutlet RSPlayerView *playerView;

@property (weak, nonatomic) IBOutlet DWTagList *tagListView;
@property (weak, nonatomic) IBOutlet UIButton *tagBtn;
@property (nonatomic, strong) NSMutableArray *tagNames;
@property (weak, nonatomic) UIButton *locationBtn;
@property (nonatomic, weak) IBOutlet UIButton *showLocationBtn;

@property (weak, nonatomic) IBOutlet RSPlaceholderTextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;


@property (nonatomic, assign) RSTagSearchType currentSearchType;
@property (nonatomic, strong) RSTag *tag;
@property (nonatomic, strong) RSLocationTag *locationTag;
@property (nonatomic, strong) NSMutableArray *generalTags;

@property (nonatomic, strong) UITapGestureRecognizer *gesture;

@end

@implementation RSVideoTagViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tags = [NSMutableArray array];
    _tagNames = [NSMutableArray array];
    _generalTags = [NSMutableArray array];
    [_textView setPlaceholder:@"分享一下你的锻炼内容"];
    [self setupTagList];
    
    UIButton *location = [[UIButton alloc] init];
    location.titleLabel.font = [UIFont systemFontOfSize:12];
    location.backgroundColor = [UIColor lightGrayColor];
    [location setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [location setImage:[UIImage imageNamed:@"video-location"] forState:UIControlStateNormal];
    [location addTarget:self action:@selector(addLocationBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    location.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.tagBtn.superview addSubview:location];
    _locationBtn = location;

    [_tagBtn becomeEllipseViewWithBorderColor:0 borderWidth:0 cornerRadius:_tagBtn.frame.size.height / 2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEditTextView:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditTextView:) name:UIKeyboardWillHideNotification object:nil];
    _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self.textView action:@selector(resignFirstResponder)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [_playerView setAsset:self.asset];
    [self setupBackgroundView];
}

- (void)setupBackgroundView {
    [RSProgressHUD show];
    [RSVideo generateImage:self.asset action:^(UIImage *image, NSError *error) {
        [_backgroundView setImageToBlur:image blurRadius:17.0 completionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [RSProgressHUD dismiss];
            });
        }];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startEditTextView:(NSNotification *)notification {
    [self.view addGestureRecognizer:_gesture];
}

- (void)endEditTextView:(NSNotification *)notification {
    [self.view removeGestureRecognizer:_gesture];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([@"\n" isEqualToString:text]){
        [textView resignFirstResponder];
        return YES;
    }
    if (textView.text.complexLength > 100 && range.length == 0) {
        return NO;
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    [self sharedButtonSetHighlighted:([[textView text] length] > 0)];
}

- (void)sharedButtonSetHighlighted:(BOOL)highlighted {
    [_shareBtn setEnabled:highlighted];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self setupLocation];
    
    if (_tagNames.count) {
        [_tagListView setTags:_tagNames];
        _tagListView.hidden = NO;
    } else {
        _tagListView.hidden = YES;
    }
    
    _tagBtn.enabled = _generalTags.count < 3;
    _playerView.frame = _playerView.frame;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_playerView pause];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TalkingData beginTrack:[self class]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TalkingData endTrack:[self class]];
}

- (void)setupLocation {
//    [_locationBtn setBackgroundColor:[UIColor lightGrayColor]];
    if (_locationTag && ![_locationTag.tagName isEqualToString:@""] && _locationTag.tagName != nil) {
        [_locationBtn setTitle:_locationTag.tagName forState:UIControlStateNormal];
        CGSize size = [_locationTag.tagName boundingRectWithSize:CGSizeMake(120, _tagBtn.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
        _locationBtn.frame = CGRectMake(CGRectGetMaxX(_tagBtn.frame) + 10, _tagBtn.frame.origin.y, size.width + 32, _tagBtn.frame.size.height);
        [_locationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [_locationBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
        _locationBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_showLocationBtn setTitle:_locationTag.tagName forState:UIControlStateNormal];
        
        _showLocationBtn.hidden = NO;
        
    } else {
        [_locationBtn setTitle:@"" forState:UIControlStateNormal];
        _locationBtn.frame = CGRectMake(CGRectGetMaxX(_tagBtn.frame) + 10, _tagBtn.frame.origin.y, _tagBtn.frame.size.height, _tagBtn.frame.size.height);
        
        _showLocationBtn.hidden = YES;
    }
    [_locationBtn becomeEllipseViewWithBorderColor:nil borderWidth:0 cornerRadius:_locationBtn.bounds.size.height / 2];
}

- (void)setupTagList {
    [_tagListView setAutomaticResize:YES];
    [_tagListView setTagDelegate:self];
    [_tagListView setTextColor:[UIColor grayColor]];
    [_tagListView setTagBackgroundColor:[UIColor lightGrayColor]];
    [_tagListView setTextShadowOffset:CGSizeMake(0, 0)];
    [_tagListView setTextShadowColor:[UIColor clearColor]];
    _tagListView.horizontalPadding = 5.0f;
    _tagListView.verticalPadding = 2;
    [_tagListView setCornerRadius:_tagListView.frame.size.height / 2];
    _tagListView.font = [UIFont systemFontOfSize:12];
    [_tagListView setBorderWidth:0.0f];
    [_tagListView setOneLine:YES];
}

- (IBAction)unwindToVideoTagViewController:(UIStoryboardSegue *)segue {
    UIViewController *sourceVC = segue.sourceViewController;
    if ([sourceVC isKindOfClass:[RSSearchBarViewController class]]) {
        RSSearchBarViewController *VC = (RSSearchBarViewController *)sourceVC;
        if (VC.currentTag.tagName == nil || [VC.currentTag.tagName isEqualToString:@""]) {
            return;
        }
        BOOL isNotContains = NO;
        @synchronized (self.generalTags) {
           isNotContains = ![_tagNames containsObject:VC.currentTag.tagName] && ![VC.currentTag isKindOfClass:[RSLocationTag class]];
        }
        if (isNotContains && self.generalTags.count < 3) {
            [self.generalTags addObject:VC.currentTag];
            [_tagNames addObject:VC.currentTag.tagName];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueForSearchBar"]) {
        RSSearchBarViewController *destinationVC = segue.destinationViewController;
        destinationVC.searchVideoTag = YES;
        destinationVC.unwindSegueIdentifier = @"unwindToVideoTagViewController";
        [destinationVC setSearchType:_currentSearchType];
        switch (_currentSearchType) {
            case RSTagSearchNormal:
                [destinationVC setCurrentTag:(RSLocationTag *)_tag];
                break;
            case RSTagSearchLocation:
                [destinationVC setCurrentTag:_locationTag];
                break;
            default:
                break;
        }
    }
}
- (IBAction)addTagBtnPressed:(UIButton *)sender {
    _currentSearchType = RSTagSearchNormal;
    _tag = [[RSTag alloc] initWithID:0 tagName:@"" type:0];
    [self performSegueWithIdentifier:@"segueForSearchBar" sender:self];

}
- (IBAction)addLocationBtnPressed:(UIButton *)sender {
    _currentSearchType = RSTagSearchLocation;
    if (!_locationTag) {
        _locationTag = [[RSLocationTag alloc] initWithID:0 tagName:@"" type:0];
    }
    
    [self performSegueWithIdentifier:@"segueForSearchBar" sender:self];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)donePressed:(UIButton *)sender {
    if (_locationTag && ![_locationTag.tagName isEqualToString:@""] && _locationTag.tagName != nil) {
        [_generalTags addObject:_locationTag];
    }
    self.tags = _generalTags;
    self.desc = _textView.text;
    sender.enabled = NO;
    [self shareVideo:sender];
}

@end
