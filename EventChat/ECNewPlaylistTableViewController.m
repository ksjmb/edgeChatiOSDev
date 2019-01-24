//
//  ECNewPlaylistTableViewController.m
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "ECNewPlaylistTableViewController.h"
#import "ECAPI.h"
#import "AppDelegate.h"
#import "DCPlaylist.h"
#import "ECFavoritesViewController.h"
#import "ECNewPlaylistTableViewCell.h"
#import "ECPlaylistDetailsViewController.h"

@interface ECNewPlaylistTableViewController ()
@property (nonatomic, assign) AppDelegate *appDelegate;

@end

@implementation ECNewPlaylistTableViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationItem setTitle:@"Playlists"];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        self.playlistArray = [[NSMutableArray alloc] initWithArray:playlists];
        [self.playlistTableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playlistArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECNewPlaylistTableViewCell";
    DCPlaylist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
    ECNewPlaylistTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ECNewPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.playlistProfilePhotoImageView.layer.cornerRadius = cell.playlistProfilePhotoImageView.frame.size.width / 2;
    cell.playlistProfilePhotoImageView.layer.borderWidth = 5;
    cell.playlistProfilePhotoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.playlistProfilePhotoImageView.layer.masksToBounds = YES;
    
    cell.playlistCoverImageView.layer.cornerRadius = 5.0;
    cell.playlistCoverImageView.layer.masksToBounds = YES;
    cell.playlistCoverImageView.layer.borderWidth = 5;
    cell.playlistCoverImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [cell.playlistTitleLabel setText:playlist.playlistName];
//    [cell.playlistUserNameLabel setText:@""];
//    [cell.playlistProfilePhotoImageView setImage:@""];
//    [cell.playlistCoverImageView setImage:@""];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DCPlaylist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
    if(_isFeedMode){
        [[ECAPI sharedManager] addToPlaylist:playlist.playlistId feedItemId:_feedItemId userId:self.signedInUser.userId callback:^(NSArray *playlists, NSError *error) {
            if(error){
                NSLog(@"Error: %@", error);
            }
            else{
                self.playlistArray = [[NSMutableArray alloc] initWithArray:playlists];
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
            };
        }];
    }else{
        DCPlaylist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
        [[ECAPI sharedManager] getFavoriteFeedItemsByFeedItemId:playlist.favoritedFeedItemIds callback:^(NSArray *favorites, NSError *error) {
            if (error) {
                NSLog(@"Error while getting playlist: %@", error);
            } else {
                /*
                ECFavoritesViewController *ecFavoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECFavoritesViewController"];
                ecFavoritesViewController.isSignedInUser = self.isSignedInUser;
                ecFavoritesViewController.signedInUser = self.signedInUser;
                ecFavoritesViewController.profileUser = self.profileUser;
                ecFavoritesViewController.favoriteList = [[NSMutableArray alloc] initWithArray:favorites];
                ecFavoritesViewController.playlistId = playlist.playlistId;
                ecFavoritesViewController.canShare = playlist.canShare;
                [self.navigationController pushViewController:ecFavoritesViewController animated:YES];
                */
                //
                ECPlaylistDetailsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECPlaylistDetailsViewController"];
                vc.isSignedInUser = self.isSignedInUser;
                vc.mSignedInUser = self.signedInUser;
                vc.mProfileUser = self.profileUser;
                vc.favListArray = [[NSMutableArray alloc] initWithArray:favorites];
                vc.mPlaylistId = playlist.playlistId;
                vc.isCanShare = playlist.canShare;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        DCPlaylist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
        [[ECAPI sharedManager] deletePlaylistById:playlist.playlistId callback:^(NSArray *playlists, NSError *error) {
            if (error) {
                NSLog(@"Error While delete playlist: %@", error);
            } else {
                [self.playlistArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                self.playlistArray = [[NSMutableArray alloc] initWithArray:playlists];
                [self.playlistTableView reloadData];
            }
        }];
    }
}

@end
