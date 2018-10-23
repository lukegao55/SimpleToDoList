//
//  MainViewController.h
//  SimpleToDoList
//
//  Created by Luke Gao on 10/4/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController

@property (nonatomic, strong) CALayer *maskLayer; // Mask for the window when event view is presented

@property (nonatomic, strong) EventView *eventView;

- (void)reloadData;

- (void)cellInfoBtnPressed:(UIButton *)sender;


@end

NS_ASSUME_NONNULL_END
