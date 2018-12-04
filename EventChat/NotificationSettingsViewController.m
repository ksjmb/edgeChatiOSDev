//
//  NotificationSettingsViewController.m
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "NotificationSettingsCell.h"

@interface NotificationSettingsViewController ()

@end

@implementation NotificationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"Notification Settings"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else{
        return 4;
    }
    //return [self.topics count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @" ";
    }
    else{
        return @" ";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationSettingsCell";
    NotificationSettingsCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[NotificationSettingsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section == 0){
        [cell configureWithData:@"Allow Notifications"];
    }
    else{
        if (indexPath.row == 0) {
            [cell configureWithData:@"General Notifications"];
        }
        else if(indexPath.row == 1) {
            [cell configureWithData:@"User replies to your comment"];
        }
        else if(indexPath.row == 2) {
            [cell configureWithData:@"User likes your comment"];
        }
        else if(indexPath.row == 3) {
            [cell configureWithData:@"User starts following you"];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

@end
