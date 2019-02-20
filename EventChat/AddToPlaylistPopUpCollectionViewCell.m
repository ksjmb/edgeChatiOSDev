//
//  AddToPlaylistPopUpCollectionViewCell.m
//  EventChat
//
//  Created by Mindbowser on 21/01/19.
//  Copyright © 2019 Jigish Belani. All rights reserved.
//

#import "AddToPlaylistPopUpCollectionViewCell.h"

@implementation AddToPlaylistPopUpCollectionViewCell


-(void)prepareForReuse{
    [super prepareForReuse];
    [self.playlistNameLabel setText:nil];
    [self.playlistImageView setImage:[UIImage imageNamed:@"placeholder.png"]];
    //lookup.png
}

@end
