//
//  ViewController.m
//  Mutli_Thread_CoreData_Demo
//
//  Created by ZhaoJuan on 14-8-31.
//  Copyright (c) 2014年 Acorld. All rights reserved.
//

#import "ViewController.h"
#import "Store.h"
#import "ImportOperation.h"
#import "FetchedResultsTableDataSource.h"
#import "Stop.h"

@interface ViewController ()
@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic, strong) FetchedResultsTableDataSource* dataSource;
@property (nonatomic, strong) UIProgressView *progressIndicator;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.store = [App_Delegate store];
    self.operationQueue = [[NSOperationQueue alloc] init];
    [self configUI];
	[self setupData];
}

#pragma mark - Config
#pragma mark -

- (void)configUI
{
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(0, 0, 44, 34);
    [startBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startImport) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:startBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 64, 34);
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelImport) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanBtn.frame = CGRectMake(0, 0, 44, 34);
    [cleanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cleanBtn setTitle:@"Clean" forState:UIControlStateNormal];
    [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cleanBtn addTarget:self action:@selector(cleanData) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:cancelBtn],[[UIBarButtonItem alloc] initWithCustomView:cleanBtn]];
    
    self.progressIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
    self.navigationItem.titleView = self.progressIndicator;
}

- (void)setupData
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kDataBaseName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
#ifdef STYLE_NEW
    NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.store.saveManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
#else
    NSFetchedResultsController* fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.store.mainManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
#endif
    self.dataSource = [[FetchedResultsTableDataSource alloc] initWithTableView:self.tableView fetchedResultsController:fetchedResultsController];
    self.dataSource.configureCellBlock = ^(UITableViewCell*  cell, Stop* item)
    {
        cell.textLabel.text = item.name;
    };
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Operation
#pragma mark -
- (void)startImport
{
    self.progressIndicator.progress = 0;
    NSString* fileName = [[NSBundle mainBundle] pathForResource:@"stops" ofType:@"txt"];
    ImportOperation* operation = [[ImportOperation alloc] initWithStore:self.store fileName:fileName];
    operation.progressCallback = ^(float progress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
         {
             self.progressIndicator.progress = progress;
         }];
    };
    [self.operationQueue addOperation:operation];
}

- (void)cancelImport
{
    [self.operationQueue cancelAllOperations];
}

- (void)cleanData
{
    if (self.progressIndicator.progress == 1.0 || self.progressIndicator.progress == 0.0)//means import operation stop
    {
        [self.store resetData];
        self.progressIndicator.progress = 0.0f;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
