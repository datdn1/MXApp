//
//  PopularCell.h
//  CustomCollectionView
//
//  Created by Viet Khang on 3/15/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *sellPrice;
@property (weak, nonatomic) IBOutlet UILabel *originalPrice;

@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *percent;
@property (weak, nonatomic) IBOutlet UIImageView *percentImage;

@end
