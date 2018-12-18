#import "ECNotificationsViewController.h"
#import "ECNotification.h"
#import "SVProgressHUD.h"
#import "ECAPI.h"
#import "ECUser.h"
#import "ECColor.h"
#import "AppDelegate.h"
#import "ECEventTopicCommentsViewController.h"
#import "ECProfileViewController.h"
#import "SignUpLoginViewController.h"
#import "ECCommonClass.h"

@interface ECNotificationsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *notificationTableView;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) ECNotification *notification;
@property (nonatomic, strong) ECUser *signedInUser;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) NSMutableOrderedSet *acknowledgedNotificationIdList;
@property (nonatomic, assign) NSString *userEmail;
@end

@implementation ECNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    _acknowledgedNotificationIdList = [[NSMutableOrderedSet alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];

    if (_userEmail != nil && ![_userEmail isEqualToString:@""]){
        [self loadNotifications];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] clearNotificationCount];
    }else{
//        [self.notifications removeAllObjects];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"Acknowledged: %@", _acknowledgedNotificationIdList);
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - API calls

- (void)loadNotifications{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Loading notifications"];
   
    [[ECAPI sharedManager] getNotificationsByUserId:self.signedInUser.userId callback:^(NSArray *notifications, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            self.notifications = [[NSMutableArray alloc] initWithArray:notifications];
            NSLog(@"%lu", (unsigned long)[self.notifications count]);
            [self.notificationTableView reloadData];
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - Table view data source
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60.0;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.notificationTableView]) {
        
        ECNotification *notification = [self.notifications objectAtIndex:indexPath.row];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        CGFloat pointSize = [MessageTableViewCell defaultFontSize];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kMessageTableViewCellAvatarHeight;
        width -= 25.0;
        
        CGRect bodyBounds = [notification.message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect timeLabelBounds = [notification.created_at boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (notification.message.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(bodyBounds);
        height += CGRectGetHeight(timeLabelBounds);
        height += 10.0;
        
        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMessageTableViewCellMinimumHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECNotificationCell";
    
    NSLog(@"%@", [self.notifications objectAtIndex:indexPath.row]);
    
    ECNotification *notification = [self.notifications objectAtIndex:indexPath.row];
    
    //static NSString *cellIdentifier = @"cell";
    ECNotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    if (!cell) {
        cell = [[ECNotificationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell configureWithNotification:notification];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ECNotification *notification = [self.notifications objectAtIndex:indexPath.row];
    // JB: 01/26/18 - Commented out for now to simplify the UI. Will think about enabling in the future if a business requirement
//    if(!notification.acknowledged){
//        [_acknowledgedNotificationIdList addObject:notification.notificationId];
//        [[ECAPI sharedManager] acknowledgeNotification:notification.notificationId callback:^(NSError *error) {
//            if (error) {
//                NSLog(@"Error adding user: %@", error);
//                NSLog(@"%@", error);
//            } else {
//                // code
//                ECNotificationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                [cell setBackgroundColor:[UIColor whiteColor]];
//                [(AppDelegate *)[[UIApplication sharedApplication] delegate] updateBadgeCounts];
//            }
//        }];
//    }
    
    if([notification.notificationType isEqualToString:@"like"]){
        if(notification.feedItemId != nil){
            [[ECAPI sharedManager] getFeedItemById:notification.feedItemId callback:^(DCFeedItem *dcFeedItem, NSError *error) {
                if(error){
                    NSLog(@"Error: %@", error);
                }
                [[ECAPI sharedManager] fetchTopicsByFeedItemId:notification.feedItemId callback:^(NSArray *topics, NSError *error)  {
                    if(error){
                        NSLog(@"Error: %@", error);
                    }
                    else{
                        // Push to comments view controller directly
                        ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
                        ECTopic *topic = [[[NSMutableArray alloc] initWithArray:topics] objectAtIndex:1];
                        ecEventTopicCommentsViewController.selectedFeedItem = dcFeedItem;
                        ecEventTopicCommentsViewController.selectedTopic = topic;
                        ecEventTopicCommentsViewController.topicId = topic.topicId;
                        [self showViewController:ecEventTopicCommentsViewController sender:nil];
                    }
                }];
            }];
        }
    }else if([notification.notificationType isEqualToString:@"follow"]){
        ECProfileViewController *ecProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECProfileViewController"];
        ecProfileViewController.isSignedInUser = false;
        ecProfileViewController.profileUser = notification.notifierUser;
        
        [self.navigationController pushViewController:ecProfileViewController animated:YES];
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Clear"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        ECNotification *notification = [self.notifications objectAtIndex:indexPath.row];
//        [[ECAPI sharedManager] acknowledgeNotification:notification.notificationId callback:^(NSError *error) {
//            if (error) {
//                NSLog(@"Error adding user: %@", error);
//                NSLog(@"%@", error);
//            } else {
//                // code
//                [self.notifications removeObjectAtIndex:indexPath.row];
//                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//        }];
    }];
    
    return @[deleteAction];//@[deleteAction, moreAction, blurAction];
}

@end
