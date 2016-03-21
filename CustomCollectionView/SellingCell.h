//
//  SellingCell.h
//  CustomCollectionView
//
//  Created by Viet Khang on 3/18/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellingCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellingPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *percent;
@property (weak, nonatomic) IBOutlet UIImageView *percentImage;

@end
