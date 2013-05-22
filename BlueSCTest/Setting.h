//
//  Setting.h
//  BlueSCTest
//
//  Created by junpeiwada on 2013/05/21.
//  Copyright (c) 2013年 soneru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject
+ (Setting *)instance;

@property (nonatomic,weak)NSString *targetBlueSC_UUID;
@property (nonatomic,weak)NSString *targetBlueHR_UUID;

@end
