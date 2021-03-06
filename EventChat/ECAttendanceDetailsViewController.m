//
//  ECAttendanceDetailsViewController.m
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECAttendanceDetailsViewController.h"
#import "ECAttendanceResponseTableViewCell.h"
#import "ECAttendeeListTableViewCell.h"
#import "ECAPI.h"
#import "ECAttendanceResponseTableViewCell.h"
#import "AppDelegate.h"

@interface ECAttendanceDetailsViewController ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString* responseStr;
@end

@implementation ECAttendanceDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self getFeedItemAttendeeList];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 115.0;
    }
    else{
        return 60.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else{
        return [self.attendeeList count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Your Response";
    }
    else{
        return @"What others are saying";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        
        static NSString *cellIdentifier = @"ECAttendanceResponseTableViewCell";
        ECAttendanceResponseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ECAttendanceResponseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.delegate = self;
        if (self.isPost){
            [cell configureWithPostItem:self.selectedPostItem :self.responseStr];
        }else{
            [cell configureWithFeedItem:self.selectedFeedItem :self.responseStr];
        }
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"ECAttendeeListTableViewCell";
        ECAttendeeListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ECAttendeeListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        ECAttendee *attendee = [self.attendeeList objectAtIndex:indexPath.row];
        [cell configureWithAttendee:attendee];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - API Methods
-(void)getFeedItemAttendeeList{
    NSString *mID = @"";
    if (self.isPost){
        mID = self.selectedPostItem.postId;
    }else{
        mID = self.selectedFeedItem.feedItemId;
    }
    
    [[ECAPI sharedManager] getAttendeeList:mID callback:^(NSArray *attendees, NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
        } else {
            self.attendeeList = [[NSArray alloc] initWithArray:attendees copyItems:true];
            self.responseStr = @"";
            
            for (int i = 0; i < [self.attendeeList count]; i++){
                ECAttendee *attList = [self.attendeeList objectAtIndex:i];
                if ([attList.userId isEqualToString:self.signedInUser.userId]){
                    self.responseStr = attList.response;
                }
            }
            [self.attendeeListTableView reloadData];
        }
    }];
}

#pragma mark - ECAttendanceResponseTableViewCellDelegate Method
- (void)attendListDidUpdateAttendanceReponse:(ECAttendanceResponseTableViewCell *)ecAttendanceResponseTableViewCell{
    [self getFeedItemAttendeeList];
}

@end
