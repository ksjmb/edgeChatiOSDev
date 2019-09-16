//
//  ECFollowViewController.m
//  EventChat
//
//  Created by Jigish Belani on 10/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECFollowViewController.h"
#import "ECAPI.h"
#import "DCProfileTableViewController.h"
#import "ECUser.h"
#import "ECIndividualProfileViewController.h"

@interface ECFollowViewController ()
@property (nonatomic, weak) IBOutlet UITableView *userListTableView;
@property (nonatomic, strong)ECUser *signedInUser;
@end

@implementation ECFollowViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.userListTableView.tableFooterView = [UIView new];
    
    if (self.isComeFromProfile){
        if(self.showFollowing){
            [self.navigationItem setTitle:@"Following"];
            [self loadFollowing:self.mSelectedLoginUserId];
        }
        else{
            [self.navigationItem setTitle:@"Followers"];
            [self loadFollowers:self.mSelectedLoginUserId];
        }
    }else{
        if(self.showFollowing){
            [self.navigationItem setTitle:@"Following"];
            [self loadFollowing:_dcUser.userId];
        }
        else{
            [self.navigationItem setTitle:@"Followers"];
            [self loadFollowers:_dcUser.userId];
        }
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ECFollowCell";
    ECFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSError *infoError = nil;
    ECUser *ecUser = [[ECUser alloc] initWithDictionary:[self.usersArray objectAtIndex:indexPath.row] error:&infoError];
    if (!cell) {
        cell = [[ECFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [cell configureWithUser:ecUser];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSError *infoError = nil;
    ECUser *ecUser = [[ECUser alloc] initWithDictionary:[self.usersArray objectAtIndex:indexPath.row] error:&infoError];
    ECIndividualProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECIndividualProfileViewController"];
    vc.isSignedInUser = false;
    vc.selectedEcUser = ecUser;
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
    dcProfileTableViewController.isSignedInUser = false;
    dcProfileTableViewController.profileUser = ecUser;
    [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
    */
}

#pragma mark - API Call Methods

- (void)loadFollowing:(NSString *)userId{
    [[ECAPI sharedManager] getFollowing:userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            [_userListTableView reloadData];
        }
    }];
}

- (void)loadFollowers:(NSString *)userId{
    [[ECAPI sharedManager] getFollowers:userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
        } else {
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            [_userListTableView reloadData];
        }
    }];
}

@end
