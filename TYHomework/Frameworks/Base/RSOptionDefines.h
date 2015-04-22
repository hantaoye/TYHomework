//
//  RSOptionDefines.h
//  RSBase
//
//  Created by closure on 10/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

#ifndef OPTIONS
#define OPTIONS(name, type, pp, default, description) 
#endif

#ifndef STR_OPTIONS
#define STR_OPTIONS(name, type, pp, default, description) OPTIONS(name, type, pp, default, description) 
#endif

#ifndef ERROR_OPTIONS
#define ERROR_OPTIONS(name, type, pp, default, description) STR_OPTIONS(name, type, pp, default, description)
#endif

STR_OPTIONS(middlewareTag, NSString *, strong, @"com.RS-inc.middleware", "middleware tag")
STR_OPTIONS(middlewareStatisticsTag, NSString *, strong, @"com.RS-inc.middleware.statistics", "middleware statistics tag")
STR_OPTIONS(sharedStorageTag, NSString *, strong, @"com.RS-inc.stoarge.shared", "RSSharedStorage")
STR_OPTIONS(notificationCenterTag, NSString *, strong, @"com.RS-inc.notify.notificationCenter", "")
STR_OPTIONS(sharedStorageCodeName, NSString *, strong, @"com.RS-inc.stoarge.shared.plist", "RSSharedStorage coder file name")

OPTIONS(concurrentOperationCount, NSUInteger, assign, 15, "the max operation count of concurrent queue")
OPTIONS(operationQueueIsSuspended, BOOL, assign, NO, "operation queue is suspended in default")

//([UIColor colorWithRed:1 green:167 / 255.0 blue:51 / 255.0 alpha:1.0])
OPTIONS(viewTintColor, UIColor*, strong, ([UIColor colorWithRed:1 green:167 / 255.0 blue:51 / 255.0 alpha:1.0]), "")

OPTIONS(blueprintTableViewBackgroundColor, UIColor*, strong, ([UIColor colorWithRed:1 green:167 / 255.0 blue:51 / 255.0 alpha:1.0]), "")
OPTIONS(originTableViewBackgroundColor, UIColor *, strong, ([UIColor colorWithRed:252.0 / 255.0f green:150.0 / 255.0f blue:39.0 / 255.0f alpha:1.0]), "")
OPTIONS(grayTableViewBackgroundColor, UIColor *, strong, ([UIColor colorWithRed:240.0 / 255.0f green:240.0 / 255.0f blue:240.0 / 255.0f alpha:1.0]), "")


STR_OPTIONS(planCardTableViewCellProgressLabelTextFormat, NSString*, strong, @"Health plans progress: %ld%%", "plan progress format key")
STR_OPTIONS(planCardTableViewCellTodayPlanLabelContent, NSString*, strong, @"today plan", "today plan")
STR_OPTIONS(planCardTableViewCellTodayPlanImageName, NSString*, strong, @"PlanCardTodayPlanImage", "")
OPTIONS(planCardTableViewCellTodayPlanImage, UIImage*, strong, ([UIImage imageNamed:@""]), "")

STR_OPTIONS(blueprintSegmentControlBackgroundImageName, NSString*, strong, @"blueprintSegmentControlBackgroundImage", "blue print segment control slider backgounrd image")

STR_OPTIONS(blueprintSegmentControlImageSBackgroundName, NSString*, strong, @"blueprintSegmentControlImageSBackground", "blue print segment control selected background")
STR_OPTIONS(blueprintSegmentControlImageUBackgroundName, NSString*, strong, @"blueprintSegmentControlImageUBackground", "blue print segment control unselected background")



ERROR_OPTIONS(nameTextFieldEmptyError, NSString *, strong, @"昵称不能为空", "in email register view controller, name text filed is nil")
ERROR_OPTIONS(nameTextFieldConflictError, NSString *, strong, @"昵称已被使用", "in email register view controller, name is already been used")
ERROR_OPTIONS(nameTextFieldShouldOver4Error, NSString *, strong, @"昵称不能短于4个字符", "")
ERROR_OPTIONS(nameTextFieldShouldLess14Error, NSString *, strong, @"昵称不能长于14个字符", "")

ERROR_OPTIONS(emailTextFieldEmptyError, NSString *, strong, @"邮箱地址为空", "in email register view controller, password text filed is nil")
ERROR_OPTIONS(emailAddressFormatInvalid, NSString *, strong, @"邮箱格式不正确", "email address format is invalid")
ERROR_OPTIONS(emailTextFieldConflictError, NSString *, strong, @"邮箱已经被使用", "in email register view controller, mail address is already been used")

ERROR_OPTIONS(passwordTextFieldEmptyError, NSString *, strong, @"密码不能为空", "in email register view controller, passsword text filed is nil")
ERROR_OPTIONS(verifyPasswordTextFieldEmptyError, NSString *, strong, @"验证密码不能为空", "in email register view controller, verify passsword text filed is nil")

ERROR_OPTIONS(passwordLengthShouldOver6Error, NSString *, strong, @"密码不能短于6位", "password length should be over 6 characters")
ERROR_OPTIONS(passwordLengthShouldLess20Error, NSString *, strong, @"密码不能长于20位", "password length should be over 20 characters")

ERROR_OPTIONS(verifyPasswordNotMatchError, NSString *, strong, @"两个密码不匹配", "in email register view controller, verify passsword text filed is nil")


ERROR_OPTIONS(locationAccessDisabledError, NSString *, strong, @"无法获得地理位置", "")

STR_OPTIONS(locationAccessDisabledNotifyContent, NSString *, strong, @"为了获得地理位置信息, 保证附近的人正常使用, 请打开这个应用程序的设置，并设置位置访问'当使用'", "")
STR_OPTIONS(openSettingsContent, NSString *, strong, @"打开设置", "")


STR_OPTIONS(cancelString, NSString*, strong, @"取消", "")
STR_OPTIONS(okString, NSString*, strong, @"好", "")
#undef OPTIONS
#undef STR_OPTIONS
