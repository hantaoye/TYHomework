//
//  RSTrackPostTableViewController.m
//  FITogether
//
//  Created by closure on 12/28/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#import "RSTrackPostTableViewController.h"
#import "RSTrackEditPhotoViewController.h"
#import "CTAssetsPickerController.h"
#import "RSEditTagOCViewController.h"
#import "RSTrackViewController.h"
#import "RSSearchBarViewController.h"
#import "RSVideoTagViewController.h"
#import "UIImage+TY.h"
#import "RSTag.h"
#import "RSDebugLogger.h"
#import "RSSharedStorage.h"
#import "RSLocationManager.h"
#import "RSPlaceholderTextView.h"
#import "RSStatistics.h"
#import "RSPhoto.h"
#import "RSPhotoAccess.h"
#import "RSProgressHUD.h"
#import "RSPasswordEncoder.h"
#import "RSShowTagView.h"

@interface RSTrackPostTableViewController () <UIScrollViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet RSPlaceholderTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sharedBarButton;
@property (weak, nonatomic) IBOutlet RSShowTagView *tagListView;

//@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UITapGestureRecognizer *gesture;

@property (nonatomic, strong) RSLocationTag *searchBarTag;

@property (nonatomic, strong) RSLocationManager *locationManager;

@end

@implementation RSTrackPostTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBarTag = [[RSLocationTag alloc] initWithID:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEditTextView:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditTextView:) name:UIKeyboardWillHideNotification object:nil];
    
    [_tagListView setAddButtonAction:^{
        [self performSegueWithIdentifier:@"segueForTrackViewController" sender:self];
    }];
    
    _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self.textView action:@selector(resignFirstResponder)];
    if (_image) {
        [self setImage:_image];
    }
}

- (void)setSelectedTags:(NSArray *)selectedTags {
    _selectedTags = selectedTags;
    [self setupTagListView];
    if (selectedTags) {
        [self.tagListView setTags:_selectedTags];
    }
}


- (void)sharedButtonSetHighlighted:(BOOL)highlighted {
    [_sharedBarButton setEnabled:highlighted];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self sharedButtonSetHighlighted:([[textView text] length] > 0)];
}

- (void)setupTagListView {
    _tagListView.horizontalMagin = 5.0;
    _tagListView.border = 5.0;
//    _tagListView.oneLine = YES;
//    [_tagListView setAutomaticResize:YES];
//    _tagListView.scroll = YES;
//    [_tagListView setTagDelegate:self];
//    [_tagListView setCornerRadius:4.0f];
//    [_tagListView setBorderColor:[UIColor lightGrayColor]];
//    [_tagListView setBorderWidth:1.0f];
//    [_tagListView setHighlightedBackgroundColor:[UIColor lightGrayColor]];
//    [_tagListView setFont:[UIFont systemFontOfSize:12]];    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startEditTextView:(NSNotification *)notification {
    [self.tableView addGestureRecognizer:_gesture];
    self.tableView.transform = CGAffineTransformIdentity;
}

- (void)endEditTextView:(NSNotification *)notification {
    [[self tableView] removeGestureRecognizer:_gesture];
}

- (IBAction)pickerImagePressed:(UIButton *)sender {
    
//    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
//    [picker setAssetsLibrary:_library];
//    picker.assetsFilter              = [ALAssetsFilter allPhotos];
//    picker.showsCancelButton         = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
//    picker.delegate                  = self;
//    [self presentViewController:picker animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (IBAction)cancelPressed:(id)sender {
//    [self dismissViewControllerAnimated:true completion:^{
//        
//    }];
//}


#pragma mark - Assets Picker Delegate

//- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group {
//    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
//}
//
//- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
//    _assets = assets;
//    [picker dismissViewControllerAnimated:YES completion:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self performSegueWithIdentifier:@"segueForEditPhoto" sender:self];
//        });
//    }];
//}
//
//- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset {
//    return (picker.selectedAssets.count < 2 && asset.defaultRepresentation != nil);
//}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.imageView setImage:image];
}

#pragma mark - Unwind

- (void)handleEditTagViewContoller:(RSEditTagOCViewController *)vc {
    [self.imageView setImage:_image = vc.editImage];
    [self setTags:[vc tags]];
}

- (void)handleVideoTagViewController:(RSVideoTagViewController *)vc {
    [self.imageView setImage:_image = vc.previewImage];
    [self setTags:[vc tags]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueForEditPhoto"]) {
//        UINavigationController *navigationController = (UINavigationController *)([segue destinationViewController]);
//        RSTrackEditPhotoViewController *destinationViewController = (RSTrackEditPhotoViewController *)[[navigationController viewControllers] firstObject];
//        [destinationViewController setAssets:_assets];
//        [destinationViewController setDeleteAfterDone:_deleteAfterDone];
    } else if ([[segue identifier] isEqualToString:@"segueForSearchBar"]) {
        RSSearchBarViewController *searchBarVC = (RSSearchBarViewController *)[segue destinationViewController];
        [searchBarVC setCurrentTag:_searchBarTag];
        [searchBarVC setUnwindSegueIdentifier:@"unwindToPostTableViewController"];
    } else if ([[segue identifier] isEqualToString:@"segueForTrackViewController"]) {
        UINavigationController *navVC = [segue destinationViewController];
        RSTrackViewController *trackVC = navVC.viewControllers[0];
        trackVC.selectedTags = _selectedTags;
    }
}

- (IBAction)unwindToPostTableViewController:(UIStoryboardSegue *)sender {
    if ([[sender sourceViewController] isKindOfClass:[RSEditTagOCViewController class]]) {
        [self handleEditTagViewContoller:[sender sourceViewController]];
    } else if ([[sender sourceViewController] isKindOfClass:[RSSearchBarViewController class]]) {
        //        RSSearchBarViewController *searchBarVC = (RSSearchBarViewController *)([sender destinationViewController]);
        [RSDebugLogger debug:@"unwind from searchbar vc"];
    } else if ([[sender sourceViewController] isKindOfClass:[RSVideoTagViewController class]]) {
        [self handleVideoTagViewController:[sender sourceViewController]];
    } else if ([[sender sourceViewController] isKindOfClass:[RSTrackViewController class]]) {
        
    }
}

#pragma mark - Update

- (NSArray *)makeCardTags {
    if ([_selectedTags count] == 0) {
        return nil;
    }
    NSMutableArray *cards = [[NSMutableArray alloc] initWithCapacity:[_selectedTags count]];
    for (NSString *t in _selectedTags) {
        RSPhotoTag *pt = [[RSPhotoTag alloc] initWithID:0 tagName:t type:1];
        [cards addObject:pt];
    }
    return cards;
}

- (BOOL)__sharePhotoToWeibo:(RSPhoto *)photo {
    RSWeiboSDKConnector *weiboDelegate = [[[RSSharedStorage sharedStorage] middleware] weiboDelegate];
    if ([_shareToWeiboSwitch isOn]) {
        [weiboDelegate sharePhoto:photo];
    }
    return YES;
}

- (IBAction)sharePressed:(id)sender {
    if ([[_textView text] complexLength] > 140) {
        [RSProgressHUD showErrorWithStatus:@"输入不得多于140字符"];
        return;
    }
    RSBaseAccount *author = [[RSSharedStorage sharedStorage] currentAccount];
    RSPhoto *photo = [[RSPhoto alloc] initWithID:0];
    [photo setDesc:[_textView text]];
    [photo setTags:_tags];
    [photo setCards:[self makeCardTags]];
    [photo setAuthor:author];
    [photo setLocationDescription:[_locationLabel text] ?: @""];
    [photo setLatitude:_coordinate2D.latitude];
    [photo setLongitude:_coordinate2D.longitude];
    
    [RSProgressHUD show];
    
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 2), ^{
        [RSDebugLogger debug:@"compressing image......."];
        NSData*data = UIImageJPEGRepresentation(_image, 1);
        [RSDebugLogger debugFormat:@"image original size -> %ld", (unsigned long)[data length]];
        [photo setImageData:[_image compressPhoto]];
        data = [photo imageData];
        [RSDebugLogger debugFormat:@"image compressed size -> %ld", (unsigned long)[data length]];
        [RSDebugLogger debug:@"compressing image done!!!"];
        
        [RSPhotoAccess create:photo external:nil action:^(RSPhoto *p, NSError *error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RSProgressHUD showErrorWithStatus:@"发送失败>...<"];
                });
                return;
            } else {
                RSBaseAccount *account = [[RSSharedStorage sharedStorage] currentAccount];
                account.continueCards++;
                account.cardCount++;
                [[NSNotificationCenter defaultCenter] postNotificationName:RSTrackViewControllerDidPostPhotoNotification  object:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    BOOL needShareToWeibo = [_shareToWeiboSwitch isOn];
                    
                    if (needShareToWeibo) {
                        [weakSelf __sharePhotoToWeibo:photo];
                    }
                    
                    [RSProgressHUD showSuccessWithStatus:@"发送成功~"];
//                    [weakSelf performSegueWithIdentifier:@"unwindToVideoViewController" sender:weakSelf];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[_searchBarTag tagName] length]) {
        _locationName = [_searchBarTag tagName];
        _coordinate2D = CLLocationCoordinate2DMake([_searchBarTag latitude], [_searchBarTag longitude]);
    }
    for (RSPhotoTag *t in _tags) {
        if ([t isKindOfClass:[RSLocationTag class]] && [[t tagName] length]) {
            RSLocationTag *lt = (RSLocationTag *)t;
            _locationName = [lt tagName];
            _coordinate2D = CLLocationCoordinate2DMake([lt latitude], [lt longitude]);
            break;
        }
    }
    
    if ([_locationName length]) {
        [_locationLabel setText:_locationName];
        [_locationButton setImage:[UIImage imageNamed:@"map-green"] forState:UIControlStateNormal];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.textView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointMake(0, -64);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [RSProgressHUD dismiss];
    [TalkingData beginTrack:[self class]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TalkingData endTrack:[self class]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.complexLength > 199 && range.length == 0) {
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
    return 25;
    }
    return 0;
}

@end
