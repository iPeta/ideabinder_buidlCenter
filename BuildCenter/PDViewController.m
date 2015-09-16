//
//  ViewController.m
//  BuildCenter
//
//  Created by Peng Tao on 15/9/10.
//  Copyright (c) 2015年 Peng Tao. All rights reserved.
//

#import "PDViewController.h"

#import "PDLeftTableViewProtocol.h"
#import "PDRightTableViewProtocol.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "Product.h"

#import "UIImageView+WebCache.h"

#import "PDProductViewModel.h"

#import "MJRefresh.h"

@interface PDViewController ()
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (weak, nonatomic) IBOutlet UITableView *rightTableView;
@property (weak, nonatomic) IBOutlet UIImageView *headerIconImageView;
@property (weak, nonatomic) IBOutlet UIButton *headerDownLoadButton;
@property (weak, nonatomic) IBOutlet UILabel *headerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerVersionLabel;


@property (nonatomic, strong) PDLeftTableViewProtocol  *leftProtocol;
@property (nonatomic, strong) PDRightTableViewProtocol *rightProtocol;

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *historyBuilds;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) PDProductViewModel *viewModel;

@property (nonatomic, copy) NSString *downloadAppKey;


@end

@implementation PDViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.leftTableView.delegate    = self.leftProtocol;
  self.leftTableView.dataSource  = self.leftProtocol;
  self.rightTableView.delegate   = self.rightProtocol;
  self.rightTableView.dataSource = self.rightProtocol;
  
  self.leftTableView.tableFooterView = [UIView new];
  
  self.leftTableView.layer.borderColor = [UIColor colorWithWhite:0.800 alpha:1.000].CGColor;
  self.leftTableView.layer.borderWidth = 1;
  
  self.rightTableView.layer.borderColor = [UIColor colorWithWhite:0.800 alpha:1.000].CGColor;
  self.rightTableView.layer.borderWidth = 1;
  
  UIView *headerView = [[UIView alloc] init];
  headerView.frame = CGRectMake(0, 0, 300, 50);
  
  UILabel *headerLabel = [[UILabel alloc] init];
  headerLabel.backgroundColor = [UIColor colorWithWhite:0.902 alpha:1.000];
  headerLabel.frame = CGRectMake(10, 10, 280, 30);
  headerLabel.layer.cornerRadius = 5;
  headerLabel.layer.masksToBounds = YES;
  headerLabel.text = @"产品列表";
  headerLabel.textAlignment = NSTextAlignmentCenter;
  [headerView addSubview:headerLabel];
  self.leftTableView.tableHeaderView = headerView;
  
  [self loadData];
  
  [self.headerDownLoadButton addTarget:self action:@selector(downLoadClick:) forControlEvents:UIControlEventTouchUpInside];
  
  self.leftTableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.leftTableView.header beginRefreshing];
}

- (void)loadData
{
  [self.viewModel reloadAllProducts:^{
    [self.leftTableView reloadData];
    [self.leftTableView.header endRefreshing];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.leftTableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
    
    [self leftViewClickAtIndex:0];
  }];
}


- (void)refreshHeaderView
{
  [self.headerIconImageView sd_setImageWithURL:[self.viewModel headerIconUrl]
                        placeholderImage:[UIImage imageNamed:@"default-icon"]];
  self.headerNameLabel.text = [self.viewModel headerProductName];
  self.headerVersionLabel.text = [self.viewModel headerVersion];
  
  self.downloadAppKey = [self.viewModel downloadAppkey];
}

- (void)downLoadClick:(UIButton *)sender
{
  NSString *path = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/%@",self.downloadAppKey];
  NSURL* nsUrl = [NSURL URLWithString:path];
  [[UIApplication sharedApplication] openURL:nsUrl];  
}

- (void)leftViewClickAtIndex:(NSInteger)index
{
  [self.viewModel reloadHistoryBuildsWithIndex:index completion:^{
    [self.rightTableView reloadData];
    [self refreshHeaderView];
  }];
}


#pragma mark -
#pragma mark - Properties

- (PDLeftTableViewProtocol *)leftProtocol
{
  if (!_leftProtocol) {
    _leftProtocol = [[PDLeftTableViewProtocol alloc] init];
    _leftProtocol.controller = self;
    _leftProtocol.viewModel = self.viewModel;
  }
  return _leftProtocol;
}

- (PDRightTableViewProtocol *)rightProtocol
{
  if (!_rightProtocol) {
    _rightProtocol = [[PDRightTableViewProtocol alloc] init];
    _rightProtocol.viewModel = self.viewModel;

  }
  return _rightProtocol;
}


- (PDProductViewModel *)viewModel
{
  if (!_viewModel) {
    _viewModel = [[PDProductViewModel alloc] init];
  }
  return _viewModel;
}
@end
