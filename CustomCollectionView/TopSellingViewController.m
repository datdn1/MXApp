//
//  TopSellingViewController.m
//  CustomCollectionView
//
//  Created by Viet Khang on 3/17/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import "TopSellingViewController.h"
#import "MangXanhAPI.h"
#import "PromotionCellCO.h"
#import "Product.h"

@interface TopSellingViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    // create dynamic collection view in code
    UICollectionView *_promotionCollectionView;
    
    // refresh control
    UIRefreshControl *_topRefreshControl;
    
    // paging index
    NSInteger _pageIndex;
    
    // page offset to update new items get more from server
    NSInteger _pageOffset;
    
    // total page
    NSInteger _totalPage;
    
    // load more or refresh
    BOOL _isRefreshing;
    
    // array contains data get from server
    NSMutableArray *_topSellingItems;
}
@end

@implementation TopSellingViewController

#pragma mark - View controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set first page index for first launch
    _pageIndex = 1;
    _pageOffset = 0;
    _totalPage = 1;
    _isRefreshing = NO;
    _topSellingItems = [[NSMutableArray alloc] init];
    
    // create UI for screen
    [self createUI];
    
    // get promotion from server
    [self getTopSellingFromServer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - API methods
-(void) getTopSellingFromServer
{
    NSLog(@"Load top selling from server");
    [[MangXanhAPI shareAPIClient] getTopSellingItemsOnPage:_pageIndex completionBlock:^(NSInteger totalPage, NSArray *results, NSError *error) {
        if (error){
            NSLog(@"Fectch top selling from server failed with error: %@", error.localizedDescription);
        }
        else
        {
            _pageOffset = [_topSellingItems count];
            _totalPage = totalPage;
            [_topSellingItems addObjectsFromArray:results];
            [self updateUI];
        }
    }];
}

#pragma mark - UI methods
-(void) updateUI
{
    NSMutableArray *updateIndexPaths = [[NSMutableArray alloc] init];
    for (int i = _pageOffset; i < [_topSellingItems count]; i++)
    {
        [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    // must update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [_promotionCollectionView performBatchUpdates:^{
            if (!_isRefreshing){
                // insert new data when load more not reload data to optimize performance
                [_promotionCollectionView insertItemsAtIndexPaths:updateIndexPaths];
            }
            else {
                // refresh data
                [_topRefreshControl endRefreshing];
                [_promotionCollectionView reloadData];
            }
        } completion:nil];
    });
}

-(void) createUI
{
    // create collection view dynamic
    UICollectionViewFlowLayout *promotionLayout = [[UICollectionViewFlowLayout alloc] init];
    promotionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    promotionLayout.itemSize = [self sizeForCell];
    promotionLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    promotionLayout.minimumInteritemSpacing = 1.0;
    promotionLayout.minimumLineSpacing = 1.0;
    _promotionCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:promotionLayout];
    _promotionCollectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [_promotionCollectionView registerNib:[UINib nibWithNibName:@"PromotionCellCO" bundle:nil] forCellWithReuseIdentifier:@"PromotionCellCO"];
    
    _promotionCollectionView.delegate = self;
    _promotionCollectionView.dataSource = self;
    _promotionCollectionView.backgroundColor = [UIColor clearColor];
    
    _topRefreshControl = [[UIRefreshControl alloc] init];
    _topRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    _topRefreshControl.tintColor = [UIColor grayColor];
    [_topRefreshControl addTarget:self action:@selector(refershUI:) forControlEvents:UIControlEventValueChanged];
    [_promotionCollectionView addSubview:_topRefreshControl];
    _promotionCollectionView.alwaysBounceVertical = YES;
    
    [self.view addSubview:_promotionCollectionView];
    
    // create navigation bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
}

#pragma mark - Event handler methods
-(void) refershUI:(UIRefreshControl*)refreshControl
{
    // refresh array contains data
    [_topSellingItems removeAllObjects];
    
    // refresh paging index and paging offset
    _pageOffset = 0;
    _pageIndex = 1;
    _totalPage = 1;
    _isRefreshing = YES;
    
    // get data refresh from server
    [self getTopSellingFromServer];
}


#pragma mark - CollectionView delegate and datasource
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_topSellingItems count];
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PromotionCellCO" forIndexPath:indexPath];
    PromotionCellCO *promotionCell = (PromotionCellCO*)cell;
    Product *product = (Product*)(_topSellingItems[indexPath.row]);
    [self configureCell:promotionCell atIndexPath:indexPath withProduct:product];
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_topSellingItems count] - 1)
    {
        // check last page
        if (_pageIndex < _totalPage)
        {
            [self loadMoreItems];
        }
    }
}

#pragma mark - Ultil methods
-(void) configureCell:(id)cell atIndexPath:(NSIndexPath*)indexPath withProduct:(Product*)product
{
    PromotionCellCO *promotionCell = (PromotionCellCO*)cell;
    promotionCell.name.text = product.title;
    promotionCell.sellPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
    [self formatPriceLabel:promotionCell.originalPrice withString:[NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]]];
    
    // load image async
    NSURL *url = [NSURL URLWithString: product.url];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PromotionCellCO *updateCell = (id)[_promotionCollectionView cellForItemAtIndexPath:indexPath];
                    if (updateCell){
                        updateCell.image.image = image;
                    }
                });
            }
        }
    }];
    [task resume];
}

-(NSString*) formatPriceFromValue:(NSNumber*)priceValue
{
    NSInteger valueInt = [priceValue integerValue];
    NSString *valueString = [NSString stringWithFormat:@"%ld", (long)valueInt];
    
    NSMutableString *valueStringFormat = [NSMutableString stringWithString:valueString];
    NSInteger lengthString = [valueString length];
    while (lengthString > 3)
    {
        [valueStringFormat insertString:@"." atIndex:lengthString - 3];
        lengthString = lengthString - 3;
    }
    return valueStringFormat;
}

-(void) formatPriceLabel:(UILabel*)priceLabel withString:(NSString*)valueString
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:valueString];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@1.5
                            range:NSMakeRange(0, [attributeString length])];
    [priceLabel setAttributedText:attributeString];
}

-(void) loadMoreItems
{
    _pageIndex++;
    _isRefreshing = NO;
    [self getTopSellingFromServer];
}

-(CGSize) sizeForCell
{
    int width = (int)[[UIScreen mainScreen] bounds].size.width;
    // check screen size
    if (width == 320)
    {
        // iphone 4/5
        return CGSizeMake(159.5, 232.5);
    }
    else if (width == 375) {
        // iphone 6
        return CGSizeMake(187.0, 272.5);
    }
    else {
        // iphone 6+
        return CGSizeMake(206.5, 301.0);
    }
}


@end
