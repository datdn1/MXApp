//
//  Product.h
//  CustomCollectionView
//
//  Created by Viet Khang on 3/17/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property(nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *price;
@property (nonatomic, copy) NSNumber *finalPrice;
@property (nonatomic, copy) NSString *totalLike;
@property (nonatomic, copy) NSString *totalComment;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *dcPercent;

@end
