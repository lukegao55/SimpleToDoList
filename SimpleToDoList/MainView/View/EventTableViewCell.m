//
//  EventTableViewCell.m
//  SimpleToDoList
//
//  Created by Luke Gao on 10/28/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import "EventTableViewCell.h"
#import "EventModel.h"
#import "macros.h"
#import <Masonry.h>

@implementation EventTableViewCell

#pragma mark - Life Cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Functionality

- (void)setupUI {
    // Subviews
    [self.contentView addSubview:self.importanceLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.infoBtn];
    
    // Layout
    [self.importanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(@(20));
        make.width.equalTo(@(10));
        make.height.equalTo(@(10));
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.importanceLabel);
        make.left.equalTo(self.importanceLabel.mas_right).offset(20);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.importanceLabel);
        make.left.equalTo(self.timeLabel.mas_right).offset(20);
        make.right.lessThanOrEqualTo(self.infoBtn.mas_left);
    }];
    [self.infoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.importanceLabel);
        make.right.equalTo(self.contentView).offset(-20);
    }];
}

- (void)configCellWitlEventDic:(NSDictionary *)eventDic {
    self.importanceLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.nameLabel.hidden = NO;
    self.infoBtn.hidden = NO;
    EventImportanceLevel importanceLevel = [[eventDic objectForKey:kImportanceLevel] integerValue];
    switch (importanceLevel) {
        case EventImportanceLevelNormal:
            self.importanceLabel.backgroundColor = [UIColor clearColor];
            break;
        case EventImportanceLevelImportant:
            self.importanceLabel.backgroundColor = [UIColor yellowColor];
            break;
        case EventImportanceLevelVeryImportant:
            self.importanceLabel.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }
    NSString *hour = [eventDic objectForKey:kHour];
    NSString *min = [eventDic objectForKey:kMin];
    NSString *eventName = [eventDic objectForKey:kEventName];
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", hour, min];
    self.nameLabel.text = eventName;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

#pragma mark - Lazy Loading

- (UILabel *)importanceLabel {
    if (!_importanceLabel) {
        _importanceLabel = [[UILabel alloc] init];
    }
    return _importanceLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
    }
    return _timeLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UIButton *)infoBtn {
    if (!_infoBtn) {
        _infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    }
    return _infoBtn;
}

@end
