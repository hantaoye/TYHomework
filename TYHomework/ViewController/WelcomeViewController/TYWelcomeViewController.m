//
//  TYWelcomeViewController.m
//  TYHomework
//
//  Created by taoYe on 15/3/2.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYWelcomeViewController.h"
#import "TYViewControllerLoader.h"

@interface TYWelcomeViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation TYWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
}

- (void)setupData {
    NSArray *imageArray = @[@"letter-paper22", @"letter-paper24", @"letter-paper26"];
    for (int i = 0; i < imageArray.count; i++) {
        NSString *imageName = imageArray[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * TYScreenWidth, 0, TYScreenWidth, TYScreenHeight)];
        UIImage *image = [UIImage imageNamed:imageName];
        imageView.image = image;
        [_scrollView addSubview:imageView];
    }
    
    UIImageView *imageView = [_scrollView.subviews lastObject];
    imageView.userInteractionEnabled = YES;
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, TYScreenHeight / 2, TYScreenWidth - 200, 50)];
    [nextBtn setTitle:@"立即体验" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [nextBtn setBackgroundImage:[UIImage imageNamed:@"pdf-footer"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextVC) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:nextBtn];
    
    _pageControl.numberOfPages = imageArray.count;
    
    _scrollView.contentSize = CGSizeMake(imageArray.count * TYScreenWidth, 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
}

- (void)nextVC {
    [TYViewControllerLoader loadResgiterEntry];
}

#pragma mark -
#pragma mark scrollviewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _pageControl.currentPage = (scrollView.contentOffset.x / TYScreenWidth) - 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
