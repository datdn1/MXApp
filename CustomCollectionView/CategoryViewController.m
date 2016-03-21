////
////  CategoryViewController.m
////  CustomCollectionView
////
////  Created by Viet Khang on 3/11/16.
////  Copyright © 2016 Viet Khang. All rights reserved.
////
//
//#import "CategoryViewController.h"
//#import "UIBarButtonItem+Badge.h"
//#import "CategoryCell.h"
//
//@interface CategoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
//{
//    UIBarButtonItem *_notifyItem;
//}
//
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//
//@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
//@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;
//@end
//
//@implementation CategoryViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
//    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchHandler:)];
//    _notifyItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notify"] style:UIBarButtonItemStylePlain target:self action:@selector(notifyHandler:)];
//    NSArray *actionButtonItems = @[_notifyItem, searchItem];
//    self.navigationItem.rightBarButtonItems = actionButtonItems;
//    
////    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    // Set the estimatedRowHeight to a non-0 value to enable auto layout.
////    self.tableView.estimatedRowHeight = 10;
//}
//
//-(void) searchHandler:(UIBarButtonItem*) searchButton
//{
//    
//}
//
//-(void) notifyHandler:(UIBarButtonItem*) notifyButton
//{
//    static int badgeValue = 0;
//    badgeValue++;
//    NSLog(@"Click notify bar button");
//    _notifyItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//#pragma mark - CollectionView datasource and delegate
////- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
////{
////    if (collectionView == self.categoriesCollectionView)
////    {
////        return 20;
////    }
////    else
////    {
////        return 100;
////    }
////}
//
////- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
////{
////    UICollectionViewCell *cell = nil;
////    if (collectionView == self.categoriesCollectionView)
////    {
////        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
////    }
////    else
////    {
////        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavoriteCell" forIndexPath:indexPath];
////    }
////    return cell;
////}
//
//-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return 20;
//}
//
//-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor redColor];
//    return cell;
//}
//
//#pragma mark - TableView datasource and delegate
//
//-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//
//-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//    {
//        return @"Khuyến Mại";
//    }
//    else
//    {
//        return @"Sản Phẩm Nổi Bật";
//    }
//}
//
//-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    CategoryCell *cell = nil;
//    if(indexPath.section == 0)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"HorizontalCell"];
//    }
//    else
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"VerticalCell"];
//    }
//    [cell setCollectionViewDataSourceDelegate:self forRow:indexPath.row];
//    return cell;
//}
//-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 1)
//    {
//        return [[UIScreen mainScreen] bounds].size.height - 113.0;
//    }
//    return 100;
//    
//}
//
//#pragma mark - ScrollView delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSIndexPath *favoriteIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:favoriteIndexPath];
//    CGRect rect = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
//    NSLog(@"Rect = (%f, %f)", rect.origin.x, rect.origin.y);
//    if (rect.origin.y <  64.0)
//    {
//        UITableViewCell *favoriteCell = [self.tableView cellForRowAtIndexPath:favoriteIndexPath];
//        UICollectionView *favoriteCollectionView = [favoriteCell viewWithTag:1];
//        [self.tableView setScrollEnabled:NO];
//        [favoriteCollectionView setScrollEnabled:YES];
//        NSLog(@"Content size = (%f, %f)", favoriteCollectionView.contentSize.width, favoriteCollectionView.contentSize.height);
//    }
//    else
//    {
//        UITableViewCell *favoriteCell = [self.tableView cellForRowAtIndexPath:favoriteIndexPath];
//        UICollectionView *favoriteCollectionView = [favoriteCell viewWithTag:1];
//        [self.tableView setScrollEnabled:YES];
//        [favoriteCollectionView setScrollEnabled:NO];
//    }
//    
//}
//
//
//
//
//@end
