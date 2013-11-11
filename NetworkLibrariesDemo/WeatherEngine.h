//
//  WeatherEngine.h
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-11.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

typedef void (^WeatherResponseBlock)(NSArray *weatherList);

@interface WeatherEngine : MKNetworkEngine
- (MKNetworkOperation*) getWeather:(NSDictionary *)params
                 completionHandler:(WeatherResponseBlock)completion
                      errorHandler:(MKNKErrorBlock)error;
@end
