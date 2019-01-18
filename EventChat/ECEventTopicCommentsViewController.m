#import "ECEventTopicCommentsViewController.h"
#import "MessageTableViewCell.h"
#import "MessageTextView.h"
#import "TypingIndicatorView.h"
#import "Message.h"
#import <LoremIpsum/LoremIpsum.h>
#import "ECAPI.h"
#import "ECUser.h"
#import "ECComment.h"
#import "NSDate+NVTimeAgo.h"
#import "MessageTableViewCell.h"
#import "ECCommonClass.h"
#import "ECSharedmedia.h"
#import "S3UploadImage.h"
#import "SVProgressHUD.h"
#import "S3UploadVideo.h"
#import "S3Constants.h"
#import "ECFullScreenImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECVideoData.h"
#import "Reachability.h"
#import "ECAPINames.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "IonIcons.h"
#import "DCPersonEntityObject.h"
#import "DCPersonProfessionObject.h"
#import "DCPost.h"
#import "DCEventEntityObject.h"

#define DEBUG_CUSTOM_TYPING_INDICATOR 0

@interface ECEventTopicCommentsViewController ()
{
    Reachability *reachabilityInfo;
    ECVideoData *videoData;
    NSMutableArray *array;
    BOOL isChild;
    NSDate *created_atFromString;
    NSDateFormatter *dateFormatter;
}


@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) NSArray *commands;
@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic, strong) UIWindow *pipWindow;
@property (nonatomic, weak) Message *editingMessage;
@property (nonatomic, strong)ECUser *signedInUser;
@property (strong, nonatomic) ECFullScreenImageViewController *fullScreenImageViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeBarButtonItem;
@property (retain, nonatomic) UIImage *alertImage;
@property (retain, nonatomic) NSString *alertTitle;
@property (retain, nonatomic) NSArray *arrayOfButtonTitles;
//
@property int viewCount;
@property (nonatomic, strong)NSMutableDictionary *viewReplyDict;
@property (nonatomic, assign) BOOL isParentIdPresent;
@end

@implementation ECEventTopicCommentsViewController
- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    } 
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:UIContentSizeCategoryDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputbarDidMove:) name:SLKTextInputbarDidMoveNotification object:nil];
    
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    [self registerClassForTextView:[MessageTextView class]];
    
#if DEBUG_CUSTOM_TYPING_INDICATOR
    // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
#endif
    
    // Format date
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get logged in user

    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    [self configureDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewReplyNewTap) name:@"viewReplyNewTap" object:nil];
    
    self.closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[IonIcons imageWithIcon:ion_ios_arrow_back  size:30.0 color:[UIColor whiteColor]] style:UIBarButtonItemStylePlain target:self action:@selector(didTapClose)];
    [self.navigationItem setLeftBarButtonItem:self.closeBarButtonItem];
    
    
    if(self.isPost){
//        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.dcPost.content]];
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.dcPost.displayName]];
    }
    else{
        // EdgeTVChat custom code
        if ([[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] lowercaseString] isEqual:@"edgetvchat_stage" ]){
            if([self.selectedFeedItem.entityType isEqual:EntityType_DIGITAL]){
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.digital.episodeTitle]];
            }
            else if ([self.selectedFeedItem.entityType isEqual:EntityType_EVENT]){
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.event.name]];
            }
            else{
                [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.person.name]];
            }
            
        }
        else{
            [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.title]];
        }
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadVideoToS3) name:@"uploadVideoToS3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyComment) name:@"replyComment" object:nil];
    
    // SLKTVC's configuration
    videoData = [ECVideoData sharedInstance];
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    [self.textInputbar setOpaque:YES];
    
    [self.leftButton setImage:[UIImage imageNamed:@"icn_upload"] forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor grayColor]];
    [self.leftButton setTitle:NSLocalizedString(@"Upload", nil) forState:UIControlStateNormal];

    [self.rightButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editorLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editorRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
#if !DEBUG_CUSTOM_TYPING_INDICATOR
    self.typingIndicatorView.canResignByTouch = YES;
#endif
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:MessengerCellIdentifier];
    
    // Added new identifier for Media purpose
    [self.tableView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:messengerMediaCellIdentifier];
    [self.autoCompletionView registerClass:[MessageTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#", @":", @"+:", @"/"]];
    
    [self.textView registerMarkdownFormattingSymbol:@"*" withTitle:@"Bold"];
    [self.textView registerMarkdownFormattingSymbol:@"_" withTitle:@"Italics"];
    [self.textView registerMarkdownFormattingSymbol:@"~" withTitle:@"Strike"];
    [self.textView registerMarkdownFormattingSymbol:@"`" withTitle:@"Code"];
    [self.textView registerMarkdownFormattingSymbol:@"```" withTitle:@"Preformatted"];
    [self.textView registerMarkdownFormattingSymbol:@">" withTitle:@"Quote"];
    
    // Checing for internet availability
    reachabilityInfo = [Reachability reachabilityForInternetConnection];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myReachabilityDidChangedMethod)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachabilityInfo startNotifier];

}
- (void)myReachabilityDidChangedMethod {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
          [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
        [self.tableView reloadData];
//        [indicator removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewReplyNewTap {
    [self.tableView reloadData];
}

- (void)didTapClose{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)replyComment
{
    [self.textView resignFirstResponder];
    [self.textView becomeFirstResponder];
}

#pragma mark - Example's Configuration

- (void)configureDataSource
{
    array = [[NSMutableArray alloc] init];
    self.viewReplyDict = [[NSMutableDictionary alloc] init];
    // Get comments
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading"];
    if(_isPost){
        [[ECAPI sharedManager] fetchCommentsByPostId:self.dcPost.postId callback:^(NSArray *comments, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [[ECCommonClass sharedManager] alertViewTitle:@"Even Chat" message:@"Failed to load comments please try again."];
            }
            else {
                for (int i = 0; i < comments.count; i++) {
                    self.viewCount = 0;
                    ECComment *comment = [comments objectAtIndex:i];
                    isChild = NO;
                    [self assignValuesToMessageClass:comment];
                    for (int j = 0; j < comments.count; j++){
                        ECComment *checkchild = [comments objectAtIndex:j];
                        if ([checkchild.parentId isEqualToString:comment.commentId]) {
                            self.viewCount = self.viewCount + 1;
                            NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.viewCount];
                            self.viewReplyDict[comment.commentId] = count;
                            isChild = YES;
                            [self assignValuesToMessageClass:checkchild];
                        }
                    }
                }
                
                NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
                self.messages = [[NSMutableArray alloc] initWithArray:reversed];
                [self.tableView reloadData];
            }
        }];
    }
    else{
        [[ECAPI sharedManager] fetchCommentsByTopicId:self.topicId callback:^(NSArray *comments, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                [[ECCommonClass sharedManager] alertViewTitle:@"Even Chat" message:@"Failed to load comments please try again."];
            }
            else {
                for (int i = 0; i < comments.count; i++) {
                    self.viewCount = 0;
                    ECComment *comment = [comments objectAtIndex:i];
                    isChild = NO;
                    [self assignValuesToMessageClass:comment];
                    for (int j = 0; j < comments.count; j++){
                        ECComment *checkchild = [comments objectAtIndex:j];
                        if ([checkchild.parentId isEqualToString:comment.commentId]) {
                            self.viewCount = self.viewCount + 1;
                            NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.viewCount];
                            self.viewReplyDict[comment.commentId] = count;
                            isChild = YES;
                            [self assignValuesToMessageClass:checkchild];
                        }
                    }
                }
                
                NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
                self.messages = [[NSMutableArray alloc] initWithArray:reversed];
                [self.tableView reloadData];
            }
        }];
    }
    self.users = @[@"Allen", @"Anna"];
}

-(void)assignValuesToMessageClass :(ECComment *)comment
{
    if ((isChild == NO && [comment.parentId isEqualToString:@"0"]) || isChild == YES) {
        Message *message  = [Message new];
        message.displayName     = comment.displayName;
        message.content         = comment.content;
        message.commentId       = comment.commentId;
        message.userId          = comment.userId;
        message.user            = comment.user;
        message.likeCount       = comment.likeCount;
        message.created_at      = comment.created_at;
        message.likedByIds      = comment.likedByIds;
        message.parantId        = comment.parentId;
        message.commentType     = comment.commentType;
        
        if ([comment.commentType isEqualToString:@"image"])
        {
            message.imageUrl         = comment.imageUrl;
            message.imageSizeInBytes = comment.imageSizeInBytes;
            message.thumbnailUrl     = comment.thumbnailUrl;
        }
        else
        {
            message.videoUrl         = comment.videoUrl;
            message.imageUrl         = comment.thumbnailUrl;
            message.imageSizeInBytes = comment.imageSizeInBytes;
            message.thumbnailUrl     = comment.thumbnailUrl;
        }
        [array addObject:message];
    }
}

- (void)configureActionItems
{
    UIBarButtonItem *arrowItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_arrow_down"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(hideOrShowTextInputbar:)];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_editing"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(editRandomMessage:)];
    
    UIBarButtonItem *typeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_typing"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(simulateUserTyping:)];
    
    UIBarButtonItem *appendItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_append"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(fillWithText:)];
    
    UIBarButtonItem *pipItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icn_pic"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(togglePIPWindow:)];
    
    self.navigationItem.rightBarButtonItems = @[arrowItem, pipItem, editItem, appendItem, typeItem];
}


#pragma mark - Action Methods

- (void)hideOrShowTextInputbar:(id)sender
{
    BOOL hide = !self.textInputbarHidden;
    
    UIImage *image = hide ? [UIImage imageNamed:@"icn_arrow_up"] : [UIImage imageNamed:@"icn_arrow_down"];
    UIBarButtonItem *buttonItem = (UIBarButtonItem *)sender;
    
    [self setTextInputbarHidden:hide animated:YES];
    [buttonItem setImage:image];
}

- (void)fillWithText:(id)sender
{
    if (self.textView.text.length == 0)
        {
        int sentences = (arc4random() % 4);
        if (sentences <= 1) sentences = 1;
        self.textView.text = [LoremIpsum sentencesWithNumber:sentences];
        }
    else {
        [self.textView slk_insertTextAtCaretRange:[NSString stringWithFormat:@" %@", [LoremIpsum word]]];
    }
}

- (void)simulateUserTyping:(id)sender
{
    if ([self canShowTypingIndicator]) {
        
#if DEBUG_CUSTOM_TYPING_INDICATOR
        __block TypingIndicatorView *view = (TypingIndicatorView *)self.typingIndicatorProxyView;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize imgSize = CGSizeMake(kTypingIndicatorViewAvatarHeight*scale, kTypingIndicatorViewAvatarHeight*scale);
        
        // This will cause the typing indicator to show after a delay ¯\_(ツ)_/¯
        [LoremIpsum asyncPlaceholderImageWithSize:imgSize
                                       completion:^(UIImage *image) {
                                           UIImage *thumbnail = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
                                           [view presentIndicatorWithName:[LoremIpsum name] image:thumbnail];
                                       }];
#else
        [self.typingIndicatorView insertUsername:[LoremIpsum name]];
#endif
    }
}

#pragma mark - API Methods
- (void)likeCellMessage:(UIGestureRecognizer *)gesture
{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    
    ECComment *message = self.messages[cell.indexPath.row];
    
    [[ECAPI sharedManager] likeComment:message.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionary, NSError *error){
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // Code
            
        }
    }];
}

- (void)reportCellMessage:(UIGestureRecognizer *)gesture{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    
    ECComment *message = self.messages[cell.indexPath.row];
    
    [[ECAPI sharedManager] reportComment:message.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionary, NSError *error){
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // Code
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:[NSString stringWithFormat:@"Comment posted by %@ was reported to the moderator.", message.displayName]
                                      delegate:nil
                                      cancelButtonTitle:@"Okay"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)hideAllMessagesFrom:(UIGestureRecognizer *)gesture{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    [alert makeAlertTypeCaution];
    [alert showAlertInView:self
                 withTitle:nil
              withSubtitle:@"Are you sure you would like to hide all message from this user?"
           withCustomImage:_alertImage
       withDoneButtonTitle:@"YES"
                andButtons:self.arrayOfButtonTitles];
}

- (void)deleteMessageByAppUserAtIndex:(UIGestureRecognizer *)gesture{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 3;
    [alert makeAlertTypeWarning];
    [alert showAlertInView:self
                 withTitle:nil
              withSubtitle:@"Are you sure you would like to delete this message?"
           withCustomImage:_alertImage
       withDoneButtonTitle:@"YES"
                andButtons:self.arrayOfButtonTitles];
}

- (void)didLongPressCell:(UIGestureRecognizer *)gesture
{
#ifdef __IPHONE_8_0
    if (SLK_IS_IOS8_AND_HIGHER && [UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        alertController.modalPresentationStyle = UIModalPresentationPopover;
        alertController.popoverPresentationController.sourceView = gesture.view.superview;
        alertController.popoverPresentationController.sourceRect = gesture.view.frame;
        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"Edit Message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [self editCellMessage:gesture];
//        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self deleteMessageByAppUserAtIndex:gesture];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self reportCellMessage:gesture];
    }
#else
    [self likeCellMessage:gesture];
#endif
}

- (void)editCellMessage:(UIGestureRecognizer *)gesture
{
    MessageTableViewCell *cell = (MessageTableViewCell *)gesture.view;
    
    self.editingMessage = self.messages[cell.indexPath.row];
    
    [self editText:self.editingMessage.content];
    
    [self.tableView scrollToRowAtIndexPath:cell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)editRandomMessage:(id)sender
{
    int sentences = (arc4random() % 10);
    if (sentences <= 1) sentences = 1;
    
    [self editText:[LoremIpsum sentencesWithNumber:sentences]];
}

- (void)editLastMessage:(id)sender
{
    if (self.textView.text.length > 0) {
        return;
    }
    
    NSInteger lastSectionIndex = [self.tableView numberOfSections]-1;
    NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex]-1;
    
    Message *lastMessage = [self.messages objectAtIndex:lastRowIndex];
    
    [self editText:lastMessage.content];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)togglePIPWindow:(id)sender
{
    if (!_pipWindow) {
        [self showPIPWindow:sender];
    }
    else {
        [self hidePIPWindow:sender];
    }
}

- (void)showPIPWindow:(id)sender
{
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.frame) - 60.0, 0.0, 50.0, 50.0);
    frame.origin.y = CGRectGetMinY(self.textInputbar.frame) - 60.0;
    
    _pipWindow = [[UIWindow alloc] initWithFrame:frame];
    _pipWindow.backgroundColor = [UIColor blackColor];
    _pipWindow.layer.cornerRadius = 10.0;
    _pipWindow.layer.masksToBounds = YES;
    _pipWindow.hidden = NO;
    _pipWindow.alpha = 0.0;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_pipWindow];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _pipWindow.alpha = 1.0;
                     }];
}

- (void)hidePIPWindow:(id)sender
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _pipWindow.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _pipWindow.hidden = YES;
                         _pipWindow = nil;
                     }];
}

- (void)textInputbarDidMove:(NSNotification *)note
{
    if (!_pipWindow) {
        return;
    }
    
    CGRect frame = self.pipWindow.frame;
    frame.origin.y = [note.userInfo[@"origin"] CGPointValue].y - 60.0;
    
    self.pipWindow.frame = frame;
}


#pragma mark - Overriden Methods

- (BOOL)ignoreTextInputbarAdjustment
{
    return [super ignoreTextInputbarAdjustment];
}

- (BOOL)forceTextInputbarAdjustmentForResponder:(UIResponder *)responder
{
    if ([responder isKindOfClass:[UIAlertController class]]) {
        return YES;
    }
    
    // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
    return SLK_IS_IPAD;
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
    // Notifies the view controller that the keyboard changed status.
}

- (void)textWillUpdate
{
    // Notifies the view controller that the text will update.
    
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    // Notifies the view controller that the text did update.
    
    [super textDidUpdate:animated];
}

- (void)didPressLeftButton:(id)sender
{
    // Notifies the view controller when the left button's action has been triggered, manually.
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Image",@"Video",nil];
    [actionSheet showInView:self.view];
    
    [super didPressLeftButton:sender];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        // Method to get images from camera or phone gallery.
        
        [[ECCommonClass sharedManager]showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Image" andResult:^(bool flag) {
            if (flag) {
                [self uploadImageToS3];
            }
        }];
        
    }else if(buttonIndex == 1){
       [[ECCommonClass sharedManager] showActionSheetToSelectMediaFromGalleryOrCamFromController:self andMediaType:@"Video" andResult:^(bool flag) {
           if (flag) {
               //[self uploadVideoToS3];
           }
       }];
        
    }
}

// Handling background Image upload
- (void) beginBackgroundUpdateTask {
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}
- (void) endBackgroundUpdateTask {
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

// Uploading Image On S3
-(void)uploadImageToS3{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Image"];
//    NSString *uniqId = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];

    NSData * thumbImageData = UIImagePNGRepresentation([[ECSharedmedia sharedManager] mediaThumbImage]);
    [self beginBackgroundUpdateTask];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"]);
    [[S3UploadImage sharedManager] uploadImageForData:thumbImageData forFileName:[[ECSharedmedia sharedManager]mediaImageThumbURL] FromController:self andResult:^(bool flag) {
        
        if (flag) {
            
            NSData * imgData = [[ECSharedmedia sharedManager] imageData];
            [[S3UploadImage sharedManager]uploadImageForData:imgData forFileName:[[ECSharedmedia sharedManager] mediaImageURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    [SVProgressHUD dismiss];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
//                    NSDate *created_atFromString = [[NSDate alloc] init];
                    
                    NSString * imageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageURL]];
                    
                    NSString * thumbImageURL = [NSString stringWithFormat:@"%@Images/%@",awsURL,[[ECSharedmedia sharedManager]mediaImageThumbURL]];
                    
                    // Hit API for new image comment
                    [[ECAPI sharedManager] postImageComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:self.signedInUser.firstName imageSizeInBytes:[[ECSharedmedia sharedManager] imageSizeInBytes] thumbnailURL:thumbImageURL  imageURL:imageURL commentType:@"image" parentId:[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"] postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error) {
                        if (!error) {
                            if (jsonDictionary != nil && ([jsonDictionary[@"statusCode"] integerValue] == 200)) {
                                
                            Message *message = [Message new];
                            
                            message.displayName      = jsonDictionary [ECdata][ECDisplayName];
                            message.user             = self.signedInUser;
                            message.likeCount        = 0;
                            message.commentType      = jsonDictionary[ECdata][ECCommentType];
                            message.imageUrl         = jsonDictionary[ECdata][ECImageUrl];
                            message.imageSizeInBytes = [jsonDictionary[ECdata][ECImageSizeInBytes] integerValue];
                            message.thumbnailUrl     = jsonDictionary[ECdata][ECThumbnailUrl];
                            message.parantId         = jsonDictionary[ECdata][ECParantId];
                            message.created_at       = jsonDictionary[ECdata][ECCreated_at];
                            message.commentId        = jsonDictionary[ECdata][ECCommentId];
                               
                                int index = 1;
                                NSLog(@"%@",jsonDictionary[ECdata][ECParantId]);
                                for (int i = 0; i < [self.messages count]; i++) {
                                    Message *checkIndex = [self.messages objectAtIndex:i];
                                    if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                                        index = i;
                                        for (int j = 0; j < [self.messages count]; j++) {
                                            Message *newcheckIndex = [self.messages objectAtIndex:j];
                                            if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                                                index = j;
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (index == 0) {
                                    index = 0;
                                }
                                else{
                                    index = index - 1;
                                }

                                
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                            UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                            
                            [self.tableView beginUpdates];
                            [self.messages insertObject:message atIndex:index];
                            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                            [self.tableView endUpdates];
                            
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                            
                            // Fixes the cell from blinking (because of the transform, when using translucent cells)
                            // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [self.textView resignFirstResponder];
                                [self.tableView reloadData];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
                        NSLog(@"Success uploading Comment:%@",jsonDictionary);
                        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
                        }
                        }
                        if (error) {
                            NSLog(@"Error :%@",error.localizedDescription);
                            [self endBackgroundUpdateTask];

                        }
                    }];
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureOfS3:@"Image"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];

                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureOfS3:@"Image"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];

        }
    }];
}

// Uploading Video On S3
- (void) uploadVideoToS3
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Uploading Video"];
    
    //Uploading Thumbnail image
    NSData * thumbImageData = UIImagePNGRepresentation(videoData.mediaThumbImage);
    [self beginBackgroundUpdateTask];
    
    [[S3UploadVideo sharedManager] uploadImageForData:thumbImageData forFileName:videoData.mediaThumbImageURL FromController:self andResult:^(bool flag) {
        
        if (flag) {
            //Uploading Video
            NSError* error = nil;
            NSData * videoDatas = [NSData dataWithContentsOfURL:videoData.videoURL options:NSDataReadingUncached error:&error];
            [[S3UploadVideo sharedManager] uploadVideoForData:videoDatas forFileName:[[ECVideoData sharedInstance] mediaURL] FromController:self andResult:^(bool flag) {
                
                if (flag) {
                    [self endBackgroundUpdateTask];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    //                    NSDate *created_atFromString = [[NSDate alloc] init];
                    
                    NSString * imageURL = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaURL];
                    
                    NSString * thumbImageURL = [NSString stringWithFormat:@"%@Videos/%@",awsURL,videoData.mediaThumbImageURL];
                    NSInteger videoBytes = (long)[videoDatas bytes];
                    
                    // Hit API for new video comment
                    [[ECAPI sharedManager] postImageComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:self.signedInUser.firstName imageSizeInBytes:videoBytes thumbnailURL:thumbImageURL  imageURL:imageURL commentType:@"video" parentId:[[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"] postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error) {
                        if (!error) {
                            if (jsonDictionary != nil && ([jsonDictionary[@"statusCode"] integerValue] == 200)) {
                                
                                Message *message = [Message new];
                                
                                message.displayName      = jsonDictionary [ECdata][ECDisplayName];
                                message.user             = self.signedInUser;
                                message.likeCount        = 0;
                                message.commentType      = jsonDictionary[ECdata][ECCommentType];
                                message.imageUrl         = jsonDictionary[ECdata][ECImageUrl];
                                message.videoUrl         = jsonDictionary[ECdata][ECVideoUrl];
                                message.imageSizeInBytes = [jsonDictionary[ECdata][ECImageSizeInBytes] integerValue];
                                message.thumbnailUrl     = jsonDictionary[ECdata][ECThumbnailUrl];
                                message.created_at       = jsonDictionary[ECdata][ECCreated_at];
                                message.parantId         = jsonDictionary[ECdata][ECParantId];
                                message.commentId        = jsonDictionary[ECdata][ECCommentId];
                                
                                int index = 1;
                                NSLog(@"%@",jsonDictionary[ECdata][ECParantId]);
                                for (int i = 0; i < [self.messages count]; i++) {
                                    Message *checkIndex = [self.messages objectAtIndex:i];
                                    if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                                        index = i;
                                        for (int j = 0; j < [self.messages count]; j++) {
                                            Message *newcheckIndex = [self.messages objectAtIndex:j];
                                            if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                                                index = j;
                                                break;
                                            }
                                        }

                                    }
                                }
                                if (index == 0) {
                                    index = 0;
                                }
                                else{
                                    index = index - 1;
                                }


                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                                UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                                
                                [self.tableView beginUpdates];
                                [self.messages insertObject:message atIndex:index];
                                [self.textView resignFirstResponder];
                                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                                [self.tableView endUpdates];
                                
                                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                
                                //                                 Fixes the cell from blinking (because of the transform, when using translucent cells)
                                //                              See https:
                                //github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                [self.tableView reloadData];
                                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                                
                                
                                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                for (UIViewController *aViewController in allViewControllers) {
                                    if ([aViewController isKindOfClass:[ECEventTopicCommentsViewController class]]) {
                                        [self.navigationController popToViewController:aViewController animated:YES];
                                    }
                                }
                                
                                //Removing view of replying.
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
                                NSLog(@"Success uploading Comment:%@",jsonDictionary);
                                [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
                            }
                        }
                        if (error) {
                            NSLog(@"Error :%@",error.localizedDescription);
                            [self endBackgroundUpdateTask];
                            
                        }
                    }];
                    
                } else{
                    // Fail Condition ask for retry and cancel through alertView
                    [self showFailureOfS3:@"Video"];
                    [SVProgressHUD dismiss];
                    [self endBackgroundUpdateTask];
                }
            }];
        } else{
            // Fail Condition ask for retry and cancel through alertView
            [self showFailureOfS3:@"Video"];
            [SVProgressHUD dismiss];
            [self endBackgroundUpdateTask];

                }
            }];
}

//Show Alert based on media type.
-(void)showFailureOfS3:(NSString *)mediaType{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Evnet Chat"
                                          message:[NSString stringWithFormat:@"%@ uploading Failed! \n Do you want to Retry?",mediaType]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Retry", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   // Re uploading if fail condition arises
                                   if ([mediaType isEqualToString:@"Image"]) {
                                       [self uploadImageToS3];
                                   }
                                   else{
                                       [self uploadVideoToS3];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// textview right btn i.e. post button click
- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    // Format date
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *created_atFromStrings = [[NSDate alloc] init];
    
    Message *message = [Message new];
    message.displayName = self.signedInUser.firstName;
    message.content = [self.textView.text copy];
    message.user = self.signedInUser;
    message.created_at = [dateFormatters stringFromDate:created_atFromStrings];
    message.likeCount = 0;
    message.parantId = [[NSUserDefaults standardUserDefaults] valueForKey:@"parantId"];
    
    NSLog(@"%@", self.topicId);
    [[ECAPI sharedManager] postComment:self.topicId feedItemId:self.selectedFeedItem.feedItemId userId:self.signedInUser.userId displayName:message.displayName content:message.content parentId:message.parantId postId:self.dcPost.postId callback:^(NSDictionary *jsonDictionary, NSError *error){
        if (error) {
            NSLog(@"Error adding user: %@", error);
            NSLog(@"%@", error);
        } else {
            // Code
            Message *message = [Message new];
//
            message.displayName      = jsonDictionary [ECdata][ECDisplayName];
            message.user             = self.signedInUser;
            message.likeCount        = 0;
            message.commentType      = jsonDictionary[ECdata][ECCommentType];
            message.parantId         = jsonDictionary[ECdata][ECParantId];
            message.created_at       = jsonDictionary[ECdata][ECCreated_at];
            message.content          = jsonDictionary[ECdata][ECContent];
            message.eventId          = jsonDictionary[ECdata][ECEventId];
            message.userId           = jsonDictionary[ECdata][ECUserId];
            message.commentId        = jsonDictionary[ECdata][ECCommentId];
            
            for (NSString* key in self.viewReplyDict) {
                NSString *value = [self.viewReplyDict objectForKey:key];
                if ([message.parantId isEqualToString:key]){
                    int mValue = [value intValue];
                    NSString *newVal = [NSString stringWithFormat:@"%lu", (unsigned long)mValue + 1];
                    self.viewReplyDict[message.parantId] = newVal;
                    self.isParentIdPresent = true;
                    break;
                }
            }
            
            if (self.isParentIdPresent == false){
                self.viewReplyDict[message.parantId] = @"1";
            }

            int index = 0;
            NSLog(@"%@",jsonDictionary[ECdata][ECParantId]);
            for (int i = 0; i < [self.messages count]; i++) {
                Message *checkIndex = [self.messages objectAtIndex:i];
                if (![jsonDictionary[ECdata][ECParantId] isEqualToString:@"0"] && [checkIndex.commentId isEqualToString:jsonDictionary[ECdata][ECParantId]]) {
                    index = i;
                    for (int j = 0; j < [self.messages count]; j++) {
                        Message *newcheckIndex = [self.messages objectAtIndex:j];
                        if ([jsonDictionary[ECdata][ECParantId] isEqualToString:newcheckIndex.parantId]) {
                            index = j;
                            break;
                        }
                    }
                }
            }
            if (index == 0) {
                index = 0;
            }
            else{
                index = index;
            }
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
            UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
            
            [self.tableView beginUpdates];
            [self.messages insertObject:message atIndex:index];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
            
            // Fixes the cell from blinking (because of the transform, when using translucent cells)
            // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.textView resignFirstResponder];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeComment" object:nil];
            NSLog(@"Success uploading Comment:%@",jsonDictionary);
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"parantId"];
            [self.tableView reloadData];
        }
    }];
    
    [super didPressRightButton:sender];
}

- (void)didPressArrowKey:(UIKeyCommand *)keyCommand
{
    if ([keyCommand.input isEqualToString:UIKeyInputUpArrow] && self.textView.text.length == 0) {
        [self editLastMessage:nil];
    }
    else {
        [super didPressArrowKey:keyCommand];
    }
}

- (NSString *)keyForTextCaching
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo
{
    // Notifies the view controller when the user has pasted a media (image, video, etc) inside of the text view.
    [super didPasteMediaContent:userInfo];
    
    SLKPastableMediaType mediaType = [userInfo[SLKTextViewPastedItemMediaType] integerValue];
    NSString *contentType = userInfo[SLKTextViewPastedItemContentType];
    id data = userInfo[SLKTextViewPastedItemData];
    
    NSLog(@"%s : %@ (type = %ld) | data : %@",__FUNCTION__, contentType, (unsigned long)mediaType, data);
}

- (void)willRequestUndo
{
    // Notifies the view controller when a user did shake the device to undo the typed text
    
    [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    self.editingMessage.content = [self.textView.text copy];
    
    [self.tableView reloadData];
    
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
    
    [super didCancelTextEditing:sender];
}

- (BOOL)canPressRightButton
{
    return [super canPressRightButton];
}

- (BOOL)canShowTypingIndicator
{
#if DEBUG_CUSTOM_TYPING_INDICATOR
    return YES;
#else
    return [super canShowTypingIndicator];
#endif
}

- (BOOL)shouldProcessTextForAutoCompletion:(NSString *)text
{
    if ([text hasPrefix:@"/"] && self.isAutoCompleting) {
        if (self.foundPrefixRange.location != 0) {
            return NO;
        }
        
        NSArray *components = [text componentsSeparatedByString:@" "];
        NSString *command = [[components firstObject] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if ([self.commands containsObject:command]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)didChangeAutoCompletionPrefix:(NSString *)prefix andWord:(NSString *)word
{
    NSArray *array1 = nil;
    
    self.searchResult = nil;
    
    if ([prefix isEqualToString:@"@"]) {
        // Commenting out for now to fix @ sign crash. Will enable tagging feature later - JB - 03/10/18
//        if (word.length > 0) {
//            array1 = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
//        }
//        else {
//            array1 = self.users;
//        }
    }
    else if ([prefix isEqualToString:@"#"] && word.length > 0) {
        array1 = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }
    else if (([prefix isEqualToString:@":"] || [prefix isEqualToString:@"+:"]) && word.length > 1) {
        array1 = [self.emojis filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    }
    else if ([prefix isEqualToString:@"/"] && self.foundPrefixRange.location == 0) {
        if (word.length > 0) {
            array1 = [self.commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
        }
        else {
            array1 = self.commands;
        }
    }
    
    if (array1.count > 0) {
        //array1 = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    self.searchResult = [[NSMutableArray alloc] initWithArray:array1];
    
    BOOL show = (self.searchResult.count > 0);
    
    [self showAutoCompletionView:show];
}

- (CGFloat)heightForAutoCompletionView
{
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight*self.searchResult.count;
}

// Handling image tap which will open image in another larger view

- (void)handleImageTap:(UIGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.tableView.frame fromView:self.tableView.superview], location))
    {
        CGPoint locationInTableview = [self.tableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath){
            
            Message *message = [Message new];
            message = [self.messages objectAtIndex:indexPath.row];
            
            BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]];
            if (imageContains) {
                self.fullScreenImageViewController = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
                self.fullScreenImageViewController.imagePath = message.imageUrl;
                [self presentViewController:self.fullScreenImageViewController animated:YES completion:nil];
            }
        }
    }
}

- (void)handleVideoTap:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    if (CGRectContainsPoint([self.view convertRect:self.tableView.frame fromView:self.tableView.superview], location))
    {
        CGPoint locationInTableview = [self.tableView convertPoint:location fromView:self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInTableview];
        if (indexPath){
            BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
            if (isInternetAvailable) {
                Message *message = [Message new];
                message = [self.messages objectAtIndex:indexPath.row];
                MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:message.videoUrl]];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(moviePlaybackDidFinish)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:nil];
                
                mpvc.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                [self presentMoviePlayerViewControllerAnimated:mpvc];
            } else {
                [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
            }
            
//            BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]];
//            if (imageContains) {
//                self.fullScreenImageViewController = [[ECFullScreenImageViewController alloc] initWithNibName:@"ECFullScreenImageViewController" bundle:nil];
//                self.fullScreenImageViewController.videoPath = message.videoUrl;
//                [self presentViewController:self.fullScreenImageViewController animated:YES completion:nil];
//            }
        }
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        return self.messages.count;
    }
    else {
        return self.searchResult.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return [self messageCellForRowAtIndexPath:indexPath];
    }
    else {
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    }
}

- (MessageTableViewCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell;
    Message *message = self.messages[indexPath.row];
    
    //Loading MediaCell
    if ([message.commentType isEqualToString:@"image"] || [message.commentType isEqualToString:@"video"]) {
        cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:messengerMediaCellIdentifier forIndexPath:indexPath];
        
        //Removing subviews of cell because it was taking previous contents after scroll
        if ([cell.contentView subviews])
        {
            for (UIView *subview in [cell.contentView subviews]) {
                [subview removeFromSuperview];
            }
        }

        cell.message = message;
        [cell configureSubviewsForMediaCell];
        cell.delegate = self;
        cell.downloadButton.tag = indexPath.row;
    }
    //Loading TextCell.
    else
    {
        cell = (MessageTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier forIndexPath:indexPath];
        
        //Removing subviews of cell because it was taking previous contents after scroll
        if ([cell.contentView subviews]) {
            for (UIView *subview in [cell.contentView subviews]) {
                [subview removeFromSuperview];
            }
        }
        
        ECCommonClass *instance = [ECCommonClass sharedManager];
        instance.isFromChatVC = false;
        cell.message = message;
//        [cell configureSubviews];
        [cell configureSubviewsForChatReaction];
        
        if (!cell.textLabel.text) {
            if([self.signedInUser.userId isEqual:message.userId]){
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCell:)];
                [cell addGestureRecognizer:longPress];
            }
        }
        cell.delegate = self;
    }
    
    cell.cellIndexPath = indexPath;
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", message.user.firstName, message.user.lastName];
    cell.titleLabel.textColor = [UIColor darkGrayColor];
    cell.replyLabel.text = @" \u2022 reply";
    cell.viewReplyLabel.textColor = [UIColor blueColor];
    
    if ([message.parantId isEqualToString:@"0"]){
        for (NSString* key in self.viewReplyDict) {
            id value = [self.viewReplyDict objectForKey:key];
            if ([message.commentId isEqualToString:key]){
                NSString *mViewReplyCount = [NSString stringWithFormat:@"\u2022 ViewReply(%@",value];
                mViewReplyCount = [mViewReplyCount stringByAppendingString:@")"];
                cell.viewReplyLabel.text = mViewReplyCount;
                [cell.viewReplyLabel setHidden:NO];
                break;
            }else{
                [cell.viewReplyLabel setHidden:YES];
            }
        }
    }
    
//    cell.reportLabel.text = @" \u2022 hide";
    
    created_atFromString = [dateFormatter dateFromString:message.created_at];
    NSString *ago = [created_atFromString formattedAsTimeAgo];
    NSArray *likedByIds = [NSArray arrayWithArray:message.likedByIds];
    /*
    if([likedByIds containsObject:self.signedInUser.userId]){
        cell.likeCountLabel.textColor = [UIColor lightGrayColor];
        cell.likeCountLabel.userInteractionEnabled = NO;
    }
    else{
        cell.likeCountLabel.textColor = [UIColor blueColor];
    }
    if(message.likeCount != nil){
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@ \u2022 Like \u2022 %@", ago, message.likeCount];
    }
    else{
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@ \u2022 Like \u2022 %@", ago, @"0"];
    }
    */
    if([likedByIds containsObject:self.signedInUser.userId]){
        cell.likeCountLabel.textColor = [UIColor lightGrayColor];
        cell.likeCountLabel.userInteractionEnabled = NO;
    }
    else{
        cell.likeCountLabel.textColor = [UIColor lightGrayColor];
    }
    if(message.likeCount != nil){
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, message.likeCount];
    }
    else{
        cell.likeCountLabel.text = [NSString stringWithFormat:@"%@, %@ Like", ago, @"0"];
    }

    
    // Configure cell if not flagged for offensive content
    if(![_signedInUser.blockedPostByUserId containsObject:message.userId]){
        //Configuring cell for image.
        if ([message.commentType isEqualToString:@"image"])
        {
            if (message.imageSizeInBytes < 1048576) {
                // show image without download option.
                [self showImageOnTheCell:cell ForImageUrl:message.imageUrl isFromDownloadButton:NO];
                cell.downloadButton.hidden = YES;
                cell.mediaImageView.userInteractionEnabled = YES;
                
            } else
                // Image size is less than 1 Mb
            {
                // Checking if Image is already in the Cache.
                BOOL imageContains = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]];
                if (imageContains) {
                    cell.mediaImageView.userInteractionEnabled = YES;
                    [self showImageOnTheCell:cell ForImageUrl:message.imageUrl isFromDownloadButton:NO];
                    cell.downloadButton.hidden = YES;
                } else{
                    NSLog(@"Thumb image with download Icon");
                    [self showImageOnTheCell:cell ForImageUrl:message.thumbnailUrl isFromDownloadButton:NO];
                    [cell.downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
                    cell.downloadButton.hidden = NO;
                    
                }
            }
            // Adding gesture to image to open in another view
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            tapGestureRecognizer.numberOfTouchesRequired = 1;
            cell.mediaImageView.userInteractionEnabled = YES;
            [cell.mediaImageView addGestureRecognizer:tapGestureRecognizer];
            
        }
        //Configuring cell for Video
        else if ([message.commentType isEqualToString:@"video"])
        {
            //Showing Thumbimage of video and adding play button.
            NSLog(@"Thumb image with download Icon");
            [self.view bringSubviewToFront:cell.mediaImageView];
            [self showImageOnTheCell:cell ForImageUrl:message.thumbnailUrl isFromDownloadButton:NO];
            [cell.downloadButton setBackgroundImage:[UIImage imageNamed:@"play-button"] forState:UIControlStateNormal];
            cell.downloadButton.hidden = NO;
            
            
            // Adding gesture to image to open in another view
            //            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTap:)];
            //            tapGestureRecognizer.numberOfTapsRequired = 1;
            //            tapGestureRecognizer.numberOfTouchesRequired = 1;
            //            cell.mediaImageView.userInteractionEnabled = YES;
            //            [cell.mediaImageView addGestureRecognizer:tapGestureRecognizer];
        }
        //Displaying comment text.
        else
        {
            cell.bodyLabel.text = message.content;
            cell.bodyLabel.textColor = [UIColor lightGrayColor];
        }
    }
    else{
        cell.bodyLabel.text = @"[Removed due to offensive content]";
    }
    
    // Set profile pic
    [cell.thumbnailView sd_setImageWithURL:[NSURL URLWithString:message.user.profilePicUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];

    cell.indexPath = indexPath;
    cell.usedForMessage = YES;
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

// Displaying Image on Cell
-(void)showImageOnTheCell:(MessageTableViewCell *)cell ForImageUrl:(NSString *)url isFromDownloadButton:(BOOL)downloadFlag{
    
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor colorWithRed:171.0/255.0 green:57.0/255.0 blue:158.0/255.0 alpha:1.0];
    [indicator startAnimating];
    [indicator setCenter: CGPointMake(170, 160)];
    
    [cell.contentView addSubview:indicator];
    [cell.contentView bringSubviewToFront:indicator];
    [indicator setCenter: CGPointMake(170, 160)];
    
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:url];
    // resolves the SDWebImage issue of image missing
    if (inMemoryImage)
    {
        cell.mediaImageView.image = inMemoryImage;
        [indicator removeFromSuperview];
        
    }
    else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
        UIImage *image = [cache imageFromDiskCacheForKey:url];
        cell.mediaImageView.image = image;
        [indicator removeFromSuperview];
        
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
                                [indicator removeFromSuperview];
                                if (image) {
                                    cell.mediaImageView.image = image;
                                    cell.mediaImageView.layer.borderWidth = 1.0;
                                    cell.mediaImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                }
                                else {
                                    if(error){
                                        NSLog(@"Problem downloading Image, play try again")
                                        ;
                                        if (downloadFlag) {
                                            cell.downloadButton.hidden = NO;
                                        }
                                        return;
                                    }
                                }
                            }];
    }
}

-(void)playButtonPressed:(Message *)message
{
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        //MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:message.videoUrl]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:message.videoUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerViewController *avvc = [AVPlayerViewController new];
        avvc.player = player;
        [player play];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlaybackDidFinish)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        //mpvc.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        //[self presentMoviePlayerViewControllerAnimated:mpvc];
        [self presentViewController:avvc animated:YES completion:nil];
        
        
    } else {
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
    }
}

// Clicking Downolad Button on Image
-(void)downloadButtonClickedForImage:(NSInteger)imageIndex forCell:(MessageTableViewCell *)cell{
    
    BOOL isInternetAvailable = [[ECCommonClass sharedManager]isInternetAvailabel];
    if (isInternetAvailable) {
        NSLog(@"Button clicked tag :%ld",(long)imageIndex);
        Message *message = self.messages[imageIndex];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.color = [UIColor colorWithRed:171.0/255.0 green:57.0/255.0 blue:158.0/255.0 alpha:1.0];
        [indicator startAnimating];
        [indicator setCenter: CGPointMake(170, 160)];
        [cell.contentView addSubview:indicator];
        [cell.contentView bringSubviewToFront:indicator];
        [indicator setCenter: CGPointMake(170, 160)];
       
        if (cell.downloadButton.tag == imageIndex) {
            cell.downloadButton.hidden = YES;
        }
        
        SDImageCache *cache = [SDImageCache sharedImageCache];
        UIImage *inMemoryImage = [cache imageFromMemoryCacheForKey:message.imageUrl];
        // resolves the SDWebImage issue of image missing
        if (inMemoryImage)
        {
            cell.mediaImageView.image = inMemoryImage;
            [indicator removeFromSuperview];
            if (cell.downloadButton.tag == imageIndex) {
                cell.downloadButton.hidden = YES;
            }
            
        }
        else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:message.imageUrl]]){
            UIImage *image = [cache imageFromDiskCacheForKey:message.imageUrl];
            cell.mediaImageView.image = image;
            [indicator removeFromSuperview];
            if (cell.downloadButton.tag == imageIndex) {
                cell.downloadButton.hidden = YES;
            }
            
        }else{
            NSURL *url = [NSURL URLWithString:message.imageUrl];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager.imageDownloader setDownloadTimeout:20];
            [manager downloadImageWithURL:url
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    [indicator removeFromSuperview];
                                    
                                    if (image) {
                                        if (cell.downloadButton.tag == imageIndex) {
                                            cell.downloadButton.hidden = YES;
                                        }
                                        cell.mediaImageView.image = image;
                                        cell.mediaImageView.layer.borderWidth = 1.0;
                                        cell.mediaImageView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor redColor]);
                                    }
                                    else {
                                        if (cell.downloadButton.tag == imageIndex) {
                                            cell.downloadButton.hidden = NO;
                                        }
                                    }
                                }];
        }
    }else{
        [[ECCommonClass sharedManager] alertViewTitle:@"Network Error" message:@"No internet connection available"];
    }
}

- (MessageTableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
    cell.indexPath = indexPath;
    
    NSString *text = self.searchResult[indexPath.row];
    
    if ([self.foundPrefix isEqualToString:@"#"]) {
        text = [NSString stringWithFormat:@"# %@", text];
    }
    else if (([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix isEqualToString:@"+:"])) {
        text = [NSString stringWithFormat:@":%@:", text];
    }
    
    cell.titleLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
       
        //Height for image or video cell.
        Message *message = self.messages[indexPath.row];
        if ([message.commentType isEqualToString:@"image"] || [message.commentType isEqualToString:@"video"]) {
            return 330;
        }
        
        // check parent commentID with child parentID
        NSLog(@"message.parantId: %@", message.parantId);
        ECCommonClass *instance = [ECCommonClass sharedManager];
        
        if ([message.parantId isEqualToString:@"0"] || [instance.parentCommentIDArray containsObject:message.parantId]){
            //show list
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentLeft;
            
            CGFloat pointSize = [MessageTableViewCell defaultFontSize];
            
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
                                         NSParagraphStyleAttributeName: paragraphStyle};
            
            CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
            width -= 25.0;
            
            CGRect titleBounds = [message.displayName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            CGRect bodyBounds = [message.content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            CGRect likeLabelBounds = [message.likeCount boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
            
            if (message.content.length == 0) {
                return 0.0;
            }
            
            CGFloat height = CGRectGetHeight(titleBounds);
            height += CGRectGetHeight(bodyBounds);
            height += CGRectGetHeight(likeLabelBounds);
            height += 50.0;
            
            if (height < kMessageTableViewCellMinimumHeight) {
                height = kMessageTableViewCellMinimumHeight;
            }
            
            return height;
        }else{
            // hide child list
            return 0.0;
        }
    }
    else {
        return kMessageTableViewCellMinimumHeight;
    }
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        
        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
        
        if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
            [item appendString:@":"];
        }
        else if (([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix isEqualToString:@"+:"])) {
            [item appendString:@":"];
        }
        
        [item appendString:@" "];
        
        [self acceptAutoCompletionWithString:item keepPrefix:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    Message *message = self.messages[indexPath.row];
//    if([self.signedInUser.userId isEqual:message.userId]){
//        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//            [self.messages removeObjectAtIndex:indexPath.row];
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        }];
//
//        return @[deleteAction];//@[deleteAction, moreAction, blurAction];
//    }
//    else{
//        return @[];
//    }
    return nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    Message *message = self.messages[indexPath.row];
    if([self.signedInUser.userId isEqual:message.userId]){
        return NO;
    }
    else{
        return NO;
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important that if you override this method, to call super.
    [super scrollViewDidScroll:scrollView];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(SLKTextView *)textView{
        return YES;
}

- (BOOL)textViewShouldEndEditing:(SLKTextView *)textView
{
    return YES;
}

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (BOOL)textView:(SLKTextView *)textView shouldOfferFormattingForSymbol:(NSString *)symbol
{
    if ([symbol isEqualToString:@">"]) {
        
        NSRange selection = textView.selectedRange;
        
        // The Quote formatting only applies new paragraphs
        if (selection.location == 0 && selection.length > 0) {
            return YES;
        }
        
        // or older paragraphs too
        NSString *prevString = [textView.text substringWithRange:NSMakeRange(selection.location-1, 1)];
        
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[prevString characterAtIndex:0]]) {
            return YES;
        }
        
        return NO;
    }
    
    return [super textView:textView shouldOfferFormattingForSymbol:symbol];
}

- (BOOL)textView:(SLKTextView *)textView shouldInsertSuffixForFormattingWithSymbol:(NSString *)symbol prefixRange:(NSRange)prefixRange
{
    if ([symbol isEqualToString:@">"]) {
        return NO;
    }
    
    return [super textView:textView shouldInsertSuffixForFormattingWithSymbol:symbol prefixRange:prefixRange];
}

#pragma mark - Lifeterm

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MessageTableViewCell Methods

-(void)didTapLikeComment:(MessageTableViewCell *)messageTableViewCell{
    NSLog(@"IndexPath: %ld", (long)messageTableViewCell.indexPath.row);
}

-(void)hideAllCommentsByUser:(Message *)message{
    NSLog(@"IndexPath: %@", message.userId);
    if(![_signedInUser.userId isEqual:message.userId]){
        _blockedMessage = message;
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.delegate = self;
        alert.tag = 1;
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:nil
                  withSubtitle:@"Are you sure you would like to hide all messages from this user?"
               withCustomImage:_alertImage
           withDoneButtonTitle:@"YES"
                    andButtons:self.arrayOfButtonTitles];
    }
}

-(void)deleteCommentByUser:(Message *)message{
    NSLog(@"IndexPath: %@", message.userId);
    if(![_signedInUser.userId isEqual:message.userId]){
        _blockedMessage = message;
        FCAlertView *alert = [[FCAlertView alloc] init];
        alert.delegate = self;
        alert.tag = 1;
        [alert makeAlertTypeCaution];
        [alert showAlertInView:self
                     withTitle:nil
                  withSubtitle:@"Are you sure you would like to hide all messages from this user?"
               withCustomImage:_alertImage
           withDoneButtonTitle:@"YES"
                    andButtons:self.arrayOfButtonTitles];
    }
    
}

#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title {
    NSLog(@"Button Clicked: %ld Title:%@", (long)index, title);
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView {
    NSLog(@"Done Button Clicked");
    if(alertView.tag == 1){
        if(![_signedInUser.blockedPostByUserId containsObject:_blockedMessage.userId]){
            [_signedInUser.blockedPostByUserId addObject:_blockedMessage.userId];
            //Sync user to DB
            [[ECAPI sharedManager] updateUser:self.signedInUser callback:^(ECUser *ecUser, NSError *error) {
                if (error) {
                    NSLog(@"Error adding user: %@", error);
                    NSLog(@"%@", error);
                }
                FCAlertView *alert = [[FCAlertView alloc] init];
                alert.delegate = self;
                alert.tag = 2;
                [alert makeAlertTypeWarning];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:@"Would also like to report this user to EdgeChat?"
                       withCustomImage:_alertImage
                   withDoneButtonTitle:@"YES"
                            andButtons:self.arrayOfButtonTitles];
                
                [self.tableView reloadData];
            }];
        }
    }else if (alertView.tag == 2){
        //
        NSLog(@"Report Tapped");
        NSLog(@"CommentId: %@ - UserId: %@", _blockedMessage.commentId, self.signedInUser.userId);
        [[ECAPI sharedManager] reportComment:_blockedMessage.commentId userId:self.signedInUser.userId callback:^(NSDictionary *jsonDictionarty, NSError *error){
            
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                FCAlertView *alert = [[FCAlertView alloc] init];
                [alert makeAlertTypeSuccess];
                [alert showAlertInView:self
                             withTitle:nil
                          withSubtitle:[NSString stringWithFormat:@"%@ has been reported to EdgeChat.", _blockedMessage.displayName]
                       withCustomImage:nil
                   withDoneButtonTitle:nil
                            andButtons:nil];
                NSLog(@"%@",jsonDictionarty);
            }
        }];
    }
    else if (alertView.tag == 3){
        
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView {
    NSLog(@"Alert Dismissed");
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView {
    NSLog(@"Alert Will Appear");
}
@end
