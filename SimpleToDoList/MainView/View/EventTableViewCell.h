//
//  EventTableViewCell.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/28/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *importanceLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *infoBtn;

- (void)configCellWitlEventDic:(NSDictionary *)eventDic;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
