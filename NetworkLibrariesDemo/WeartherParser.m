//
//  WeartherParser.m
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-11.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import "WeartherParser.h"
#import "GDataXMLNode.h"
#import "Weather.h"

@implementation WeartherParser
- (NSArray *)parseWeather:(NSData *)data{
    NSMutableArray *weatherList = [NSMutableArray new];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *items = [doc nodesForXPath:@"//weather" error:nil];
    for (GDataXMLElement *item in items) {
        Weather *weather = [Weather new];
        for(GDataXMLElement *wea in [item nodesForXPath:@"//weatherDesc/value" error:nil]) {
            weather.weatherDesc = wea.stringValue;
            break;
        }
        for(GDataXMLElement *wea in [item nodesForXPath:@"//weatherIconUrl/value" error:nil]) {
            weather.weatherImageUrl = wea.stringValue;
            break;
        }
        [weatherList addObject:weather];
        
    }
    return [NSArray arrayWithArray:weatherList];
}
@end
