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

@interface ECFollowViewController ()
@property (nonatomic, weak) IBOutlet UITableView *userListTableView;
@property (nonatomic, strong)ECUser *signedInUser;
@end

@implementation ECFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    
    if(self.showFollowing){
        [self.navigationItem setTitle:@"Following"];
        [self loadFollowing];
    }
    else{
        [self.navigationItem setTitle:@"Followers"];
        [self loadFollowers];
    }
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
    dcProfileTableViewController.isSignedInUser = false;
    dcProfileTableViewController.profileUser = ecUser;
    
    [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
}

- (void)loadFollowing{
    [[ECAPI sharedManager] getFollowing:_dcUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            [_userListTableView reloadData];
        }
    }];
}

- (void)loadFollowers{
    [[ECAPI sharedManager] getFollowers:_dcUser.userId callback:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            [_userListTableView reloadData];
        }
    }];
}

@end
