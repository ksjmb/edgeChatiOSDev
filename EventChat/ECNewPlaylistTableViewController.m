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
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+AFNetworking.h"

@interface ECNewPlaylistTableViewController ()
@property (nonatomic, assign) AppDelegate *appDelegate;

@end

@implementation ECNewPlaylistTableViewController

#pragma mark - ViewController LifeCycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *userId;
    if(self.isSignedInUser){
        userId = self.signedInUser.userId;
    }else{
        userId = self.profileUser.userId;
    }
    
    [[ECAPI sharedManager] getPlaylistsByUserId:userId callback:^(NSArray *playlists, NSError *error) {
        self.playlistArray = [[NSMutableArray alloc] initWithArray:playlists];
        [self.playlistTableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setTitle:@"Playlists"];
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
    ECNewPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ECNewPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell configureTableViewCellWithItem:playlist indexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DCPlaylist *playlist = [self.playlistArray objectAtIndex:indexPath.row];
    [[ECAPI sharedManager] getFavoriteFeedItemsByFeedItemId:playlist.favoritedFeedItemIds callback:^(NSArray *favorites, NSError *error) {
        if (error) {
            NSLog(@"Error while getting playlist: %@", error);
        } else {
            ECPlaylistDetailsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ECPlaylistDetailsViewController"];
            vc.isSignedInUser = self.isSignedInUser;
            vc.mSignedInUser = self.signedInUser;
            vc.mProfileUser = self.profileUser;
            vc.favListArray = [[NSMutableArray alloc] initWithArray:favorites];
            vc.mPlaylistId = playlist.playlistId;
            vc.isCanShare = playlist.canShare;
            vc.mPlaylistName = playlist.playlistName;
            vc.mProfileImageURL = playlist.thumbnailImageUrl;
            vc.mCoverImageURL = playlist.coverImageUrl;
            //                vc.mProfileName = playlist;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
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
