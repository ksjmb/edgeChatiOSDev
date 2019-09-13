//
//  DCPlaylistsTableViewController.m
//  EventChat
//
//  Created by Jigish Belani on 11/8/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "DCPlaylistsTableViewController.h"
#import "ECAPI.h"
#import "AppDelegate.h"
#import "DCPlaylist.h"
#import "ECFavoritesViewController.h"
#import "NSMutableAttributedString+Color.h"

@interface DCPlaylistsTableViewController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *playlists;
@property (nonatomic, strong) IBOutlet UITableView *playlistTableView;
- (IBAction)refresh:(UIRefreshControl *)sender;
@end

@implementation DCPlaylistsTableViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     //Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
     //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    */
    
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController.navigationItem setTitle:@"Playlists"];
    
    if(!_isFeedMode){
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    NSString *userId;
    if(self.isSignedInUser){
        userId = self.signedInUser.userId;
    }
    else{
        userId = self.profileUser.userId;
    }
    [[ECAPI sharedManager] getPlaylistsByUserId:userId callback:^(NSArray *playlists, NSError *error) {
        self.playlists = [[NSMutableArray alloc] initWithArray:playlists];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaylistCell";
    DCPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    NSLog(@"Playlist: %@", [self.playlists objectAtIndex:indexPath.row]);
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [cell.textLabel setText:playlist.playlistName];
    UIColor *normalColor = [UIColor blackColor];
    UIColor *highlightColor = [UIColor redColor];
    UIFont *font = [UIFont systemFontOfSize:12.0];
    NSDictionary *normalAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:normalColor};
    NSDictionary *highlightAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:highlightColor};
    
    NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu items", (unsigned long)[playlist.favoritedFeedItemIds count]] attributes:normalAttributes];
    NSAttributedString *highlightedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" Shared by %@", playlist.sharedByUser.firstName] attributes:highlightAttributes];
    
    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:normalText];
    
    if(playlist.sharedByUser != nil){
        [finalAttributedString appendAttributedString:highlightedText];
    }
    [cell.detailTextLabel setAttributedText:finalAttributedString];
    if(_isFeedMode){
        cell.accessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(self.isSignedInUser){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_isFeedMode){
        /*
         DCPlaylist *playlist = [_playlists objectAtIndex:indexPath.row];
         
         [[ECAPI sharedManager] addToPlaylist:playlist.playlistId feedItemId:_feedItemId userId:self.signedInUser.userId callback:^(NSArray *playlists, NSError *error) {
         if(error){
         NSLog(@"Error: %@", error);
         }
         else{
         _playlists = [[NSMutableArray alloc] initWithArray:playlists];
         //Update user profile API call
         [[ECAPI sharedManager] updateProfilePicUrl:self.signedInUser.userId profilePicUrl:self.signedInUser.profilePicUrl callback:^(NSError *error) {
         if (error) {
         NSLog(@"Error adding user: %@", error);
         } else {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdated" object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"profileUpdatedNew" object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"updateEventTV" object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatReaction" object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTableView" object:nil];
         [self dismissViewControllerAnimated:YES completion:nil];
         }
         }];
         //                [self dismissViewControllerAnimated:YES completion:nil];
         };
         }];
         */
    }else{
        DCPlaylist *playlist = [_playlists objectAtIndex:indexPath.row];
        [[ECAPI sharedManager] getFavoriteFeedItemsByFeedItemId:playlist.favoritedFeedItemIds callback:^(NSArray *favorites, NSError *error) {
            if (error) {
                NSLog(@"Error saving response: %@", error);
            } else {
                // code
                ECFavoritesViewController *ecFavoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFavoritesViewController"];
                ecFavoritesViewController.isSignedInUser = self.isSignedInUser;
                ecFavoritesViewController.signedInUser = self.signedInUser;
                ecFavoritesViewController.profileUser = self.profileUser;
                ecFavoritesViewController.favoriteList = [[NSMutableArray alloc] initWithArray:favorites];
                ecFavoritesViewController.playlistId = playlist.playlistId;
                ecFavoritesViewController.canShare = playlist.canShare;
                [self.navigationController pushViewController:ecFavoritesViewController animated:YES];
            }
        }];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        DCPlaylist *playlist = [_playlists objectAtIndex:indexPath.row];
        [[ECAPI sharedManager] deletePlaylistById:playlist.playlistId callback:^(NSArray *playlists, NSError *error) {
            if (error) {
                NSLog(@"Error adding user: %@", error);
            } else {
                [self.playlists removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                self.playlists = [[NSMutableArray alloc] initWithArray:playlists];
                [self.tableView reloadData];
            }
        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - IBActions Methods

- (IBAction)didTapCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapAddPlaylist:(id)sender{
    DCPlaylist *newPlaylist = [DCPlaylist alloc];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"New Playlist" message:@"Enter a name for the playlist" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        [textField becomeFirstResponder];
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray * tfArray = alert.textFields;
        UITextField * tf = [tfArray objectAtIndex:0];
        newPlaylist.playlistName = tf.text;
        if([tf.text length] > 0){
            /*
            [[ECAPI sharedManager] createPlaylist:self.signedInUser.userId playlistName:newPlaylist.playlistName callback:^(DCPlaylist *playlist, NSError *error) {
                if(error){
                    NSLog(@"Error: %@", error);
                }
                else{
                    [self.playlists insertObject:playlist atIndex:0];
                    [_playlistTableView reloadData];
                }
            }];
             */
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:@"Please enter a Name for the new playlist."
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:NO completion:nil];
}

- (IBAction)refresh:(UIRefreshControl *)sender {
    [[ECAPI sharedManager] getPlaylistsByUserId:self.signedInUser.userId callback:^(NSArray *playlists, NSError *error) {
        self.playlists = [[NSMutableArray alloc] initWithArray:playlists];
        [self.playlistTableView reloadData];
        [sender endRefreshing];
    }];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

@end
