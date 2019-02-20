//
//  ECNewPlaylistTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCFeedItem.h"
#import "DCPlaylist.h"

@class DCFeedItem;
@class DCPlaylist;

@interface ECNewPlaylistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playlistProfilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playlistCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *playlistUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;

- (void)configureTableViewCellWithItem:(DCPlaylist *)playlistItem indexPath:(NSIndexPath*)indexPath;

@end
