//
//  EventInfoTableViewCell.m
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import "EventInfoTableViewCell.h"
#import "EventViewModel.h"
#import "EventView.h"
#import <Masonry.h>

@interface EventInfoTableViewCell () 

@property (nonatomic, assign) EventInfoTableViewCellType type;

@end

@implementation EventInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setupUIWithType:(EventInfoTableViewCellType)type {
    self.type = type;
    if (self.type == EventInfoTableViewCellTypeEventTitleLabelInputTextField) {
        // Subviews
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.inputTextField];
        
        // Layout
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(20);
        }];
        [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-20);
            make.left.lessThanOrEqualTo(self.contentView.mas_centerX);
        }];
    } else if (self.type == EventInfoTableViewCellTypeEventTitleLabelDetailLabel) {
        // Subviews
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        
        // Layout
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(20);
        }];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    } else if (self.type == EventInfoTableViewCellTypeEventInputTextView) {
        // Subviews
        [self.contentView addSubview:self.inputTextView];
        
        // Layout
        [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView).offset(-20);
        }];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.textColor = [UIColor grayColor];
    }
    return _detailLabel;
}

- (UITextField *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [[UITextField alloc] init];
        _inputTextField.textAlignment = NSTextAlignmentRight;
        _inputTextField.userInteractionEnabled = NO;
    }
    return _inputTextField;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        _inputTextField.userInteractionEnabled = NO;
    }
    return _inputTextView;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}


@end
