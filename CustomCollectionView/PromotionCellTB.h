//
//  PromotionCellTB.h
//  CustomCollectionView
//
//  Created by Viet Khang on 3/16/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionCellTB : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *sellPrice;

@property (weak, nonatomic) IBOutlet UILabel *originalPrice;

@property (weak, nonatomic) IBOutlet UILabel *comment;

@property (weak, nonatomic) IBOutlet UILabel *numberOfBuy;

@end
