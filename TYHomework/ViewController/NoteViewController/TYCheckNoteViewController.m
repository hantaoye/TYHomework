//
//  TYCheckNoteViewController.m
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYCheckNoteViewController.h"
#import "TYNote.h"
#import "TYNoteDao.h"

static NSString *__identifier = @"cell";

@interface TYCheckNoteViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation TYCheckNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:__identifier];
    TYNote *note = _dataArray[indexPath.row];
    cell.textLabel.text = note.title;
    cell.detailTextLabel.text = note.timestamp;
    return cell;
}

- (void)setupData {
    _dataArray = [NSMutableArray array];
    NSArray *array = [[TYNoteDao sharedDao] getAllNotes];
    [_dataArray addObjectsFromArray:array];
}

#pragma mark searchBar 代理
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
   
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self searchDisplayController] searchResultsTableView] reloadData];
    });

}

@end
