//
//  PromotionViewController.m
//  CustomCollectionView
//
//  Created by Viet Khang on 3/16/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import "PromotionViewController.h"
#import "PromotionCellTB.h"
#import "PromotionCellCO.h"
#import "MangXanhAPI.h"
#import "Product.h"

@interface PromotionViewController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    UITableView *_promotionTableView;
    UICollectionView *_promotionCollectionView;
    
    NSInteger _pageIndex;
    NSMutableArray *_promotionItems;
}

@end

@implementation PromotionViewController

// create enum check display type of screen
typedef enum DisplayType
{
    TableDisplayType,
    GridDisplayType,
} DisplayType;

#pragma mark - ViewController lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set first page index for first launch
    _pageIndex = 1;
    _promotionItems = [[NSMutableArray alloc] init];
    
    // create UI for screen
    [self createUI];
    
    // get promotion from server
    [self getPromotionFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI methods
-(void) createUI
{
    // create table view dynamic
    _promotionTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    //    _promotionTableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 49.0, 0.0);
    [_promotionTableView registerNib:[UINib nibWithNibName:@"PromotionCellTB" bundle:nil] forCellReuseIdentifier:@"PromotionCellTB"];
    _promotionTableView.delegate = self;
    _promotionTableView.dataSource = self;
    
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
    
    // add tableview/collectionview to view
    // can save current status of display when user exit app
    [self.view addSubview:_promotionCollectionView];
    
    // create navigation bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
}

-(void) updateUI
{
    if ([self getDisplayType] == TableDisplayType)
    {
        [_promotionTableView reloadData];
    }
    else
    {
        [_promotionCollectionView reloadData];
    }
}

-(void) configureCell:(id)cell atIndexPath:(NSIndexPath*)indexPath withProduct:(Product*)product
{
    if ([cell isKindOfClass:[PromotionCellTB class]])
    {
        PromotionCellTB *promotionCell = (PromotionCellTB*)cell;
        promotionCell.name.text = product.title;
        promotionCell.sellPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
//        promotionCell.originalPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]];
        [self formatPriceLabel:promotionCell.originalPrice withString:[NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]]];
        promotionCell.comment.text = product.totalComment;
        promotionCell.numberOfBuy.text = product.totalLike;
        
        // load image async
        NSURL *url = [NSURL URLWithString: product.url];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        PromotionCellTB *updateCell = (id)[_promotionTableView cellForRowAtIndexPath:indexPath];
                        if (updateCell)
                            updateCell.image.image = image;
                    });
                }
            }
        }];
        [task resume];
    }
    else if ([cell isKindOfClass:[PromotionCellCO class]])
    {
        PromotionCellCO *promotionCell = (PromotionCellCO*)cell;
        promotionCell.name.text = product.title;
        promotionCell.sellPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
//        promotionCell.originalPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]];
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
}

#pragma mark - Server methods
-(void) getPromotionFromServer
{
    [[MangXanhAPI shareAPIClient] getPromotionItemsOnPage:_pageIndex completionBlock:^(NSInteger totalPage, NSArray *results, NSError *error) {
        if (error)
        {
            NSLog(@"Fetch spkm from server failed with error: %@", error.localizedDescription);
            return;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // append data when has new data
                [_promotionItems addObjectsFromArray:results];
                
                // update UI
                [self updateUI];
            });
        }
    }];
}

#pragma mark - Ultil methods
-(DisplayType) getDisplayType
{
    if (_promotionTableView.superview == self.view)
    {
        return TableDisplayType;
    }
    else
    {
        return GridDisplayType;
    }
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

-(NSString*) formatPriceFromValue:(NSNumber*)priceValue
{
    NSInteger valueInt = [priceValue integerValue];
    NSString *valueString = [NSString stringWithFormat:@"%d", valueInt];
    
    NSMutableString *valueStringFormat = [NSMutableString stringWithString:valueString];
    int lengthString = [valueString length];
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

#pragma mark - Handler
-(void) changeDisplayUI:(UIBarButtonItem*)item
{
    UIView *fromView, *toView;
    UIViewAnimationOptions options = kNilOptions;
    NSString *nameIconSwitch = nil;
    
    if ([self getDisplayType] == TableDisplayType)
    {
        // change display from tableview to collectionview
        fromView = _promotionTableView;
        toView = _promotionCollectionView;
        options = UIViewAnimationOptionTransitionFlipFromLeft;
        nameIconSwitch = @"table";
    }
    else
    {
        // change display from collectionview to tableview
        fromView = _promotionCollectionView;
        toView = _promotionTableView;
        options = UIViewAnimationOptionTransitionFlipFromRight;
        nameIconSwitch = @"collection";
    }
    toView.frame = self.view.bounds;
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:1.0
                       options:options
                    completion:nil];
    item.image = [UIImage imageNamed:nameIconSwitch];
}

#pragma mark - TableView delegate and datasource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_promotionItems count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126.0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"PromotionCellTB"];
    PromotionCellTB *promotionCell = (PromotionCellTB*)cell;
    Product *product = (Product*)(_promotionItems[indexPath.row]);
    [self configureCell:promotionCell atIndexPath:indexPath withProduct:product];
    return promotionCell;
}



#pragma mark - CollectionView delegate and datasource
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_promotionItems count];
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PromotionCellCO" forIndexPath:indexPath];
    PromotionCellCO *promotionCell = (PromotionCellCO*)cell;
    Product *product = (Product*)(_promotionItems[indexPath.row]);
    [self configureCell:promotionCell atIndexPath:indexPath withProduct:product];
    return cell;
}

@end
