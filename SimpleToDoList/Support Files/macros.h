//
//  macros.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/4/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEVICE_WIDTH    [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define IS_IPHONEX [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0
#define kEventName @"EVENTNAME"
#define kHour @"HOUR"
#define kMin @"MIN"
#define kMemo @"MEMO"
#define kImportanceLevel @"IMPORTANCELEVEL"
#define kTimestamp @"TIMESTAMP"
#define kEvent @"events"
#define kFinishedEvent @"finishedEvents"

NS_ASSUME_NONNULL_BEGIN

@interface macros : NSObject

@end

NS_ASSUME_NONNULL_END
