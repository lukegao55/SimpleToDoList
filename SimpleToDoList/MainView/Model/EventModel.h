//
//  EventModel.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/4/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EventImportanceLevel) {
    EventImportanceLevelNormal = 0,
    EventImportanceLevelImportant = 1,
    EventImportanceLevelVeryImportant = 2
};

@interface EventModel : NSObject


@end

NS_ASSUME_NONNULL_END
