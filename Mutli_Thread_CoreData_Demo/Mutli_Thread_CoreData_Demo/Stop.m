//
//  Stop.m
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import "Stop.h"


@implementation Stop

@dynamic identifier;
@dynamic name;
@dynamic latitude;
@dynamic longitude;

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %p, %@ - %@ (%f, %f)>", [self class], self, self.identifier, self.name, self.latitude.doubleValue, self.longitude.doubleValue];
}

@end
