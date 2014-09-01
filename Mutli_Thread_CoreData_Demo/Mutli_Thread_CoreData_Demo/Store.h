//
//  Store.h
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic,strong,readonly) NSManagedObjectContext* saveManagedObjectContext;
- (void)saveContext;
- (NSManagedObjectContext*)newPrivateContext;

@end
