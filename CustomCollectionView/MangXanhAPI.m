//
//  MangXanhAPI.m
//  CustomCollectionView
//
//  Created by Viet Khang on 3/16/16.
//  Copyright © 2016 Viet Khang. All rights reserved.
//

#import "MangXanhAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "Product.h"

@implementation MangXanhAPI
{
    NSString *_tokenId;
}

static MangXanhAPI *_shareAPIClient = nil;

+(MangXanhAPI*)shareAPIClient
{
    @synchronized([MangXanhAPI class])
    {
        if (!_shareAPIClient)
            _shareAPIClient = [[MangXanhAPI alloc] init];
        return _shareAPIClient;
    }
    return nil;
}


- (NSString *)getURLFormatWithInfo:(NSDictionary*)urlInfo
{
    NSString *urlFormat = nil;
    NSString *deviceId = urlInfo[@"device_id"];
    if (deviceId)
    {
        NSString *url = urlInfo[@"url"];
        urlFormat = [NSString stringWithFormat:@"%@%@", url, deviceId];
    }
    else
    {
        
    }
    return urlFormat;
}

-(void) getTokenIdWithDeviceId:(NSString*)deviceId completionBlock:(TokenCompletionBlock)completionBlock
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSURLResponse* response;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://gnetapps.com/accountapi/getguesttokenv2&device_id=%@", currentDeviceId]]] returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Load token id failed with error: %@", error.localizedDescription);
        completionBlock(nil, error);
    }
    else {
        // get token id from json return
        error = nil;
        NSDictionary *tokendDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            NSLog(@"Parse token id from json faild with error: %@", error.localizedDescription);
            completionBlock(nil, error);
        }
        else {
            NSString *tokenId = tokendDictionary[@"token"];
            completionBlock(tokenId, nil);
        }
    }
}

- (void)getPromotionItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock
{
    if (self.tokenId)
    {
        NSString *urlAsString = [NSString stringWithFormat:@"https:/gnetapps.com/api.php?method=accountapi.getPromoListing&page=%ld&token=%@", (long)page, self.tokenId];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        [self getProductsAtURL:url completionBlock:completionBlock];
    }
    else
    {
        // handle when hasn't token id
    }
}

-(void) getTopSellingItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock
{
    if (self.tokenId)
    {
        NSString *urlAsString = [NSString stringWithFormat:@"https://gnetapps.com/api.php?method=accountapi.getTopSellListing&page=%ld&token=%@", (long)page, self.tokenId];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        [self getProductsAtURL:url completionBlock:completionBlock];
    }
    else
    {
        // handle when hasn't token id
    }
}

-(void) getPopularItemsOnPage:(NSInteger)page completionBlock:(CompletionBlock) completionBlock {
    if (self.tokenId)
    {
        NSString *urlAsString = [NSString stringWithFormat:@"https:/gnetapps.com/api.php?method=accountapi.getFeaturedListing&page=%ld&token=%@", (long)page, self.tokenId];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        [self getProductsAtURL:url completionBlock:completionBlock];
    }
    else {
        
    }
}

-(void) getProductsAtURL:(NSURL*)url completionBlock:(CompletionBlock) completionBlock
{
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            completionBlock(0, nil, error);
        } else {
            NSError *err = nil;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if (err)
            {
                completionBlock(0, nil, err);
            }
            else
            {
                // parse data from server return
                NSArray *output = jsonDictionary[@"output"];
                NSNumber *totalPage = [jsonDictionary valueForKeyPath:@"api.total"];
                NSMutableArray *result = [[NSMutableArray alloc] init];
                if (output && totalPage)
                {
                    for (NSDictionary *productDictionary in output)
                    {
                        Product *product = [[Product alloc] init];
                        product.title = productDictionary[@"title"];
                        product.price = productDictionary[@"price"];
                        product.dcPercent = productDictionary[@"dcpercent"];
                        product.finalPrice = productDictionary[@"final_price"];
                        product.totalComment = productDictionary[@"total_comment"];
                        product.totalLike = productDictionary[@"total_like"];
                        product.url = productDictionary[@"listing_image"];
                        [result addObject:product];
                    }
                    completionBlock([totalPage integerValue],result, nil);
                }
            }
        }
    }];
}

-(void) getImageFromURLString:(NSString*)urlString completionBlock:(ImageCompletionBlock)completionBlock
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            completionBlock(nil, error);
        }
        else {
            // if get image data success
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                // if get image success
                if (image) {
                    completionBlock(image, nil);
                }
                // if get image data failed
                else {
                    completionBlock(nil, nil);
                }
            }
            // if get image data failed
            else {
                completionBlock(nil, nil);
            }
        }
    }];
    [task resume];
}




@end
