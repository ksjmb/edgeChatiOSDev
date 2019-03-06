//
//  ECNewTableViewCell.m
//  EventChat
//
//  Created by Mindbowser on 26/11/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "ECNewTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import "ECColor.h"
#import "ECEvent.h"
#import "DCFeedItem.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSObject+AssociatedObject.h"
#import "IonIcons.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomButton.h"
#import <Crashlytics/Crashlytics.h>
#import "ECCommonClass.h"

@interface ECNewTableViewCell()
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@end

@implementation ECNewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark:- Intance Methods


- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.episodeImageView setImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.nameTitleLabel setText:nil];
    [self.nameDescriptionLabel setText:nil];
    [self.seasonNameLabel setText:nil];
}

#pragma mark:- IBAction Methods

- (IBAction)actionOnPlayEpisodeButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnPlayEpisodeButton: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFeedITemThumbnail:index:)]){
        [self.delegate mainFeedDidTapFeedITemThumbnail:self index:indexPath.row];
    }
}

- (void)didTapFeedItemThumbnail:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"didTapFeedItemThumbnail: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFeedITemThumbnail:index:)]){
        [self.delegate mainFeedDidTapFeedITemThumbnail:self index:indexPath.row];
    }
}

- (IBAction)actionOnCommentButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnCommentButton: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapCommentsButton:index:)]){
        [self.delegate mainFeedDidTapCommentsButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnShareButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnShareButton: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapShareButton:index:)]){
        [self.delegate mainFeedDidTapShareButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnLikeButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnLikeButton: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapAttendanceButton:index:)]){
        [self.delegate mainFeedDidTapAttendanceButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnFavButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnFavButton: %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFavoriteButton:index:)]){
        [self.delegate mainFeedDidTapFavoriteButton:self index:indexPath.row];
    }
}

- (IBAction)actionOnViewMoreButton:(id)sender {
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"actionOnViewMoreButton: %ld", (long)indexPath.row);
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark:- Configure TableViewCell

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending{
    
    self.feedItem = feedItem;
    _playSelectedEpisodeButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
    
    /*
    self.episodeImageView.layer.shadowOffset = CGSizeMake(05, 05);
    self.episodeImageView.layer.shadowRadius = 3.0;
    self.episodeImageView.layer.shadowOpacity = 0.6;
//    self.episodeImageView.layer.masksToBounds = NO;
    */
    
    UITapGestureRecognizer *feedItemThumbnailTapRecognizer = [[UITapGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(didTapFeedItemThumbnail:)];
    [feedItemThumbnailTapRecognizer setNumberOfTouchesRequired:1];
    [feedItemThumbnailTapRecognizer setDelegate:self];
    
    // Set the userInteractionEnabled to YES, by default It's NO.
    self.episodeImageView.userInteractionEnabled = YES;
    [self.episodeImageView addGestureRecognizer:feedItemThumbnailTapRecognizer];
    [self.contentView addGestureRecognizer:feedItemThumbnailTapRecognizer];
    
    // Get Comment Count :-
//    NSLog(@"commentCount : %d", commentCount);
    if(commentCount > 0){
        self.commentButton.enabled = FALSE;
        self.commentButton.enabled = TRUE;
        NSString *mCommentCount = [NSString stringWithFormat:@"%d", commentCount];
        mCommentCount = [mCommentCount stringByAppendingString:@" comments"];
        [self.commentCountLabel setText:mCommentCount];
    }
    else{
        [self.commentCountLabel setText:@"00 comments"];
        self.commentButton.enabled = FALSE;
        //Remove Later
        self.commentButton.enabled = TRUE;
    }
    
    // Get favorited events:-
    if(isFavorited){
        [self.favButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:27.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        UIImage *btnImage = [UIImage imageNamed:@"heart_new"];
        [self.favButton setTintColor:[UIColor darkTextColor]];
        [self.favButton setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(30.0, 30.0)] forState:UIControlStateNormal];
        
//        [self.favButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //Get attending events:-
    if(isAttending){
        UIImage *btnImage = [UIImage imageNamed:@"thumb_blue"];
//        [self.likeButton setTintColor:[UIColor blueColor]];
        [self.likeButton setTintColor:[UIColor colorWithRed:(67/255.0) green:(114/255.0) blue:(199/255.0) alpha:1]];
        [self.likeButton setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(27.0, 27.0)] forState:UIControlStateNormal];
        
//        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        UIImage *btnImage = [UIImage imageNamed:@"thumb_white"];
        [self.likeButton setTintColor:[UIColor darkTextColor]];
        [self.likeButton setImage:[self imageWithImage:btnImage scaledToSize:CGSizeMake(27.0, 27.0)] forState:UIControlStateNormal];
//        [self.likeButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //share button
//    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor darkTextColor]] forState:UIControlStateNormal];
    
    // Get Venue address
    if([feedItem.location.name length] > 0 && [feedItem.location.city length] > 0){
        [self.seasonNameLabel setText:[NSString stringWithFormat:@"%@ - %@, %@", feedItem.location.name, feedItem.location.city, feedItem.location.state]];
    }
    else{
        [self.seasonNameLabel setText:[NSString stringWithFormat:@"%@", feedItem.location.state]];
    }
    
    // Get Main Image
    NSString *mainImage_Url = nil;
    if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
        if([feedItem.entityType isEqual:EntityType_DIGITAL]){
            mainImage_Url = feedItem.digital.imageUrl;
            [self.nameTitleLabel setText:feedItem.digital.series];
            [self.nameDescriptionLabel setText:feedItem.digital.starring];
            [self.seasonNameLabel setText:[NSString stringWithFormat:@"S%@E%@ - %@", feedItem.digital.seasonNumber, feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
            // Show play button for one-off episodes
            if(feedItem.entityType )
//                [self.playSelectedEpisodeButton setBackgroundImage:[IonIcons imageWithIcon:ion_play  size:60.0 color:[UIColor redColor]] forState:UIControlStateNormal];
            if([feedItem.digital.seasonNumber intValue] == 0 && [feedItem.digital.seasonNumber intValue] ==0){
                [_playSelectedEpisodeButton setHidden:NO];
            }
            else{
                [_playSelectedEpisodeButton setHidden:YES];
            }
        }
        else{
            mainImage_Url = feedItem.person.profilePic_url;
            [self.nameTitleLabel setText:feedItem.person.name];
            [self.nameDescriptionLabel setText:feedItem.person.blurb];
            [self.seasonNameLabel setText:feedItem.person.profession.title];
            [_playSelectedEpisodeButton setHidden:YES];
        }
    }
    else{
        mainImage_Url = feedItem.mainImage_url;
        [self.nameTitleLabel setText:feedItem.title];
        [self.nameDescriptionLabel setText:feedItem.influencer];
    }
    if( mainImage_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:mainImage_Url];
    }
    
    int lines = [_nameDescriptionLabel.text sizeWithFont:_nameDescriptionLabel.font
                         constrainedToSize:_nameDescriptionLabel.frame.size
                             lineBreakMode:NSLineBreakByWordWrapping].height/11;
    if (lines > 1){
        [self.viewMoreButton setHidden:NO];
    }else{
        [self.viewMoreButton setHidden:YES];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - AF
- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

#pragma mark - SDWebImage
// Displaying Image on Cell

-(void)showImageOnTheCell:(ECNewTableViewCell *)cell ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.episodeImageView.image = inMemoryImage;
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.episodeImageView.image = image;
        
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
                                    cell.episodeImageView.image = image;
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        return;
                                    }
                                }
                            }];
    }
    
}

@end
