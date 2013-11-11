//
//  WeatherEngine.m
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-11.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import "WeatherEngine.h"
#import "WeartherParser.h"

static NSString *const URLString = @"%@weather.php?format=xml";
//NSString *weatherUrl = [NSString stringWithFormat:@"%@weather.php?format=xml",BaseURLString];

@implementation WeatherEngine
- (MKNetworkOperation*) getWeather:(NSDictionary *)params
                 completionHandler:(WeatherResponseBlock)completionBlock
                      errorHandler:(MKNKErrorBlock)errorBlock{
    MKNetworkOperation *op = [self operationWithPath:URLString
                                              params:params
                                          httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         // the completionBlock will be called twice.
         // if you are interested only in new values, move that code within the else block
         NSString *valueString = [[completedOperation responseString] componentsSeparatedByString:@","][1];
         DLog(@"%@", valueString);
         
         if([completedOperation isCachedResponse]) {
             DLog(@"Data from cache %@", [completedOperation responseString]);
         }
         else {
             DLog(@"Data from server %@", [completedOperation responseString]);
         }
         NSData *responseData = [completedOperation responseData];
         WeartherParser *parser = [WeartherParser new];
         NSArray *weatherList = [parser parseWeather:responseData];
         completionBlock(weatherList);
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}
@end
