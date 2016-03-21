//
//  MainViewController.m
//  CustomCollectionView
//
//  Created by Viet Khang on 3/15/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import "MainViewController.h"
#import "CategoryCell.h"
#import "PopularCell.h"
#import "PromotionCell.h"
#import "SellingCell.h"
#import "Product.h"

#import "MangXanhAPI.h"

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *_categoryTitle;
    NSMutableArray *_categoryImage;
    
    NSMutableArray *_khuyenMaiItems;
    NSMutableArray *_banChayItems;
    NSMutableArray *_noiBatItems;
    
    NSInteger _popularPageIndex;
    NSInteger _popularPageOffset;
    NSInteger _totalPage;
}

@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;

@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *promotionCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *sellingCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *popularCollectionView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// custom font
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *promotionHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellingHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *popularHeaderLabel;

@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup UI when launch screen
    [self setupUI];
    
    // send request to server
    [self sendRequestToServer];
}

-(void) setupUI
{
    // setup for category collection part
    _categoryTitle = [[NSMutableArray alloc] initWithArray:@[@"Thời trang", @"Giầy dép", @"Phụ kiện thời trang", @"Làm đẹp", @"Mẹ và bé", @"Đồ dùng gia đình", @"Sách-Văn phòng", @"Công nghệ"]];
    _categoryImage = [[NSMutableArray alloc] initWithArray:@[@"thoitrang",@"giaydep",@"phukien",@"lamdep",@"mebe",@"giadinh",@"sach",@"congnghe"]];
    
    // setup model
    _khuyenMaiItems = [[NSMutableArray alloc] init];
    _banChayItems = [[NSMutableArray alloc] init];
    _noiBatItems = [[NSMutableArray alloc] init];
    
    // setup initialize value of popular products
    _popularPageIndex = 1;
    _popularPageOffset = 0;
    _totalPage = 1;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
}


#pragma mark - CollectionView datasource and delegate
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.categoriesCollectionView)
    {
        return [_categoryImage count];
    }
    else if (collectionView == self.promotionCollectionView)
    {
        return [_khuyenMaiItems count];
    }
    else if (collectionView == self.sellingCollectionView)
    {
        return [_banChayItems count];
    }
    else
    {
        return [_noiBatItems count];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.categoriesCollectionView)
    {
        int width = (int)[[UIScreen mainScreen] bounds].size.width;
        if (width == 414) {
            return CGSizeMake(103.5, 90.0);
        }
        return CGSizeMake(80.0, 90.0);
    }
    else if (collectionView == self.promotionCollectionView
             || collectionView == self.sellingCollectionView)
    {
        return CGSizeMake(120.0, 180.0);
    }
    else
    {
        int width = (int)[[UIScreen mainScreen] bounds].size.width;
        // check screen size
        if (width == 320)
        {
            // iphone 4/5
            return CGSizeMake(152.5, 215.8);
        }
        else if (width == 375) {
            // iphone 6
            return CGSizeMake(180.0, 253.5);
        }
        else {
            // iphone 6+
            return CGSizeMake(199.5, 281.0);
        }
        
    }
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.categoriesCollectionView)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
        CategoryCell *categoryCell = (CategoryCell*)cell;
        categoryCell.image.image = [UIImage imageNamed:_categoryImage[indexPath.row]];
        categoryCell.title.text = _categoryTitle[indexPath.row];
    }
    else if (collectionView == self.promotionCollectionView)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PromotionCell" forIndexPath:indexPath];
        PromotionCell *promotionCell = (PromotionCell*)cell;
        Product *product = _khuyenMaiItems[indexPath.row];
        [self configureCell:promotionCell atIndexPath:indexPath withProduct:product];
        [[MangXanhAPI shareAPIClient] getImageFromURLString:product.url completionBlock:^(UIImage *image, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if (image) {
                        [self updateImagePromotionCellAtIndexPath:indexPath withImage:image];
                    }
                }
            });
        }];
    }
    else if (collectionView == self.sellingCollectionView)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SellingCell" forIndexPath:indexPath];
        SellingCell *sellingCell = (SellingCell*)cell;
        Product *product = _banChayItems[indexPath.row];
        [self configureCell:sellingCell atIndexPath:indexPath withProduct:product];
        [[MangXanhAPI shareAPIClient] getImageFromURLString:product.url completionBlock:^(UIImage *image, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if (image) {
                        [self updateImageSellingCellAtIndexPath:indexPath withImage:image];
                    }
                }
            });
        }];
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PopularCell" forIndexPath:indexPath];
        PopularCell *popularCell = (PopularCell*)cell;
        Product *product = _noiBatItems[indexPath.row];
        [self configureCell:popularCell atIndexPath:indexPath withProduct:_noiBatItems[indexPath.row]];
        [[MangXanhAPI shareAPIClient] getImageFromURLString:product.url completionBlock:^(UIImage *image, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if (image) {
                        [self updateImagePopularCellAtIndexPath:indexPath withImage:image];
                    }
                }
            });
        }];
    }
    return cell;
}

-(void) updateImagePromotionCellAtIndexPath:(NSIndexPath*)indexPath withImage:(UIImage*)image
{
    PromotionCell *updateCell = (id)[self.promotionCollectionView cellForItemAtIndexPath:indexPath];
    if (updateCell){
        updateCell.image.image = image;
    }
}

-(void) updateImageSellingCellAtIndexPath:(NSIndexPath*)indexPath withImage:(UIImage*)image
{
    SellingCell *updateCell = (id)[self.sellingCollectionView cellForItemAtIndexPath:indexPath];
    if (updateCell){
        updateCell.image.image = image;
    }
}

-(void) updateImagePopularCellAtIndexPath:(NSIndexPath*)indexPath withImage:(UIImage*)image
{
    PopularCell *updateCell = (id)[self.popularCollectionView cellForItemAtIndexPath:indexPath];
    if (updateCell){
        updateCell.image.image = image;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // IOS 7 throw exception
    if (collectionView == self.categoriesCollectionView)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Category Info" message:[NSString stringWithFormat:@"You is selected %@", _categoryTitle[indexPath.row]] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void) collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.popularCollectionView) {
        if (indexPath.row == [_noiBatItems count] - 1)
        {
            // check last page
            if (_popularPageIndex < _totalPage)
            {
                [self loadMoreItems];
            }
        }
    }
}



#pragma mark - TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

-(void) sendRequestToServer
{
    [[MangXanhAPI shareAPIClient] getPromotionItemsOnPage:1 completionBlock:^(NSInteger totalPage, NSArray *results, NSError *error) {
        if(error){
            NSLog(@"Fetch spkm from server failed with error: %@", error.localizedDescription);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _khuyenMaiItems = [[NSMutableArray alloc] initWithArray:results];
                [self.promotionCollectionView reloadData];
            });
        }
    }];
    [[MangXanhAPI shareAPIClient] getTopSellingItemsOnPage:1 completionBlock:^(NSInteger totalPage, NSArray *results, NSError *error) {
        if(error){
            NSLog(@"Fetch spbc from server failed with error: %@", error.localizedDescription);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _banChayItems = [[NSMutableArray alloc] initWithArray:results];
                [self.sellingCollectionView reloadData];
            });
        }
    }];
    
    [self getPopularFromServer];
}

-(void) configureCell:(id)cell atIndexPath:(NSIndexPath*)indexPath withProduct:(Product*)product
{
    if ([cell isKindOfClass:[PromotionCell class]]) {
        PromotionCell *promotionCell = (PromotionCell*)cell;
        promotionCell.name.text = product.title;
        [self formatPriceLabel:promotionCell.originalPrice withString:[NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]]];
        promotionCell.sellPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
        if ([product.dcPercent isKindOfClass:[NSNumber class]]) {
            promotionCell.percent.hidden = YES;
            promotionCell.percentImage.hidden = YES;
        }
        else {
            promotionCell.percent.hidden = NO;
            promotionCell.percentImage.hidden = NO;
            promotionCell.percent.text = [product.dcPercent stringByAppendingString:@"%"];
        }
    }
    else if ([cell isKindOfClass:[SellingCell class]]) {
        SellingCell *sellingCell = (SellingCell*)cell;
        sellingCell.name.text = product.title;
        [self formatPriceLabel:sellingCell.originalPriceLabel withString:[NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]]];
        sellingCell.sellingPriceLabel.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
        if ([product.dcPercent isKindOfClass:[NSNumber class]]) {
            sellingCell.percent.hidden = YES;
            sellingCell.percentImage.hidden = YES;
        }
        else {
            sellingCell.percent.hidden = NO;
            sellingCell.percentImage.hidden = NO;
            sellingCell.percent.text = [product.dcPercent stringByAppendingString:@"%"];
        }
    }
    else {
        PopularCell *popularCell = (PopularCell*)cell;
        popularCell.name.text = product.title;
        [self formatPriceLabel:popularCell.originalPrice withString:[NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.price]]];
        popularCell.sellPrice.text = [NSString stringWithFormat:@"%@đ", [self formatPriceFromValue:product.finalPrice]];
        popularCell.commentLabel.text = product.totalComment;
        popularCell.likeLabel.text = product.totalLike;
        if ([product.dcPercent isKindOfClass:[NSNumber class]]) {
            popularCell.percent.hidden = YES;
            popularCell.percentImage.hidden = YES;
        }
        else {
            popularCell.percent.hidden = NO;
            popularCell.percentImage.hidden = NO;
            popularCell.percent.text = [product.dcPercent stringByAppendingString:@"%"];
        }
    }
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
    _popularPageIndex++;
    [self getPopularFromServer];
}

-(void) getPopularFromServer
{
    [[MangXanhAPI shareAPIClient] getPopularItemsOnPage:_popularPageIndex completionBlock:^(NSInteger totalPage, NSArray *results, NSError *error) {
        if(error){
            NSLog(@"Fetch spnb from server failed with error: %@", error.localizedDescription);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _totalPage = totalPage;
                _popularPageOffset = [_noiBatItems count];
                [_noiBatItems addObjectsFromArray:results];
                if (_popularPageOffset == 0) {
                    [self.popularCollectionView reloadData];
                }
                else {
                    NSMutableArray *updateIndexPaths = [[NSMutableArray alloc] init];
                    for (int i = _popularPageOffset; i < [_noiBatItems count]; i++)
                    {
                        [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [self.popularCollectionView insertItemsAtIndexPaths:updateIndexPaths];
                }
            });
        }
    }];
}

#pragma mark - Observer handler
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    //Whatever you do here when the reloadData finished
    if ([keyPath isEqualToString:@"contentSize"]) {
        float newHeight = self.popularCollectionView.collectionViewLayout.collectionViewContentSize.height;
        NSLog(@"New height = %f", newHeight);
        CGRect frame = self.popularCollectionView.frame;
        NSLog(@"Frame of collectionview = (%f, %f)", frame.origin.x, frame.origin.y);
        self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, newHeight + frame.origin.y);
        frame.size.height = newHeight;
        self.popularCollectionView.frame = frame;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // add observer on popular collectionview
    [self.popularCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"View disappear");
    [self.popularCollectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
