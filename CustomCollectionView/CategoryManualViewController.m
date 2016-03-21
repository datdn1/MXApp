//
//  CategoryManualViewController.m
//  CustomCollectionView
//
//  Created by Viet Khang on 3/15/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import "CategoryManualViewController.h"
#import "OLEContainerScrollView.h"
#import "UIBarButtonItem+Badge.h"

@interface CategoryManualViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIImageView *_bannerImageView;
    UICollectionView *_categoryCollectionView;
    UICollectionView *_promotionCollectionView;
    UICollectionView *_sellingCollectionView;
    UICollectionView *_popularCollectionView;
    
    UIBarButtonItem *_notifyItem;
}

@property (weak, nonatomic) IBOutlet OLEContainerScrollView *scrollView;

@end

@implementation CategoryManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchHandler:)];
    _notifyItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notify"] style:UIBarButtonItemStylePlain target:self action:@selector(notifyHandler:)];
    NSArray *actionButtonItems = @[_notifyItem, searchItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    [self configureUI];
}

- (UICollectionView *)preconfiguredCollectionViewWithItemSize:(CGSize)size inset:(UIEdgeInsets)inset backgroundColor:(UIColor*)color verticalScroll:(BOOL)isVertical
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (!isVertical)
    {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    layout.itemSize = size;
    layout.sectionInset = inset;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    layout.minimumInteritemSpacing = 0.0f;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = color;
    return collectionView;
}

-(void) configureUI
{
    // set background for view of controller
    self.view.backgroundColor = [UIColor grayColor];
    
    // set banner imageview
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    //    _bannerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner"]];
    
    UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 125)];
    
    imageView.backgroundColor = [UIColor whiteColor];
    _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, width, 120)];
    _bannerImageView.image = [UIImage imageNamed:@"banner"];
    [_bannerImageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView addSubview:_bannerImageView];
    
    NSLog(@"Height image = %f", _bannerImageView.image.size.height);
    
    // create header for category collectionview
    UIView *headerCategory = [[UIView alloc] initWithFrame:CGRectMake(0.0, 50.0, width, 50)];
    headerCategory.backgroundColor = [UIColor clearColor];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 100.0, 30.0)];
    [headerTitle setText:@"DANH MỤC"];
    [headerCategory addSubview:headerTitle];
    
    
    // create category collectionview
    CGSize categoryItemSize = CGSizeMake(80.0, 80.0);  // custom item size for category item
    UIEdgeInsets categoryInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0); // custom inset for category item
    
    _categoryCollectionView = [self preconfiguredCollectionViewWithItemSize:categoryItemSize inset:categoryInset backgroundColor:[UIColor whiteColor] verticalScroll:YES];
    [_categoryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCell"];  // register custom cell for category item
    
    // create header for promotion collection view
    UIView *headerPromotion = [[UIView alloc] initWithFrame:CGRectMake(0.0, 50.0, width, 50)];
    headerPromotion.backgroundColor = [UIColor clearColor];
    UILabel *headerPromotionTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 200.0, 30.0)];
    [headerPromotionTitle setText:@"SẢN PHẨM KHUYẾN MẠI"];
    [headerPromotion addSubview:headerPromotionTitle];
    
    // create promotion collection view
    CGSize promotionItemSize = CGSizeMake(100.0, 150.0);  // custom item size for category item
    UIEdgeInsets promotionInset = UIEdgeInsetsMake(0.0, 2.5, 0.0, 2.5); // custom inset for category item
    
    _promotionCollectionView = [self preconfiguredCollectionViewWithItemSize:promotionItemSize inset:promotionInset backgroundColor:[UIColor clearColor] verticalScroll:YES];
    [_promotionCollectionView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:KVOContext];
    
    [_promotionCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PromotionCell"];  // register custom cell for category item
    
    UIView *promotionContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 200.0)];
    promotionContainer.backgroundColor = [UIColor whiteColor];
    [promotionContainer addSubview:_promotionCollectionView];
    
    [self.scrollView.contentView addSubview:imageView];
    [self.scrollView.contentView addSubview:headerCategory];
    [self.scrollView.contentView addSubview:_categoryCollectionView];
    [self.scrollView.contentView addSubview:headerPromotion];
    [self.scrollView.contentView addSubview:_promotionCollectionView];
}

#pragma mark - KVO
static void *KVOContext = &KVOContext;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        // Initiate a layout recalculation only when a subviewʼs frame or contentSize has changed
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UIScrollView *scrollView = object;
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            NSLog(@"oldContentSize = (%f, %f)", oldContentSize.width, oldContentSize.height);
            NSLog(@"newContentSize = (%f, %f)", newContentSize.width, newContentSize.height);
            if (!CGSizeEqualToSize(newContentSize, oldContentSize)) {
                //                [self setNeedsLayout];
                //                [self layoutIfNeeded];
            }
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))] ||
                   [keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
            UIView *subview = object;
            CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newFrame = subview.frame;
            if (!CGRectEqualToRect(newFrame, oldFrame)) {
                //                [self setNeedsLayout];
                //                [self layoutIfNeeded];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - CollectionView delegate and datasource
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == _categoryCollectionView)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    }
    else if (collectionView == _promotionCollectionView)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PromotionCell" forIndexPath:indexPath];
    }
    cell.backgroundColor = [UIColor brownColor];
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
