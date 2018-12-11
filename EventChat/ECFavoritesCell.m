//
//  ECFavoritesCell.m
//  EventChat
//
//  Created by Jigish Belani on 11/7/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECFavoritesCell.h"
#import "NSDate+NVTimeAgo.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECCommonClass.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"
#import "DCEventEntityObject.h"

@interface ECFavoritesCell()
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@end

@implementation ECFavoritesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.attendanceResponse addTarget:self action:@selector(setUserAttendanceResponse:) forControlEvents:UIControlEventValueChanged];
    
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self.commentsButton addTarget:self action:@selector(didTapCommentsButton:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *eventGetDetailsTapRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didTapGetEventDetails:)];
    [eventGetDetailsTapRecognizer setNumberOfTouchesRequired:1];
    [eventGetDetailsTapRecognizer setDelegate:self];
    self.feedItemThumbnail.userInteractionEnabled = YES;
    self.feedItemTitle.userInteractionEnabled = YES;
    [self.feedItemTitle addGestureRecognizer:eventGetDetailsTapRecognizer];
    [self.feedItemThumbnail addGestureRecognizer:eventGetDetailsTapRecognizer];
    
    self.questionOptions = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"AttendanceQuestionOptions"];
    
    for(int i = 0; i < [self.questionOptions count]; i++){
        [self.attendanceResponse setTitle:[self.questionOptions objectAtIndex:i] forSegmentAtIndex:i];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureWithFeedItem:(DCFeedItem *)favoriteFeedItem commentCount:(int)commentCount{
    if(!self.isSignedInUser){
        [self.attendanceResponse setEnabled:NO];
    }
    self.favoriteFeedItem = favoriteFeedItem;
    [self getUserAttendanceResponse];
    // Get Main Image
    // EdgeTVChat custom code
    NSString *mainImage_Url = nil;
    if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
        if([favoriteFeedItem.entityType isEqual:EntityType_DIGITAL]){
            mainImage_Url = favoriteFeedItem.digital.imageUrl;
            [self.feedItemTitle setText:[NSString stringWithFormat:@"S%@E%@ - %@", favoriteFeedItem.digital.seasonNumber, favoriteFeedItem.digital.episodeNumber, favoriteFeedItem.digital.episodeTitle]];
            [self.feedItemDetails setText:favoriteFeedItem.digital.starring];
        }
        else if ([favoriteFeedItem.entityType isEqual:EntityType_EVENT]){
            mainImage_Url = favoriteFeedItem.event.mainImage;
            [self.feedItemTitle setText:favoriteFeedItem.event.name];
            [self.feedItemDetails setText:[NSString stringWithFormat:@"%@, %@", favoriteFeedItem.event.city, favoriteFeedItem.event.state]];
        }
        else{
            mainImage_Url = favoriteFeedItem.mainImage_url;
            [self.feedItemTitle setText:favoriteFeedItem.person.profession.title];
            [self.feedItemDetails setText:favoriteFeedItem.person.name];
        }
    }
    else{
        mainImage_Url = favoriteFeedItem.mainImage_url;
        [self.feedItemTitle setText:favoriteFeedItem.title];
        [self.feedItemDetails setText:favoriteFeedItem.influencer];
    }
    if( mainImage_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:mainImage_Url];
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    ////////// Add different value instead of time here ////////////////////
    //The Z at the end of your string represents Zulu which is UTC
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//    
//    NSDate* newTime = [dateFormatter dateFromString:favoriteEvent.start.utc];
//    NSLog(@"original time: %@", newTime);
//    
//    //Add the following line to display the time in the local time zone
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"EEE, MMM d 'at' h:mm a"];
//    NSString* finalTime = [dateFormatter stringFromDate:newTime];
//    NSLog(@"%@", finalTime);
//    
//    [self.eventStartTime setText:finalTime];
    
    //Get ECEvent Comment Count
    if(commentCount > 0){
        UIImage *image = [UIImage imageNamed:@"ECComment_On.png"];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
        self.commentsButton.enabled = FALSE;
        [self.commentsButton setTitle:[NSString stringWithFormat:@"%d", commentCount] forState:UIControlStateNormal];
        self.commentsButton.enabled = TRUE;
    }
    else{
        UIImage *image = [UIImage imageNamed:@"ECComment_Off.png"];
        [self.commentsButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
        [self.commentsButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    [self.commentsButton setNeedsLayout];
}

#pragma mark - API Methods
-(void)setUserAttendanceResponse:(id)sender{
    NSLog(@"Seg: %ld", ((UISegmentedControl *)sender).selectedSegmentIndex);
    NSInteger selectedIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
    NSString *userResponse;
    //    if(selectedIndex == 0){
    //        userResponse = [self.questionOptions objectAtIndex:0];
    //    }
    //    else if(selectedIndex == 1){
    //        userResponse = @"maybe";
    //    }
    //    else{
    //        userResponse = @"no";
    //    }
    userResponse = [self.questionOptions objectAtIndex:((UISegmentedControl *)sender).selectedSegmentIndex];
    [[ECAPI sharedManager] setAttendeeResponse:self.signedInUser.userId feedItemId:self.favoriteFeedItem.feedItemId response:userResponse callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
        }
    }];
}

-(void)getUserAttendanceResponse{
    [[ECAPI sharedManager] getAttendeeResponse:self.signedInUser.userId feedItemId:self.favoriteFeedItem.feedItemId callback:^(ECAttendee *attendance, NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
            NSLog(@"%@", error);
        } else {
            // code
//            if([attendances count] > 0){
//                ECAttendee *attendance = [attendances objectAtIndex:0];
//                if([attendance.response isEqual:@"yes"]){
//                    self.attendanceResponse.selectedSegmentIndex = 0;
//                }
//                else if([attendance.response isEqual:@"maybe"]){
//                    self.attendanceResponse.selectedSegmentIndex = 1;
//                }
//                else{
//                    self.attendanceResponse.selectedSegmentIndex = 2;
//                }
//            }
            for (int i = 0; i < [self.attendanceResponse numberOfSegments]; i++)
            {
                if ([[self.attendanceResponse titleForSegmentAtIndex:i] isEqualToString:attendance.response])
                {
                    [self.attendanceResponse setSelectedSegmentIndex:i];
                    break;
                }
                //else {Do Nothing - these are not the droi, err, segment we are looking for}
            }
        }
    }];
}

#pragma mark - ECFavoritesCall Delegate Methods
- (void)didTapCommentsButton:(id)sender{
    if([self.delegate respondsToSelector:@selector(favoritesDidTapCommentsButton:)]){
        [self.delegate favoritesDidTapCommentsButton:self];
    }
}

- (void)didTapGetEventDetails:(id)sender{
    if([self.delegate respondsToSelector:@selector(favoritesDidTapGetEventDetails:)]){
        [self.delegate favoritesDidTapGetEventDetails:self];
    }
}

#pragma mark - SDWebImage
// Displaying Image on Cell

-(void)showImageOnTheCell:self ForImageUrl:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        _feedItemThumbnail.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        _feedItemThumbnail.image = image;
        
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
                                    _feedItemThumbnail.image = image;
                                    
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
