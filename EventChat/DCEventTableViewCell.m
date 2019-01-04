//
//  DCEventTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 2/25/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCEventTableViewCell.h"
#import "ECCommonClass.h"
#import "ECColor.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"
#import "IonIcons.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DCFeedItem.h"
#import "DCEventEntityObject.h"
#import "ECUser.h"

@implementation DCEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    /*
    _shareButton.layer.cornerRadius = _shareButton.frame.size.width /2;
    _shareButton.layer.masksToBounds = YES;
    _shareButton.layer.borderWidth = 0.5;
    _shareButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_shareButton setImage:[IonIcons imageWithIcon:ion_ios_upload_outline size:25.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    _likeButton.layer.cornerRadius = _likeButton.frame.size.width /2;
    _likeButton.layer.masksToBounds = YES;
    _likeButton.layer.borderWidth = 0.5;
    _likeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup size:25.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    _commentButton.layer.cornerRadius = _commentButton.frame.size.width /2;
    _commentButton.layer.masksToBounds = YES;
    _commentButton.layer.borderWidth = 0.5;
    _commentButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_commentButton setImage:[IonIcons imageWithIcon:ion_ios_chatboxes_outline size:25.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    _favoriteButton.layer.cornerRadius = _favoriteButton.frame.size.width /2;
    _favoriteButton.layer.masksToBounds = YES;
    _favoriteButton.layer.borderWidth = 0.5;
    _favoriteButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_favoriteButton setImage:[IonIcons imageWithIcon:ion_heart size:25.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    */
    
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 1.0;
    self.container.layer.shadowOffset = CGSizeMake(0, 0);
    self.container.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.feedItemThumbnail.layer.masksToBounds = YES;
}

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending{
    self.feedItem = feedItem;
    
//    [_feedItemTitle setTextAlignment:NSTextAlignmentJustified];
    [_feedItemTitle setText:feedItem.event.name];
    [_feedItemBottomSubText setText:[NSString stringWithFormat:@"%@, %@", feedItem.event.city, feedItem.event.state]];
    
    if(commentCount > 0){
        self.commentButton.enabled = FALSE;
        self.commentButton.enabled = TRUE;
        NSString *mCommentCount = [NSString stringWithFormat:@"%d", commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.eventCommentCount setText:mCommentCount];
    }
    else{
        [self.eventCommentCount setText:@"00 comments"];
        self.commentButton.enabled = FALSE;
        //Remove Later
        self.commentButton.enabled = TRUE;
    }
    
    // Get favorited events:-
    if(isFavorited){
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //Get attending events:-
    if(isAttending){
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //share button
//    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *eventDate = [dateFormatter dateFromString:feedItem.event.startDate];
    [dateFormatter setDateFormat:@"MMM"];
    NSLog(@"month is %@", [[dateFormatter stringFromDate:eventDate] uppercaseString]);
    [self.eventMonthNameLabel setText:[[dateFormatter stringFromDate:eventDate] uppercaseString]];
    [dateFormatter setDateFormat:@"dd"];
    NSLog(@"date is %@", [[dateFormatter stringFromDate:eventDate] uppercaseString]);
    [self.eventMonthDayLabel setText:[[dateFormatter stringFromDate:eventDate] uppercaseString]];
    
    if(feedItem.event.mainImage != nil){
        [self showImageOnTheCell:self ForImageUrl:feedItem.event.mainImage isFromDownloadButton:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - SDWebImage

// Displaying Image on Cell
-(void)showImageOnTheCell:(DCEventTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.feedItemThumbnail.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.feedItemThumbnail.image = image;
        
    }else{
        NSURL *urL = [NSURL URLWithString:url];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager.imageDownloader setDownloadTimeout:20];
        [manager downloadImageWithURL:urL
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    cell.feedItemThumbnail.image = image;
                                    cell.feedItemThumbnail.layer.borderWidth = 1.0;
                                    cell.feedItemThumbnail.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        if (downloadFlag) {
                                            //cell.downloadButton.hidden = NO;
                                        }
                                        return;
                                    }
                                    
                                }
                            }];
    }
}

#pragma mark - Button actions

- (IBAction)didTapThumbnail:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(eventFeedDidTapFeedITemThumbnail:index:)]){
        [self.delegate eventFeedDidTapFeedITemThumbnail:self index:indexPath.row];
    }
}

- (IBAction)didTapShareButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(eventFeedDidTapShareButton:index:)]){
        [self.delegate eventFeedDidTapShareButton:self index:indexPath.row];
    }
}

- (IBAction)didTapAttendanceButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(eventFeedDidTapAttendanceButton:index:)]){
        [self.delegate eventFeedDidTapAttendanceButton:self index:indexPath.row];
    }
}

- (IBAction)didTapCommentButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(eventFeedDidTapCommentsButton:index:)]){
        [self.delegate eventFeedDidTapCommentsButton:self index:indexPath.row];
    }
}

- (IBAction)didTapFavoritesButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(eventFeedDidTapFavoriteButton:index:)]){
        [self.delegate eventFeedDidTapFavoriteButton:self index:indexPath.row];
    }
}
@end
