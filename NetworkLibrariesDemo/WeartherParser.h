//
//  WeartherParser.h
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-11.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeartherParser : NSObject
- (NSArray *)parseWeather:(NSData *)data;
@end
