//
//  EventView.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventViewModel.h"
#import "EventInfoTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EventViewType) {
    EventViewTypeNew = 0, // Access from add event button
    EventViewTypeCheck = 1 // Access from cell info button
};

@interface EventView : UIView

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) EventViewModel<UITableViewDelegate, UITableViewDataSource> *viewModel;

@property (nonatomic, strong) UIViewController *parentVC;

@property (nonatomic, assign) EventViewType type;

@property (nonatomic, strong) UITableView *eventInfoTableView;

- (instancetype)initWithType:(EventViewType)type;

- (void)updateUIAfterSaving;

@end

NS_ASSUME_NONNULL_END
