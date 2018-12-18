//
//  ECAttendanceResponseTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 9/14/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECAttendanceResponseTableViewCell.h"
#import "NSDate+NVTimeAgo.h"
#import "UIImageView+AFNetworking.h"
#import "ECAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECCommonClass.h"
#import "DCEventEntityObject.h"

@implementation ECAttendanceResponseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.attendanceResponse addTarget:self action:@selector(setUserAttendanceResponse:) forControlEvents:UIControlEventValueChanged];

    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.questionOptions = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"AttendanceQuestionOptions"];
    //@kj_NewChange
    /*
    for(int i = 0; i < [self.questionOptions count]; i++){
        [self.attendanceResponse setTitle:[self.questionOptions objectAtIndex:i] forSegmentAtIndex:i];
    }
     */
    [self getUserAttendanceResponse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithFeedItem:(DCFeedItem *)selectedFeedItem{
    self.selectedFeedItem = selectedFeedItem;
    
    // Get Main Image
    // EdgeTVChat custom code
    NSString *mainImage_Url = nil;
    if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
        if([selectedFeedItem.entityType isEqual:EntityType_DIGITAL]){
            mainImage_Url = selectedFeedItem.digital.imageUrl;
            [self.feedItemTitle setText:[NSString stringWithFormat:@"S%@E%@ - %@", selectedFeedItem.digital.seasonNumber, selectedFeedItem.digital.episodeNumber, selectedFeedItem.digital.episodeTitle]];
            [self.feedItemDetails setText:selectedFeedItem.digital.starring];
        }
        else if ([selectedFeedItem.entityType isEqual:EntityType_EVENT]){
            mainImage_Url = selectedFeedItem.event.mainImage;
            [self.feedItemTitle setText:selectedFeedItem.event.name];
            [self.feedItemDetails setText:[NSString stringWithFormat:@"%@, %@", selectedFeedItem.event.city, selectedFeedItem.event.state]];
        }
        else{
            mainImage_Url = selectedFeedItem.mainImage_url;
            [self.feedItemTitle setText:selectedFeedItem.person.profession.title];
            [self.feedItemDetails setText:selectedFeedItem.person.name];
        }
        
    }
    else{
        mainImage_Url = selectedFeedItem.mainImage_url;
        [self.feedItemTitle setText:selectedFeedItem.title];
        [self.feedItemDetails setText:selectedFeedItem.influencer];
    }
    if( mainImage_Url != nil){
        [self showImageOnTheCell:self ForImageUrl:mainImage_Url];
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    ////////// Add different value instead of time here ////////////////////
//    //The Z at the end of your string represents Zulu which is UTC
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//    
//    //NSDate* newTime = [dateFormatter dateFromString:selectedEvent.start.utc];
//    NSLog(@"original time: %@", newTime);
//    
//    //Add the following line to display the time in the local time zone
//    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    [dateFormatter setDateFormat:@"EEE, MMM d 'at' h:mm a"];
//    NSString* finalTime = [dateFormatter stringFromDate:newTime];
//    NSLog(@"%@", finalTime);
//    
//    [self.eventStartTime setText:finalTime];
}

#pragma mark - API Methods
-(void)setUserAttendanceResponse:(id)sender{
    NSLog(@"Seg: %ld", ((UISegmentedControl *)sender).selectedSegmentIndex);
    NSInteger selectedIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
    NSString *userResponse;
    
    if(selectedIndex == 0){
        userResponse = @"Going";
    }
    else if(selectedIndex == 1){
        userResponse = @"Maybe";
    }
    else{
        userResponse = @"Can't go";
    }
    //@kj_change
//    userResponse = [self.questionOptions objectAtIndex:((UISegmentedControl *)sender).selectedSegmentIndex];
    
    [[ECAPI sharedManager] setAttendeeResponse:self.signedInUser.userId feedItemId:self.selectedFeedItem.feedItemId response:userResponse callback:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
        } else {
            if([self.delegate respondsToSelector:@selector(attendListDidUpdateAttendanceReponse:)]){
                [self.delegate attendListDidUpdateAttendanceReponse:self];
            }
        }
    }];
}

-(void)getUserAttendanceResponse{
    [[ECAPI sharedManager] getAttendeeResponse:self.signedInUser.userId feedItemId:self.selectedFeedItem.feedItemId callback:^(ECAttendee *attendance, NSError *error) {
        if (error) {
            NSLog(@"Error saving response: %@", error);
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
                NSLog(@"REspnse %@", attendance.response);
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
