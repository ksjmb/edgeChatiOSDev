//
//  DCUserListTableViewController.m
//  EventChat
//
//  Created by Jigish Belani on 2/1/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCUserListTableViewController.h"
#import "ECAPI.h"
#import "ECUser.h"
#import "ECUserListCell.h"
#import "DCProfileTableViewController.h"

@interface DCUserListTableViewController ()
@property (nonatomic, strong) NSArray *usersArray;
@end

@implementation DCUserListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    static NSString *cellIdentifier = @"ECUserListCell";
    ECUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSError *infoError = nil;
    ECUser *ecUser = [[ECUser alloc] initWithDictionary:[self.usersArray objectAtIndex:indexPath.row] error:&infoError];
    if (cell == nil) {
        cell = [[ECUserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - API calls
- (void)loadUsers{
    [[ECAPI sharedManager] getAllUsers:^(NSArray *users, NSError *error) {
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
            NSLog(@"%@", users);
            self.usersArray = [[NSArray alloc] initWithArray:users];
            NSLog(@"%d", (int)[self.usersArray count]);
            [self.tableView reloadData];
        }
    }];
}

@end
