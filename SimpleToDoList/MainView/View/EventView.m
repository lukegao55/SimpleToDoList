//
//  EventView.m
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import "EventView.h"
#import "EventInfoTableViewCell.h"
#import "macros.h"
#import <Masonry.h>


@interface EventView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation EventView

#pragma mark - Lift Cycle
- (instancetype)initWithType:(EventViewType)type {
    self = [super init];
    if (self) {
        self.type = type;
        [self setupUI];
    }
    return self;
}

#pragma mark - Functionality

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    // Subviews
    [self addSubview:self.titleLabel];
    [self addSubview:self.dismissBtn];
    [self addSubview:self.editBtn];
    [self addSubview:self.eventInfoTableView];
    
    // Layout
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(30);
    }];
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    [self.eventInfoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel).offset(30);
        make.bottom.equalTo(self.editBtn.mas_top).offset(-20);
        make.left.right.equalTo(self);
    }];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-24);
        make.left.equalTo(self.eventInfoTableView).offset(20);
        make.right.equalTo(self.eventInfoTableView).offset(-20);
    }];
}

#pragma mark - Lazy Loading

- (EventViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[EventViewModel alloc] init];
    }
    return _viewModel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBlack];
        if (self.type == EventViewTypeNew) {
            _titleLabel.text = @"New Event";
        } else if (self.type == EventViewTypeCheck) {
            _titleLabel.text = @"Event Info";
        }
    }
    return _titleLabel;
}

- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [[UIButton alloc] init];
        if (self.type == EventViewTypeNew) {
            [_editBtn setTitle:@"Save" forState:UIControlStateNormal];
        } else if (self.type == EventViewTypeCheck) {
            [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
        }
        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editBtn setBackgroundColor:[UIColor colorWithRed:51 / 255.f green:161 / 255.f blue:201 / 255.f alpha:1]];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBlack];
        [_editBtn addTarget:self.viewModel action:@selector(editBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] init];
        [_dismissBtn setTitle:@"X" forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_dismissBtn addTarget:self.viewModel action:@selector(dismissBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UITableView *)eventInfoTableView {
    if (!_eventInfoTableView) {
        _eventInfoTableView = [[UITableView alloc] init];
        [_eventInfoTableView registerClass:[EventInfoTableViewCell class] forCellReuseIdentifier:[EventInfoTableViewCell reuseIdentifier]];
        _eventInfoTableView.scrollEnabled = NO;
        _eventInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _eventInfoTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _eventInfoTableView.dataSource = self.viewModel;
        _eventInfoTableView.delegate = self.viewModel;
        if (self.type == EventViewTypeCheck) {
            _eventInfoTableView.userInteractionEnabled = NO;
        }
    }
    return _eventInfoTableView;
}

@end
