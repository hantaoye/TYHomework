//
//  RSClassHomeNavigationContorller.m
//  FITogether
//
//  Created by closure on 3/15/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "RSNavigationController.h"
#import "RSOptions.h"
#import "TYDebugLog.h"

@interface RSNavigationControllerX ()

@end

@implementation RSNavigationControllerX

- (void)viewDidLoad {
    [super viewDidLoad];
//    _barTintColor = _barTintColor ? : [[RSOptions option] blueprintTableViewBackgroundColor];
//    [[self navigationBar] setBarTintColor:_barTintColor];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[self viewControllers] count]) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

//- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSArray *array = [super popToViewController:viewController animated:animated];
//    RSRootTabBarController *tabbrVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbrVC removeSystemTabBarItem];
//    return array;
//}
//
//- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
//    UIViewController *VC = [super popViewControllerAnimated:animated];
//    RSRootTabBarController *tabbrVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbrVC removeSystemTabBarItem];
//    return VC;
//}
//
//- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
//    NSArray *array = [super popToRootViewControllerAnimated:animated];
//    RSRootTabBarController *tabbarVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbarVC removeSystemTabBarItem];
//    return array;
//}

- (void)popToController
{
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    [TYDebugLog debug:self];
}

@end

@implementation RSRegNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[self navigationBar] setTintColor:[[RSOptions option] viewTintColor]];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[self navigationBar] setTitleTextAttributes:navbarTitleTextAttributes];
//    UIColor *tintColor = [UIColor colorWithRed:42.0 / 255 green:184.0 / 255 blue:94.0 / 255 alpha:1.0];
//    UIColor *tintColor = [UIColor clearColor];
//    [[self navigationBar] setBarTintColor:tintColor];
}

//- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    NSArray *array = [super popToViewController:viewController animated:animated];
//    RSRootTabBarController *tabbrVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbrVC removeSystemTabBarItem];
//    return array;
//}
//
//- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
//    UIViewController *VC = [super popViewControllerAnimated:animated];
//    RSRootTabBarController *tabbrVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbrVC removeSystemTabBarItem];
//    return VC;
//}
//
//- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
//    NSArray *array = [super popToRootViewControllerAnimated:animated];
//    RSRootTabBarController *tabbarVC = (RSRootTabBarController *)self.tabBarController;
//    [tabbarVC removeSystemTabBarItem];
//    return array;
//}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[self viewControllers] count]) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)popToController
{
    [self popViewControllerAnimated:YES];
}


- (void)dealloc {
//    [TYDebugLog debug:self];
}

@end

@implementation UINavigationController (EXT)

- (NSUInteger)supportedInterfaceOrientations
{
    if([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return(NSInteger)[self.topViewController performSelector:@selector(supportedInterfaceOrientations) withObject:nil];
    }
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    if([self.visibleViewController respondsToSelector:@selector(shouldAutorotate)])
    {
        BOOL autoRotate = (BOOL)[self.visibleViewController
                                 performSelector:@selector(shouldAutorotate)
                                 withObject:nil];
        return autoRotate;
        
    }
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}


@end


@implementation RSClassHomeNavigationContorller

+ (void)load {
//    [[UIBarButtonItem appearance] setTintColor:[[RSOptions option] viewTintColor]];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: [[RSOptions option] viewTintColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[RSClassHomeNavigationContorller class], nil] setTintColor:[[RSOptions option] viewTintColor]];
//    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: [[RSOptions option] viewTintColor]};
    [[UINavigationBar appearanceWhenContainedIn:[RSClassHomeNavigationContorller class], nil] setTitleTextAttributes:navbarTitleTextAttributes];
}

- (UIColor *)color {
    return [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setBarTintColor:[self color]];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setBarTintColor:[self color]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [[RSOptions option] viewTintColor];
    [[self navigationBar] setTintColor:color];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName: color};
    [[self navigationBar] setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.navigationBar.backgroundColor = [self color];
    self.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    NSArray* subViews = [self.navigationBar subviews];
    UIView *sbView = nil;
    for (UIView* subView in subViews) {
        NSString* className = NSStringFromClass([subView class]);
        if ([className isEqualToString:@"_UINavigationBarBackground"]) {
            sbView = subView;
            break;
        }
    }
    if (sbView) {
        [sbView setAlpha:0.8];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[self viewControllers] count]) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)popToController {
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    //    [TYDebugLog debug:self];
}


@end
