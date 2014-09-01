//
//  Store.m
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import "Store.h"

@interface Store ()
@property (nonatomic,strong,readwrite) NSManagedObjectContext* mainManagedObjectContext;
#ifdef STYLE_NEW
@property (nonatomic,strong,readwrite) NSManagedObjectContext* saveManagedObjectContext;
#endif
@property (nonatomic,strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation Store

- (id)init
{
    self = [super init];
    if (self) {
        [self setupSaveNotification];
    }

    return self;
}

- (void)setupSaveNotification
{
#ifndef STYLE_NEW
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* note) {
                                                      NSManagedObjectContext *moc = self.mainManagedObjectContext;
                                                      if (note.object != moc) {
                                                          [moc performBlock:^(){
                                                              [moc mergeChangesFromContextDidSaveNotification:note];
                                                          }];
                                                      }
                                                  }];
#else
    __weak Store *weakStore = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* notification) {
                                                      NSManagedObjectContext *savedContext = [notification object];
                                                      
                                                      // ignore change notifications for save context or maincontext
                                                      if (savedContext == self.saveManagedObjectContext ||  savedContext == self.mainManagedObjectContext) {
                                                          return;
                                                      }
                                                      [self.mainManagedObjectContext performBlock:^{
                                                          [weakStore saveContext];
                                                      }];
                                                      
                                                      
                                                  }];
#endif
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }else
            {
                [_saveManagedObjectContext performBlock:^{
                    __block NSError *inner_error = nil;
                    if (![_saveManagedObjectContext save:&inner_error])
                    {
                        NSLog(@"Unresolved inner_error %@, %@", inner_error, [inner_error userInfo]);
                    }
                }];
            }
        }
    }
}

- (void)resetData
{
    NSEntityDescription *description = [NSEntityDescription entityForName:kDataBaseName inManagedObjectContext:self.saveManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:description];
    NSError *error = nil;
    NSArray *datas = [self.saveManagedObjectContext executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [self.saveManagedObjectContext deleteObject:obj];
        }
        if (![self.saveManagedObjectContext save:&error])
        {
            NSLog(@"error:%@",error);
        }  
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }

    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
#ifndef STYLE_NEW
    _mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
#else
    [_mainManagedObjectContext setParentContext:self.saveManagedObjectContext];
#endif
    return _mainManagedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDataBaseName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",kDataBaseName]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma -mark ==== New implemetion ====
#pragma mark -

#ifdef STYLE_NEW
- (NSManagedObjectContext *)saveManagedObjectContext
{
    if (nil != _saveManagedObjectContext) return _saveManagedObjectContext;
    _saveManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _saveManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    return _saveManagedObjectContext;
}
#endif


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext*)newPrivateContext
{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
#ifdef STYLE_NEW
    [context setParentContext:self.mainManagedObjectContext];
#else
    context.persistentStoreCoordinator = [self persistentStoreCoordinator];
#endif
    return context;
}
@end
