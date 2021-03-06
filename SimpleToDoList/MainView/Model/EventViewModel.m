//
//  EventViewModel.m
//  SimpleToDoList
//
//  Created by Luke Gao on 10/6/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import "EventViewModel.h"
#import "EventView.h"
#import "EventModel.h"
#import "EventInfoTableViewCell.h"
#import "MainViewController.h"
#import "Macros.h"

@interface EventViewModel () 

@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, strong) NSDate *dateSelected;

@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *hour;
@property (nonatomic, strong) NSString *min;
@property (nonatomic, strong) NSString *memo;

@property (nonatomic, assign) EventImportanceLevel importanceLevel;

@property (nonatomic, strong) NSString *placeholder; // Placeholder for input text field of event name

@property (nonatomic, assign) BOOL isRevised;

@end

@implementation EventViewModel

#pragma mark - Functionality

- (void)cleanupData {
    NSMutableArray *eventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"events"] mutableCopy];
    NSMutableArray *finishedEventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"finishedEvents"] mutableCopy];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [eventArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval eventTime = [[obj objectForKey:kTimestamp] doubleValue];
        if (![self isSameDay:eventTime Time2:currentTime]) {
            [eventArray removeObject:obj];
        }
    }];
    [finishedEventArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval eventTime = [[obj objectForKey:kTimestamp] doubleValue];
        if (![self isSameDay:eventTime Time2:currentTime]) {
            [finishedEventArray removeObject:obj];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setObject:eventArray forKey:@"events"];
    [[NSUserDefaults standardUserDefaults] setObject:finishedEventArray forKey:@"finishedEvents"];
}

- (NSArray *)retrieveDataWithKey:(NSString *)key {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:key] isKindOfClass:[NSArray class]]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    } else {
        return nil;
    }
}

- (BOOL)isSameDay:(double)time1 Time2:(double)time2 {
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:time1 / 1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:time2 / 1000];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:pDate2];
    return [comp1 day]   == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

- (void)editBtnPressed:(UIButton *)sender {
    if ([sender.superview isKindOfClass:[EventView class]]) {
        EventView *view = (EventView *)sender.superview;
        NSIndexPath *idxPath1 = [NSIndexPath indexPathForRow:0 inSection:0]; // Eventname cell
        NSIndexPath *idxPath2 = [NSIndexPath indexPathForRow:0 inSection:1]; // Memo cell
        if (view.type == EventViewTypeNew) {
            [[view.eventInfoTableView delegate] tableView:view.eventInfoTableView
                                didDeselectRowAtIndexPath:idxPath1]; // Deselect all input cell
            [[view.eventInfoTableView delegate] tableView:view.eventInfoTableView
                                didDeselectRowAtIndexPath:idxPath2];
            // If eventname is empty, toast
            if (self.eventName.length == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Enter a name!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(dismissAlert) userInfo:nil repeats:NO];
            } else {
                [self saveEvent];
                [view updateUIAfterSaving];
            }
        } else if (view.type == EventViewTypeCheck) {
            [sender setTitle:@"Save" forState:UIControlStateNormal];
            view.eventInfoTableView.userInteractionEnabled = YES;
            if (!self.isRevised) {
                self.isRevised = YES;
                // Select event name cell
                [[view.eventInfoTableView delegate] tableView:view.eventInfoTableView
                                      didSelectRowAtIndexPath:idxPath1];
            } else {
                // Deselect all input cell
                [[view.eventInfoTableView delegate] tableView:view.eventInfoTableView
                                    didDeselectRowAtIndexPath:idxPath1];
                [[view.eventInfoTableView delegate] tableView:view.eventInfoTableView
                                    didDeselectRowAtIndexPath:idxPath2];
                if (self.eventName.length == 0) {
                    // If eventname is empty, toast
                    UIAlertController *alert = [UIAlertController
                                                alertControllerWithTitle:@"Error"
                                                message:@"Enter a name!"
                                                preferredStyle:UIAlertControllerStyleAlert];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                                 animated:YES
                                                                                               completion:nil];
                    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(dismissAlert)
                                                   userInfo:nil repeats:NO];
                } else {
                    [self saveEvent];
                    [view updateUIAfterSaving];
                    self.isRevised = NO;
                }
            }
        }
    }
}

- (void)saveEvent {
    // Update event
    NSDictionary *eventDic = [NSDictionary dictionaryWithObjectsAndKeys:self.eventName,kEventName,self.hour,kHour,self.min,kMin,self.memo,kMemo,@(self.importanceLevel),kImportanceLevel,@(self.timestamp),kTimestamp, nil];
    NSMutableArray *eventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"events"] mutableCopy];
    if (self.selectedEvent) {
        NSUInteger idx = [eventArray indexOfObject:self.selectedEvent];
        [eventArray replaceObjectAtIndex:idx withObject:eventDic];
    } else {
        [eventArray addObject:eventDic];
    }
    [[NSUserDefaults standardUserDefaults] setObject:eventArray forKey:@"events"];
}

- (void)dismissAlert {
    for (UIAlertController *alert in [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Lazy Loading

- (NSTimeInterval)timestamp {
    return [self.dateSelected timeIntervalSince1970];
}

- (NSDate *)dateSelected {
    if (!_dateSelected) {
        _dateSelected = [NSDate date];
    }
    return _dateSelected;
}

- (NSString *)eventName {
    if (!_eventName) {
        _eventName = @"";
    }
    return _eventName;
}

- (NSString *)hour {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH"];
        return [dateFormatter stringFromDate:self.dateSelected];
}

- (NSString *)min {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm"];
    return [dateFormatter stringFromDate:self.dateSelected];
}

- (NSString *)memo {
    if (!_memo) {
        _memo = @"";
    }
    return _memo;
}
- (EventImportanceLevel)importanceLevel {
    if (!_importanceLevel) {
        _importanceLevel = EventImportanceLevelNormal;
    }
    return _importanceLevel;
}

- (NSString *)placeholder {
    if (!_placeholder) {
        _placeholder = @"Enter a name...";
    }
    return _placeholder;
}

#pragma mark - UITableView DateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (section == 0) {
        title = @"Event Info";
    } else if (section == 1) {
        title = @"Memo";
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 100;
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventInfoTableViewCell reuseIdentifier]
                                                                   forIndexPath:indexPath];
    if (!cell) {
        cell = [[EventInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:[EventInfoTableViewCell reuseIdentifier]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell setupUIWithType:EventInfoTableViewCellTypeEventTitleLabelInputTextField];
            cell.titleLabel.text = @"Event Name:";
            cell.inputTextField.delegate = self;
            if (self.selectedEvent == nil) {
                cell.inputTextField.text = self.placeholder;
            } else {
                self.eventName = [self.selectedEvent objectForKey:kEventName];
                cell.inputTextField.text = self.eventName;
            }
            cell.inputTextField.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            [cell setupUIWithType:EventInfoTableViewCellTypeEventTitleLabelDetailLabel];
            cell.titleLabel.text = @"Start Time:";
            if (self.selectedEvent != nil) {
                self.hour = [self.selectedEvent objectForKey:kHour];
                self.min = [self.selectedEvent objectForKey:kMin];
                self.dateSelected = [NSDate dateWithTimeIntervalSince1970:[[self.selectedEvent objectForKey:kTimestamp] doubleValue]];
            }
            cell.detailLabel.text = [NSString stringWithFormat:@"%@:%@",self.hour,self.min];
        } else if (indexPath.row == 2) {
            [cell setupUIWithType:EventInfoTableViewCellTypeEventTitleLabelDetailLabel];
            cell.titleLabel.text = @"Priority:";
            if (self.selectedEvent == nil) {
                cell.detailLabel.text = @"Normal";
            } else {
                self.importanceLevel = [[self.selectedEvent objectForKey:kImportanceLevel] integerValue];
                switch (self.importanceLevel) {
                    case EventImportanceLevelNormal:
                        cell.detailLabel.text = @"Normal";
                        cell.detailLabel.backgroundColor = [UIColor clearColor];
                        break;
                    case EventImportanceLevelImportant:
                        cell.detailLabel.text = @"Important";
                        cell.detailLabel.backgroundColor = [UIColor yellowColor];
                        break;
                    case EventImportanceLevelVeryImportant:
                        cell.detailLabel.text = @"Very Important";
                        cell.detailLabel.backgroundColor = [UIColor redColor];
                        break;
                    default:
                        break;
                }
            }
        }
    } else {
        [cell setupUIWithType:EventInfoTableViewCellTypeEventInputTextView];
        cell.inputTextView.delegate = self;
        if (self.selectedEvent != nil) {
            self.memo = [self.selectedEvent objectForKey:kMemo];
            cell.inputTextView.text = self.memo;
        }
    }
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventInfoTableViewCell *cell = (EventInfoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.inputTextField.userInteractionEnabled = YES;
            [cell.inputTextField becomeFirstResponder];
        } else if (indexPath.row == 1) {
            cell.detailLabel.textColor = [UIColor blackColor];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"\n\n\n\n\n\n\n\n\n"
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            UIDatePicker *datePicker = [[UIDatePicker alloc] init];
            datePicker.minimumDate = [NSDate date];
            datePicker.date = self.dateSelected;
            datePicker.datePickerMode = UIDatePickerModeTime;
            [alert.view addSubview:datePicker];
            [alert addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        self.dateSelected = [datePicker date];
                                                        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                                                        [dateFormatter setDateFormat:@"HH"];
                                                        self.hour = [dateFormatter stringFromDate:self.dateSelected];
                                                        [dateFormatter setDateFormat:@"mm"];
                                                        self.min = [dateFormatter stringFromDate:self.dateSelected];
                                                        cell.detailLabel.text = [NSString stringWithFormat:@"%@:%@",self.hour,self.min];
                                                        cell.detailLabel.textColor = [UIColor blackColor];
            }]];
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert
                                                                                           animated:YES
                                                                                         completion:nil];
        } else if (indexPath.row == 2) {
            cell.detailLabel.textColor = [UIColor blackColor];
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:nil
                                        preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"Very Important"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [tableView deselectRowAtIndexPath:indexPath animated:NO];
                                                        cell.detailLabel.text = @"Very Important";
                                                        cell.detailLabel.backgroundColor = [UIColor redColor];
                                                        self.importanceLevel = EventImportanceLevelVeryImportant;
                                                    }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Important"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [tableView deselectRowAtIndexPath:indexPath animated:NO];
                                                        cell.detailLabel.text = @"Important";
                                                        cell.detailLabel.backgroundColor = [UIColor yellowColor];
                                                        self.importanceLevel = EventImportanceLevelImportant;
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Normal"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [tableView deselectRowAtIndexPath:indexPath animated:NO];
                                                        cell.detailLabel.text = @"Normal";
                                                        cell.detailLabel.backgroundColor = [UIColor clearColor];
                                                        self.importanceLevel = EventImportanceLevelNormal;
                                                    }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:alert completion:nil];
            }]];
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert
                                                                                           animated:YES
                                                                                         completion:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.inputTextView.userInteractionEnabled = YES;
            [cell.inputTextView becomeFirstResponder];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventInfoTableViewCell *cell = (EventInfoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell.inputTextField endEditing:YES];
            cell.inputTextField.userInteractionEnabled = NO;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell.inputTextView endEditing:YES];
            cell.inputTextView.userInteractionEnabled = NO;
        }
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor blackColor];
    if ([textField.text isEqualToString:self.placeholder]) {
        textField.text = nil;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.text = self.placeholder;
        self.eventName = nil;
        textField.textColor = [UIColor grayColor];
    } else {
        self.eventName = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextView Delegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.memo = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
