//
//  ECNewPlaylistTableViewCell.h
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECNewPlaylistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *playlistProfilePhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playlistCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *playlistUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;

@end
