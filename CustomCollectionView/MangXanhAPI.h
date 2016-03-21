//
//  MangXanhAPI.h
//  CustomCollectionView
//
//  Created by Viet Khang on 3/16/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PromotionSearchCompletionBlock)(NSArray *results, NSError *error);
typedef void (^CompletionBlock)(NSInteger totalPage, NSArray *results, NSError *error);
typedef void (^ImageCompletionBlock)(UIImage* image, NSError *error);

typedef void (^PromotionPhotoCompletionBlock)(UIImage *photoImage, NSError *error);
typedef void (^TokenCompletionBlock)(NSString *tokenId, NSError *error);

@interface MangXanhAPI : NSObject

@property(nonatomic, copy) NSString *tokenId;

+(MangXanhAPI*)shareAPIClient;

-(void) getTokenIdWithDeviceId:(NSString*)deviceId completionBlock: (TokenCompletionBlock)completionBlock;

-(void) getTopSellingItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock;
- (void)getPromotionItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock;
-(void) getPopularItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock;
-(void) getImageFromURLString:(NSString*)urlString completionBlock:(ImageCompletionBlock)completionBlock;

@end
