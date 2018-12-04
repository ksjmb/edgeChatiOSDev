#import "ECNotificationCell.h"
#import "NSDate+NVTimeAgo.h"
#import "ECColor.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ECNotificationCell()
@property (nonatomic, strong) IBOutlet UILabel *message;
@property (nonatomic, strong) IBOutlet UILabel *created_at;
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;
@end

@implementation ECNotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithNotification:(ECNotification *)notification{
    NSString *notifierUserName = [NSString stringWithFormat:@"%@ %@", notification.notifierUser.firstName, notification.notifierUser.lastName];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
    NSString *yourString = [NSString stringWithFormat:@"%@ %@", notifierUserName, notification.message];
    NSRange boldedRange = NSMakeRange(0, [notifierUserName length]);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:yourString];
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName
                       value:boldFont
                       range:boldedRange];
    
    [attrString endEditing];
    
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *created_atFromString = [[NSDate alloc] init];
    created_atFromString = [dateFormatter dateFromString:notification.created_at];
    NSString *ago = [created_atFromString formattedAsTimeAgo];
    NSLog(@"Output is: \"%@\"", ago);
    [self.created_at setText:[NSString stringWithFormat:@"%@", ago]];
    
    // Set profile pic
    if([notification.notificationType isEqualToString:@"report"]){
        [self.message setText:notification.message];
        self.profilePic.image = [UIImage imageNamed:@"icon_rdgeTV.png"];
    }
    else{
        // Set profile pic
        if(notification.notifierUser.profilePicUrl != nil){
            [self showImageOnTheCell:notification.notifierUser.profilePicUrl];
        }
        else{
            self.profilePic.image = [UIImage imageNamed:@"missing-profile.png"];
        }
        [self.message setAttributedText:attrString];
    }
    
    [self.contentView addSubview:_profilePic];
    [self.contentView addSubview:_message];
    [self.contentView addSubview:_created_at];
    
    NSDictionary *views = @{@"thumbnailView": self.profilePic,
                            @"bodyLabel": self.message,
                            @"createdAtLabel": self.created_at,
                            };
    
    NSDictionary *metrics = @{@"thumbSize": @(50.0),
                              @"padding": @15,
                              @"right": @10,
                              @"left": @10
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(thumbSize)]-right-[bodyLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(thumbSize)]-right-[createdAtLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(thumbSize)]-right-[createdAtLabel(>=0)]-right-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[thumbnailView(thumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[bodyLabel(>=0)]-5-[createdAtLabel(20)]-5-|" options:0 metrics:metrics views:views]];
    
    if(!notification.acknowledged){
        [self setBackgroundColor:[ECColor colorFromHexString:@"#EBEEF4"]];
    }
}

#pragma mark - Getters
- (UILabel *)message
{
    if (!_message) {
        _message = [UILabel new];
        _message.translatesAutoresizingMaskIntoConstraints = NO;
        _message.backgroundColor = [UIColor clearColor];
        _message.userInteractionEnabled = NO;
        _message.numberOfLines = 0;
        _message.textColor = [UIColor darkGrayColor];
        _message.font = [UIFont systemFontOfSize:[ECNotificationCell defaultFontSize]];
    }
    return _message;
}

+ (CGFloat)defaultFontSize
{
    CGFloat pointSize = 14.0;
    
    return pointSize;
}

#pragma mark - SDWebImage
// Displaying Image on Cell

-(void)showImageOnTheCell:(NSString *)url{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        self.profilePic.image = inMemoryImage;
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        self.profilePic.image = image;
        
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
                                    self.profilePic.image = image;
                                    
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
