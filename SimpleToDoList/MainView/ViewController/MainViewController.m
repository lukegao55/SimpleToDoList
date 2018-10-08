//
//  MainViewController.m
//  SimpleToDoList
//
//  Created by Luke Gao on 10/4/18.
//  Copyright © 2018 Luke Gao. All rights reserved.
//

#import "MainViewController.h"
#import "EventView.h"
#import "EventModel.h"
#import "EventInfoTableViewCell.h"
#import "macros.h"
#import <Masonry.h>

#pragma mark - EventTableViewCell

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *importanceLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *infoBtn;

@end

@implementation EventTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

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

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

@end

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *eventTableView;

@property (nonatomic, strong) UIBarButtonItem *addEventBtn;

@property (nonatomic, strong) NSMutableArray *eventArray;
@property (nonatomic, strong) NSMutableArray *finishedEventArray;

@end

@implementation MainViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self cleanData];
    [self setupData];
    [self setupUI];
    
}

#pragma mark - Functionality

- (void)cleanData {
    // Clean up any event that is planned at 24 hr ago
    self.eventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"events"] mutableCopy];
    self.finishedEventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"finishedEvents"] mutableCopy];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [self.eventArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval eventTime = [[obj objectForKey:kTimestamp] doubleValue];
        if (![self isSameDay:eventTime Time2:currentTime]) {
            [self.eventArray removeObject:obj];
        }
    }];
    [self.finishedEventArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval eventTime = [[obj objectForKey:kTimestamp] doubleValue];
        if (![self isSameDay:eventTime Time2:currentTime]) {
            [self.finishedEventArray removeObject:obj];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setObject:self.eventArray forKey:@"events"];
    [[NSUserDefaults standardUserDefaults] setObject:self.finishedEventArray forKey:@"finishedEvents"];
}

- (void)setupData {
    self.eventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"events"] mutableCopy];
    self.finishedEventArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"finishedEvents"] mutableCopy];
    self.eventArray = [NSMutableArray arrayWithArray: [self.eventArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:kTimestamp] compare:[obj2 valueForKey:kTimestamp]];
    }]];
    self.finishedEventArray = [NSMutableArray arrayWithArray: [self.finishedEventArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:kTimestamp] compare:[obj2 valueForKey:kTimestamp]];
    }]];
}

- (void)setupUI {
    self.title = @"SimpleToDoList";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.addEventBtn;
    // Subviews
    [self.view addSubview:self.eventTableView];
    
    // Layout
    [self.eventTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPHONEX) {
            make.top.equalTo(self.view).offset(88);
        } else {
            make.top.equalTo(self.view).offset(64);
        }
        make.bottom.equalTo(self.view).offset(-34);
        make.left.right.equalTo(self.view);
    }];
}

- (void)reloadData {
    [self setupData];
    [self.eventTableView reloadData];
}

// What: check if two timestamps are in same day
// Where: https://www.jianshu.com/p/cdf65d28be7c
// Why: need to implement logic to clean up the event that is created by yesterday

- (BOOL)isSameDay:(double)time1 Time2:(double)time2
{
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:time1 / 1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:time2 / 1000];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    return [comp1 day]   == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

- (void)addEventBtnPressed:(UIBarButtonItem *)sender {
    [self.eventView removeFromSuperview];
    self.eventView = [[EventView alloc] initWithType:EventViewTypeNew];
     self.eventView.parentVC = self;
    [self.view addSubview: self.eventView];
    [self.view.layer insertSublayer:self.maskLayer below:self.eventView.layer];
     self.eventView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT / 2);
    [UIView animateWithDuration:0.5 animations:^{
         self.eventView.frame = CGRectMake(0, DEVICE_HEIGHT / 2, DEVICE_WIDTH, DEVICE_HEIGHT / 2);
    }];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)cellInfoBtnPressed:(UIButton *)sender {
    [self.eventView removeFromSuperview];
    sender.userInteractionEnabled = NO;
    UIView *contentView = [sender superview];
    if ([[contentView superview] isKindOfClass:[EventTableViewCell class]]) {
        EventInfoTableViewCell *cell = (EventInfoTableViewCell *)[contentView superview];
        NSIndexPath *indexPath = [self.eventTableView indexPathForCell:cell];
        self.eventView = [[EventView alloc] initWithType:EventViewTypeCheck];
        self.eventView.parentVC = self;
        if (indexPath.section == 0) {
            self.eventView.viewModel.selectedEvent = self.eventArray[indexPath.row];
            self.eventView.editBtn.hidden = NO;
        } else {
            self.eventView.viewModel.selectedEvent = self.finishedEventArray[indexPath.row];
            self.eventView.editBtn.hidden = YES;
        }
        [self.view addSubview:self.eventView];
        [self.view.layer insertSublayer:self.maskLayer below:self.eventView.layer];
        self.eventView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT / 2);
        [UIView animateWithDuration:0.5 animations:^{
            self.eventView.frame = CGRectMake(0, DEVICE_HEIGHT / 2, DEVICE_WIDTH, DEVICE_HEIGHT / 2);
        }];
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        [self.navigationController.navigationBar setHidden:YES];
    }
}

#pragma mark - Lazy Loading

- (UITableView *)eventTableView {
    if (!_eventTableView) {
        _eventTableView = [[UITableView alloc] init];
        [_eventTableView registerClass:[EventTableViewCell class] forCellReuseIdentifier:[EventTableViewCell reuseIdentifier]];
    }
    _eventTableView.allowsSelection = NO;
    _eventTableView.allowsSelectionDuringEditing = NO;
    _eventTableView.allowsMultipleSelectionDuringEditing = NO;
    _eventTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _eventTableView.backgroundColor = [UIColor whiteColor];
    _eventTableView.dataSource = self;
    _eventTableView.delegate = self;
    
    return _eventTableView;
}

- (UIBarButtonItem *)addEventBtn {
    if (!_addEventBtn) {
        _addEventBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEventBtnPressed:)];
    }
    return _addEventBtn;
}

- (CALayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [[CALayer alloc] init];
        _maskLayer.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
        [_maskLayer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor];
    }
    return _maskLayer;
}

- (NSMutableArray *)eventArray {
    if (!_eventArray) {
        _eventArray = [[NSMutableArray alloc] init];
    }
    return _eventArray;
}

- (NSMutableArray *)finishedEventArray {
    if (!_finishedEventArray) {
        _finishedEventArray = [[NSMutableArray alloc] init];
    }
    return _finishedEventArray;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1;
    if (self.finishedEventArray.count != 0) {
        sections += 1;
    }
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    if (section == 0) {
        title = @"Ongoing";
    } else if (section == 1) {
        title = @"Finished";
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.eventArray.count == 0 ? 1:self.eventArray.count;
    } else if (section == 1) {
        return self.finishedEventArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventTableViewCell reuseIdentifier] forIndexPath:indexPath];
    if (!cell) {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EventTableViewCell reuseIdentifier]];
    }
    if (indexPath.section == 0) {
        if (self.eventArray.count == 0) {
            cell.timeLabel.text = @"Nothing to do today.";
            cell.infoBtn.hidden = YES;
            cell.nameLabel.hidden = YES;
            cell.importanceLabel.hidden = YES;
        } else {
            [cell configCellWitlEventDic:self.eventArray[indexPath.row]];
        }
    } else if (indexPath.section == 1) {
        [cell configCellWitlEventDic:self.finishedEventArray[indexPath.row]];
    }
    [cell.infoBtn addTarget:self action:@selector(cellInfoBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.infoBtn.userInteractionEnabled = YES;
    return cell;
}

#pragma mark - UITableView Delegate

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.section == 0) {
            [self.eventArray removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:self.eventArray forKey:@"events"];
        } else if (indexPath.section == 1) {
            [self.finishedEventArray removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:self.finishedEventArray forKey:@"finishedEvents"];
        }
        [tableView reloadData];
    }];
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done!" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.finishedEventArray addObject:self.eventArray[indexPath.row]];
        [self.eventArray removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.eventArray forKey:@"events"];
        [[NSUserDefaults standardUserDefaults] setObject:self.finishedEventArray forKey:@"finishedEvents"];
        [tableView reloadData];
    }];
    action2.backgroundColor = [UIColor blueColor];
    if (indexPath.section == 0) {
        return @[action1,action2];
    } else {
        return @[action1];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.eventArray.count == 0) {
        return NO;
    } 
    return YES;
}

@end
