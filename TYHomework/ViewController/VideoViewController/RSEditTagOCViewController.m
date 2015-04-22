//
//  RSEditTagOCViewController.m
//  FITogether
//
//  Created by shaveKevin on 14/12/8.
//  Copyright (c) 2014年 closure. All rights reserved.
//

#import "RSEditTagOCViewController.h"
#import "RSTag.h"
#import "TalkingData.h"
#import "RSSearchBarViewController.h"
#import "RSStatistics.h"
#import "RSTrackPostTableViewController.h"
#import "RSTagImageView.h"

@interface RSEditTagOCViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageOfTagAndLocation;
@property (strong, nonatomic) IBOutlet UIView *popView;
@property (weak, nonatomic) IBOutlet UIButton *popTagButton;
@property (weak, nonatomic) IBOutlet UIButton *popLocationButton;

@property (nonatomic, assign) RSTagSearchType currentSearchType;
@property (nonatomic, strong) RSPhotoTag *photoTag;
@property (nonatomic, strong) RSLocationTag *locationTag;
@property (nonatomic, assign) CGPoint tapLocationScale;
@property (nonatomic, assign) CGPoint tapLocation;

@property (nonatomic, strong) RSLocationTag *movingTag;


@property (nonatomic, strong) RSDraggableArrowView *arrowView;

@end

@implementation RSEditTagOCViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TalkingData beginTrack:[self class]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TalkingData endTrack:[self class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageOfTagAndLocation.image = _editImage;

    _imageOfTagAndLocation.userInteractionEnabled = YES;
    [[self popView] setFrame:[[self view] bounds]];
   // [self.view addSubview:_popView];
    _tags = [[NSMutableArray alloc] initWithCapacity:4];
}

- (RSDraggableArrowView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[RSDraggableArrowView alloc] initWithFrame:CGRectZero];
    }
    return _arrowView;
}

- (IBAction)tapToTagAndLocation:(UITapGestureRecognizer *)sender{
    for (RSDraggableArrowView *arrowView in self.imageOfTagAndLocation.subviews) {
        arrowView.alpha = 1;
    }

    [[self popView] setAlpha:0];
    [[self view] addSubview:[self popView]];
    [UIView animateWithDuration:0.5 animations:^{
        _arrowView.alpha = 1;
        [[self popView] setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
    
    CGFloat width = _imageOfTagAndLocation.bounds.size.width;
    CGFloat height = _imageOfTagAndLocation.bounds.size.height;
    _tapLocation = [sender locationInView:[self imageOfTagAndLocation]];
    _tapLocationScale = CGPointMake(_tapLocation.x / width * 1000, _tapLocation.y / height * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)popViewTapGesture:(UITapGestureRecognizer *)sender {
    [self hiddenPopView];
//    [_tags removeLastObject];
}

- (IBAction)tagButtonPressed:(id)sender {
    _currentSearchType = RSTagSearchNormal;
    _photoTag = [[RSPhotoTag alloc] initWithID:0 tagName:@"" x:_tapLocationScale.x y:_tapLocationScale.y isLeftDirection:true type:0];
    [self performSegueWithIdentifier:@"segueForSearchBar" sender:self];
}

- (IBAction)locationButtonPressed:(id)sender {
    _currentSearchType = RSTagSearchLocation;
    _locationTag = [[RSLocationTag alloc] initWithID:0 tagName:@"" x:_tapLocationScale.x y:_tapLocationScale.y isLeftDirection:true type:0];
    [self performSegueWithIdentifier:@"segueForSearchBar" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//when viewcontroller pushed to judge which is the datasource
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueForSearchBar"]) {
        RSSearchBarViewController* searchBarViewController = (RSSearchBarViewController *)[segue destinationViewController];
        [searchBarViewController setSearchType:_currentSearchType];
        switch (_currentSearchType) {
            case RSTagSearchNormal:
                [searchBarViewController setCurrentTag:(RSLocationTag *)_photoTag];
                
                break;
            case RSTagSearchLocation:
                [searchBarViewController setCurrentTag:_locationTag];
                break;
            default:
                break;
        }
    } else if ([[segue identifier] isEqualToString:@"seugeForPhotoPost"]) {
        RSTrackPostTableViewController *trackPostTableVC = (RSTrackPostTableViewController *)[segue destinationViewController];
        [trackPostTableVC setImage:_editImage];
        
        NSArray *filtertags = [_tags filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RSPhotoTag *tag, NSDictionary *bindings) {
            return tag.tagName != nil && ![tag.tagName isEqualToString:@""];
        }]];
        [trackPostTableVC setTags:filtertags];
        [trackPostTableVC setLocationName:[_locationTag tagName]];
    }
}
//when data  passed by the controller you can judge which one would be presented
- (IBAction)unwindToEditTagOCViewController:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"segueForUnwindToEditTagOCViewController"]) {
        [self hiddenPopView];
        RSSearchBarViewController *searchBarViewController = (RSSearchBarViewController *)[segue sourceViewController];
        [searchBarViewController setSearchType:_currentSearchType];
        
        switch (_currentSearchType) {
            case RSTagSearchNormal: {
                _movingTag = (RSLocationTag *)[searchBarViewController currentTag];
                [[self arrowView] setText:[_movingTag tagName]];
                [self setPhotoTag:_movingTag];
                [_tags addObject:_photoTag];
                [[self arrowView].animationView startAnimations];
                [self.arrowView addObserver:self forKeyPath:@"tipPoint" options:NSKeyValueObservingOptionNew context:nil];
            }
                break;
            case RSTagSearchLocation: {
                _movingTag = (RSLocationTag *)[searchBarViewController currentTag];
                [[self arrowView] setText:[_movingTag tagName]];
                [self setLocationTag:_movingTag];
                [_tags addObject:_movingTag];
                [[self arrowView].animationView startAnimations];
                [self.arrowView addObserver:self forKeyPath:@"tipPoint" options:NSKeyValueObservingOptionNew context:nil];
            }
                break;
            default:
                break;
        }
        
//        CGFloat width = _imageOfTagAndLocation.bounds.size.width;
//        CGFloat height = _imageOfTagAndLocation.bounds.size.height;

//        _movingTag.x = _movingTag.x / width;
//        _movingTag.y = _movingTag.y / height;

        [[self arrowView] setTipPoint:_tapLocation];
        _tapLocation = CGPointZero;
        [[self arrowView] setupAppearance];
    
        [[self arrowView] setHidden:YES];
        [[self arrowView] popAtView:[self imageOfTagAndLocation]];
        [[self arrowView] setHidden:NO];
        
        
        [[self imageOfTagAndLocation] addSubview:[self arrowView]];
        if (![[self arrowView] isLeft]) {
            // Right
//            CGRect frame = self.arrowView.frame;
//            frame.origin.x -= 100;//frame.size.width;
//            NSLog(@"%f", frame.size.width);
//            self.arrowView.frame = frame;
           // self.arrowView.transform = CGAffineTransformMakeTranslation(-200, 10);
        }
        _arrowView = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tipPoint"]) {
        RSDraggableArrowView *arrowView = (RSDraggableArrowView *)object;
        CGFloat width = _imageOfTagAndLocation.bounds.size.width;
        CGFloat height = _imageOfTagAndLocation.bounds.size.height;

        _movingTag.x = arrowView.tipPoint.x / width * 1000;
        _movingTag.y = arrowView.tipPoint.y / height * 1000;
//        NSLog(@"%@ -> %@", NSStringFromSelector(_cmd), NSStringFromCGPoint(CGPointMake(_movingTag.x, _movingTag.y)));
    }
}

- (void)dealloc {
    for (RSDraggableArrowView *arrowView in [self.imageOfTagAndLocation subviews]) {
        [arrowView removeObserver:self forKeyPath:@"tipPoint"];
    }
}

#pragma mark - In order to hide popview -
- (void)hiddenPopView{
    [UIView animateWithDuration:0.5 animations:^{
        [[self popView] setAlpha:0];
    } completion:^(BOOL finished) {
        [[self popView] removeFromSuperview];
        [[self popView] setAlpha:1];
    }];
    
}
@end
