//
//  AppDelegate.h
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Store;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) Store    *store;
@end
