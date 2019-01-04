//
//  ECFeedCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/31/16.
//  Copyright © 2016 Apex Ventures, LLC. All rights reserved.
//

#import "ECFeedCell.h"
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

@interface ECFeedCell()
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *attendanceButton;
@property (nonatomic, strong) CustomButton *shareButton;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UIButton *playSelectedEpisodeButton;
//@property (nonatomic, strong) DCFeedItem *feedItem;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@end

@implementation ECFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.container.layer.shadowOpacity = 1;
    self.container.layer.shadowRadius = 1.0;
    self.container.layer.shadowOffset = CGSizeMake(0, 0);
    self.container.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.feedItemThumbnail.layer.masksToBounds = YES;
    
    [self.commentsButton setTintColor:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    //self.eventTitle.text = @"";
    //self.eventThumbnail.image = nil;
    [self.feedItemThumbnail setImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.feedItemTopSubText setText:nil];
    [self.feedItemTitle setText:nil];
    [self.feedItemBottomSubText setText:nil];
    [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"ECComment_Off.png"] forState:UIControlStateNormal];
     [self.commentsButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
} 

- (void)configureWithFeedItem:(DCFeedItem *)feedItem ecUser:(ECUser *)ecUser cellIndex:(NSIndexPath *)indexPath commentCount:(int)commentCount isFavorited:(BOOL)isFavorited isAttending:(BOOL)isAttending{
    int selRow = (int)indexPath.row;
    self.feedItem = feedItem;
    
    // for tranding label:-
    if(selRow < 2){
        [self.sponseredEvent setHidden:NO];
        //[self.container setBackgroundColor:[ECColor sponseredColor]];
    }
    else{
        [self.sponseredEvent setHidden:YES];
        [self.container setBackgroundColor:[UIColor whiteColor]];
    }
    
    // Use formatter if TopSubText is dateTime format
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    
//    //The Z at the end of your string represents Zulu which is UTC
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//    
//    NSDate* newTime = [dateFormatter dateFromString:feedItem.time.duration];
//    NSLog(@"original time: %@", newTime);
//    
//    //Add the following line to display the time in the local time zone
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"EEE, MMM d 'at' h:mm a"];
//    NSString* finalTime = [dateFormatter stringFromDate:newTime];
//    NSLog(@"%@", finalTime);
    //NSLog(@"%@: ", feedItem.digital.series);
//    [self.feedItemTopSubText setText:[NSString stringWithFormat:@"%@ - S%@ E%@ - %@", feedItem.digital.series, feedItem.digital.season, feedItem.digital.episode, feedItem.time.duration]];
    UITapGestureRecognizer *feedItemThumbnailTapRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didTapFeedItemThumbnail:)];
    [feedItemThumbnailTapRecognizer setNumberOfTouchesRequired:1];
    [feedItemThumbnailTapRecognizer setDelegate:self];
    // Set the userInteractionEnabled to YES, by default It's NO.
    self.feedItemThumbnail.userInteractionEnabled = YES;
    [self.feedItemThumbnail addGestureRecognizer:feedItemThumbnailTapRecognizer];
    [self.container addGestureRecognizer:feedItemThumbnailTapRecognizer];
    [self.commentsButton addTarget:self action:@selector(didTapCommentsButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.favoriteButton addTarget:self action:@selector(didTapFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.attendanceButton addTarget:self action:@selector(didTapAttendanceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(didTapShareButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Updated code block
    //Get ECEvent Comment Count
    self.commentsButton.titleLabel.textColor = [UIColor blackColor];
    if(commentCount > 0){
        UIImage *image = [UIImage imageNamed:@"ECComment_On.png"];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
        self.commentsButton.enabled = FALSE;
        [self.commentsButton setTitle:[NSString stringWithFormat:@"%d", commentCount] forState:UIControlStateNormal];
        self.commentsButton.enabled = TRUE;
    }
    else{
        UIImage *image = [UIImage imageNamed:@"ECComment_Off.png"];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    [self.commentsButton setNeedsLayout];
    
    // Get ECUser favorited events
    if(isFavorited){
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor redColor]] forState:UIControlStateNormal];
    }
    else{
        [self.favoriteButton setImage:[IonIcons imageWithIcon:ion_ios_heart  size:30.0 color:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    //Get ECUser attending events
    if(isAttending){
        [self.attendanceButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    }
    else{
        [self.attendanceButton setImage:[IonIcons imageWithIcon:ion_thumbsup  size:30.0 color:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    
    //Set share button
//    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[ECColor colorFromHexString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"mainThemeColorHex"]]] forState:UIControlStateNormal];
    [self.shareButton setImage:[IonIcons imageWithIcon:ion_share  size:30.0 color:[UIColor blackColor]] forState:UIControlStateNormal];
    
    // Get Venue address
    if([feedItem.location.name length] > 0 && [feedItem.location.city length] > 0){
        [self.feedItemBottomSubText setText:[NSString stringWithFormat:@"%@ - %@, %@", feedItem.location.name, feedItem.location.city, feedItem.location.state]];
    }
    else{
        [self.feedItemBottomSubText setText:[NSString stringWithFormat:@"%@", feedItem.location.state]];
    }
    
    // Get Main Image
    // EdgeTVChat custom code
    NSString *mainImage_Url = nil;
    if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
        if([feedItem.entityType isEqual:EntityType_DIGITAL]){
            mainImage_Url = feedItem.digital.imageUrl;
            [self.feedItemTitle setText:feedItem.digital.series];
            [self.feedItemTopSubText setText:feedItem.digital.starring];
            [self.feedItemBottomSubText setText:[NSString stringWithFormat:@"S%@E%@ - %@", feedItem.digital.seasonNumber, feedItem.digital.episodeNumber, feedItem.digital.episodeTitle]];
            // Show play button for one-off episodes
            if(feedItem.entityType )
                [self.playSelectedEpisodeButton setBackgroundImage:[IonIcons imageWithIcon:ion_play  size:60.0 color:[UIColor redColor]] forState:UIControlStateNormal];
            if([feedItem.digital.seasonNumber intValue] == 0 && [feedItem.digital.seasonNumber intValue] ==0){
                [_playSelectedEpisodeButton setHidden:NO];
            }else{
                [_playSelectedEpisodeButton setHidden:YES];
            }
        }
        else{
            mainImage_Url = feedItem.person.profilePic_url;
            [self.feedItemTitle setText:feedItem.person.name];
            [self.feedItemTopSubText setText:feedItem.person.blurb];
            [self.feedItemBottomSubText setText:feedItem.person.profession.title];
            [_playSelectedEpisodeButton setHidden:YES];
        }
        
        
    }
    else{
        mainImage_Url = feedItem.mainImage_url;
        [self.feedItemTitle setText:feedItem.title];
        [self.feedItemTopSubText setText:feedItem.influencer];
    }
    if( mainImage_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:mainImage_Url];
    }
    
    
    NSLayoutConstraint *favoriteButtonWidth = [NSLayoutConstraint constraintWithItem:self.favoriteButton attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:50];
    
    NSLayoutConstraint *favoriteButtonHeight = [NSLayoutConstraint constraintWithItem:self.favoriteButton
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:50];
    
    NSLayoutConstraint *commentButtonWidth = [NSLayoutConstraint constraintWithItem:self.commentsButton attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1
                                                                           constant:50];
    
    NSLayoutConstraint *commentButtonHeight = [NSLayoutConstraint constraintWithItem:self.commentsButton
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:50];
    
    NSLayoutConstraint *attendanceButtonWidth = [NSLayoutConstraint constraintWithItem:self.attendanceButton attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1
                                                                              constant:50];
    
    NSLayoutConstraint *attendanceButtonHeight = [NSLayoutConstraint constraintWithItem:self.attendanceButton
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1
                                                                                constant:50];
    
    NSLayoutConstraint *shareButtonWidth = [NSLayoutConstraint constraintWithItem:self.shareButton attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1
                                                                              constant:50];
    
    NSLayoutConstraint *shareeButtonHeight = [NSLayoutConstraint constraintWithItem:self.shareButton
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1
                                                                                constant:50];
    
    [NSLayoutConstraint activateConstraints:@[favoriteButtonWidth, favoriteButtonHeight, commentButtonWidth, commentButtonHeight, attendanceButtonWidth, attendanceButtonHeight, shareButtonWidth, shareeButtonHeight]];
    [self.contentView addSubview:self.favoriteButton];
    [self.contentView addSubview:self.commentsButton];
    [self.contentView addSubview:self.attendanceButton];
    [self.contentView addSubview:self.shareButton];
    
    NSDictionary *views = @{@"favoriteButton": self.favoriteButton,
                            @"attendanceButton": self.attendanceButton,
                            @"commentsButton": self.commentsButton,
                            @"shareButton": self.shareButton,
                            };
    
    NSDictionary *metrics = @{@"thumbSize": @(50.0),
                              @"padding": @15,
                              @"right": @10,
                              @"left": @10
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareButton(50)]-[attendanceButton(50)]-[commentsButton(50)]-[favoriteButton(50)]-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[favoriteButton(50)]-2-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[attendanceButton(50)]-2-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[commentsButton(50)]-2-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[shareButton(50)]-2-|" options:0 metrics:metrics views:views]];
}

- (void)getEventVenueAddress{
    
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

#pragma mark - ECFeedCellDelegate Methods

- (IBAction)didTapPlayButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFeedITemThumbnail:index:)]){
        [self.delegate mainFeedDidTapFeedITemThumbnail:self index:indexPath.row];
    }
}
- (void)didTapFeedItemThumbnail:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFeedITemThumbnail:index:)]){
        [self.delegate mainFeedDidTapFeedITemThumbnail:self index:indexPath.row];
    }
}

- (void)didTapCommentsButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapCommentsButton:index:)]){
        [self.delegate mainFeedDidTapCommentsButton:self index:indexPath.row];
    }
}

-(void)didTapFavoriteButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapFavoriteButton:index:)]){
        [self.delegate mainFeedDidTapFavoriteButton:self index:indexPath.row];
    }
}

- (void)didTapAttendanceButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapAttendanceButton:index:)]){
        [self.delegate mainFeedDidTapAttendanceButton:self index:indexPath.row];
    }
}

- (void)didTapShareButton:(id)sender{
    NSIndexPath *indexPath = [(UITableView *)self.superview indexPathForCell:self];
    NSLog(@"rowofthecell %ld", (long)indexPath.row);
    
    if([self.delegate respondsToSelector:@selector(mainFeedDidTapShareButton:index:)]){
        [self.delegate mainFeedDidTapShareButton:self index:indexPath.row];
    }
}

-(UIButton *)favoriteButton{
    if (!_favoriteButton) {
        _favoriteButton = [UIButton new];
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
        _favoriteButton.backgroundColor = [UIColor clearColor];
        [_favoriteButton addTarget:self
                            action:@selector(didTapFavoriteButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _favoriteButton;
}

-(UIButton *)commentsButton{
    if (!_commentsButton) {
        _commentsButton = [UIButton new];
        _commentsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _commentsButton.backgroundColor = [UIColor clearColor];
        [_commentsButton setTitleColor:[self colorFromHexString:@"#555555"] forState:UIControlStateNormal];
        [_commentsButton setTitleEdgeInsets:UIEdgeInsetsMake(25.0, 0.0, 0.0, 0.0)];
        _commentsButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [_commentsButton addTarget:self
                            action:@selector(didTapCommentsButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _commentsButton;
}

-(UIButton *)attendanceButton{
    if (!_attendanceButton) {
        _attendanceButton = [UIButton new];
        _attendanceButton.translatesAutoresizingMaskIntoConstraints = NO;
        _attendanceButton.backgroundColor = [UIColor clearColor];
        [_attendanceButton addTarget:self
                            action:@selector(didTapAttendanceButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _attendanceButton;
}

-(UIButton *)shareButton{
    if (!_shareButton) {
        _shareButton = [CustomButton new];
        _shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        _shareButton.backgroundColor = [UIColor clearColor];
        [_shareButton addTarget:self
                              action:@selector(didTapShareButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _shareButton;
}

// Assumes input like "#00FF00" (#RRGGBB).
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - SDWebImage
// Displaying Image on Cell

-(void)showImageOnTheCell:(ECFeedCell *)cell ForImageUrl:(NSString *)url{
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
