//
//  EventInfoTableViewCell.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EventInfoTableViewCellType) {
    EventInfoTableViewCellTypeEventTitleLabelInputTextField = 0,
    EventInfoTableViewCellTypeEventTitleLabelDetailLabel = 1,
    EventInfoTableViewCellTypeEventInputTextView = 2,
    
};

@interface EventInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) UITextView *inputTextView;


- (void)setupUIWithType:(EventInfoTableViewCellType)type;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
