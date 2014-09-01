//
//  Stop.h
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
