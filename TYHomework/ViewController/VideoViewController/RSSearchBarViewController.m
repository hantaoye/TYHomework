//
//  RSSearchBarViewController.m
//  RSSearchBarTwo
//
//  Created by taoYe on 14/12/8.
//  Copyright (c) 2014年 RenYuXian. All rights reserved.
//

#import "RSSearchBarViewController.h"
#import "RSSearchBarView.h"
#import <CoreLocation/CoreLocation.h>
#import "RSUserTrackLocationDataSource.h"
#import "RSLocationManager.h"
#import "RSDebugLogger.h"
#import "RSStatistics.h"

@interface RSSearchBarViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate, RSSearchBarViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) RSSearchBarView *showView;
@property (nonatomic, strong) RSUserTrackRecentLocationDataSource *rds;
@property (nonatomic, strong) RSUserTrackLocationDataSource *lds;

@property (nonatomic, strong) RSUserTrackRecentTagDataSource *rtds;

@property (nonatomic, strong) id<UITableViewDataSource, RSUserTrackDataSourceProtocol> tagDataSource;
@end

@implementation RSSearchBarViewController

- (RSSearchBarView *)showView {
    if (!_showView) {
        _showView = [[RSSearchBarView alloc] init];
        _showView.delegate = self;
        _showView.backgroundColor = _searchVideoTag ? [UIColor blackColor] : [UIColor whiteColor];
    }
    return _showView;
}

- (BOOL)prefersStatusBarHidden {
    return _searchVideoTag;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TalkingData beginTrack:[self class]];

    [_searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TalkingData endTrack:[self class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *color = [[RSOptions option] defaultTextTintColor];
    [[self tableView] setBackgroundColor:[UIColor whiteColor]];
    if (_searchVideoTag) {
        [self.searchBar setBarTintColor:[UIColor blackColor]];
        [self.searchBar setTintColor:[UIColor blueColor]];
        
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = [UIColor blackColor];
        
        [[[self searchDisplayController] searchResultsTableView] setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [[[self searchDisplayController] searchResultsTableView] setBackgroundView:nil];
        [[[self searchDisplayController] searchResultsTableView] setBackgroundColor:[UIColor blackColor]];
        [self.searchBar becomeFirstResponder];
    } else {
    
    }
    
    [[RSLocationManager defaultManager] currentLocation:^(CLLocation *location, NSError *error) {
        if (error) {
            [RSDebugLogger error:error];
        }
    }];
    
    if (self.searchType == RSTagSearchNormal) {
        self.searchBar.placeholder = @"输入标签";
        _tagDataSource = [[RSUserTrackTagDataSource alloc] init];
        [(RSUserTrackTagDataSource *)_tagDataSource setTextColor:_searchVideoTag ? [UIColor whiteColor] : [UIColor blackColor]];
        [[self searchDisplayController] setSearchResultsDataSource:_tagDataSource];
        [[self searchDisplayController] setSearchResultsDelegate:self];
        _rtds = [[RSUserTrackRecentTagDataSource alloc] init];
        _rtds.textColor = _searchVideoTag ? color : [UIColor blackColor];
        
        [self.tableView addSubview:self.showView];
        NSMutableArray *textResults = [[NSMutableArray alloc] initWithCapacity:[[_rtds recentlyTag] count]];
        [[_rtds recentlyTag] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [textResults addObject:[obj tagName]];
        }];
        [self.showView addTags:textResults];
    } else if (self.searchType == RSTagSearchLocation) {
        self.searchBar.placeholder = @"输入地点";
        _rds = [[RSUserTrackRecentLocationDataSource alloc] init];
        if (_searchVideoTag) {
            [_rds setTextColor:[UIColor whiteColor]];
        }
        
        [_rds setTableView:[self tableView]];
        [[self tableView] setDataSource:_rds];
        [[self tableView] setDelegate:self];
        [_rds reload];
        
        RSUserTrackLocationDataSource *ds = [[RSUserTrackLocationDataSource alloc] init];
        ds.textColor = _searchVideoTag ? color : [UIColor blackColor];
        [ds setTableView:[[self searchDisplayController] searchResultsTableView]];
        _tagDataSource = ds;

//        [self.tableView setDataSource:_tagDataSource];
        [[self searchDisplayController] setSearchResultsDataSource:_tagDataSource];
        [[self searchDisplayController] setSearchResultsDelegate:self];
    }
}

#pragma mark searchBar 代理
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.showView.hidden = [searchText length] > 0;
//    [_tagDataSource search:searchText action:^(BOOL success) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[self tableView] reloadData];
//        });
//    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.showView.hidden = NO;
    if (_searchVideoTag) {
        [self setupTag:nil];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [_tagDataSource search:[searchBar text] action:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[self searchDisplayController] searchResultsTableView] reloadData];
        });
    }];
}

//加载(传递)数据
- (void)setupTag:(RSPhotoTag *)tag {
    if (tag != nil) {
        _currentTag.tagName = tag.tagName;
        if ([tag isKindOfClass:[RSLocationTag class]]) {
            RSLocationTag *lt = (RSLocationTag *)tag;
            if ([_currentTag isKindOfClass:[RSLocationTag class]]) {
                RSLocationTag *ct = (RSLocationTag *)_currentTag;
                ct.longitude = [lt longitude];
                ct.latitude = [lt latitude];
            }
        }
    }
    [self performSegueWithIdentifier: _unwindSegueIdentifier ? : @"segueForUnwindToEditTagOCViewController" sender:self];
}

#pragma mark tableView代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.searchType == RSTagSearchNormal) {
        RSUserTrackTagDataSource *tagDS = (RSUserTrackTagDataSource *)[tableView dataSource];
        RSPhotoTag *tag = [tagDS tagAtIndexPath:indexPath];
        if (tag != nil) {
            [tagDS addTag:tag];
            [self setupTag:tag];
        }
    } else {
        RSLocationTag *tag = nil;
        if (tableView != [self tableView]) {
            // POI
            RSUserTrackLocationDataSource *ds = (RSUserTrackLocationDataSource *)[tableView dataSource];
            tag = [ds tagAtIndexPath:indexPath];
        } else {
            tag = [_rds tagAtIndexPath:indexPath];
            if (tag) {
                [_rds addTag:tag];
            }
            
        }
        if (tag != nil) {
            [self setupTag:tag];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchType == RSTagSearchNormal) return 0;
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIColor *color = [UIColor clearColor];
    CGRect rect = CGRectMake(0, 0, 0, [[tableView delegate] tableView:tableView heightForHeaderInSection:section]);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = color;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor orangeColor];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setAutoresizingMask:UIViewAutoresizingNone];
    if ([((RSUserTrackRecentLocationDataSource *)_rds) _isRecentlyLocationSection:section]) {
        label.text = @"我的地点";
    } else {
        label.text = @"附近的地点";
    }
    [view addSubview:label];
    NSDictionary *viewBinding = NSDictionaryOfVariableBindings(label);
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[label]-15-|" options:0 metrics:nil views:viewBinding]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[label]-|" options:0 metrics:nil views:viewBinding]];
    [view updateConstraintsIfNeeded];
    return view;
}

#pragma mark showView的代理

- (void)searchBarView:(RSSearchBarView *)searchBarView didSelectedTagIndex:(NSInteger)tagIndex {
    // 针对normal tag
//    RSUserTrackTagDataSource *ds = (RSUserTrackTagDataSource *)[[self tableView] dataSource];
    RSPhotoTag *tag = [_rtds recentlyTag][tagIndex];
    if (tag) {
        [_rtds addTag:tag];
        [self setupTag:tag];
    }
}

@end
