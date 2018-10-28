//
//  EventViewModel.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventViewModel : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSDictionary *selectedEvent;

- (void)cleanupData;

- (NSArray *)retrieveDataWithKey:(NSString *)key;

- (void)editBtnPressed:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
