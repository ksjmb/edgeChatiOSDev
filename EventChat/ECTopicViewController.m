#import "ECTopicViewController.h"
#import "ECAddTopicViewController.h"
#import "SVProgressHUD.h"
#import "ECAPI.h"
#import "ECTopic.h"
#import "ECTopicCell.h"
#import "ECEventTopicCommentsViewController.h"
#import "ECEventBriteName.h"
#import "ECAttendanceDetailsViewController.h"

@interface ECTopicViewController ()
@property (nonatomic, weak) IBOutlet UITableView *eventTopicTableView;
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic, strong) ECTopic *topic;
@end

@implementation ECTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEventTopics];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.title]];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [self loadEventTopics];
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
- (void)loadEventTopics{
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    [SVProgressHUD showWithStatus:@"Loading topics"];
    NSLog(@"%@", self.selectedFeedItem.feedItemId);
    NSLog(@"%@", self.eventId);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[ECAPI sharedManager] fetchTopicsByFeedItemId:self.selectedFeedItem.feedItemId callback:^(NSArray *topics, NSError *error)  {
        if(error){
            NSLog(@"Error: %@", error);
        }
        else{
            
            NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
            
            self.topics = [[NSMutableArray alloc] initWithArray:topics];
            NSLog(@"%lu", (unsigned long)[self.topics count]);
            [self.eventTopicTableView reloadData];
//            [SVProgressHUD dismiss];
        }
        
    }];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else{
        return 2;
    }
    //return [self.topics count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return @"Attendance";
    }
    else{
        return @"Communication";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ECTopicCell";
    
    NSLog(@"%@", [self.topics objectAtIndex:indexPath.row]);
    
    if(indexPath.section == 0){
        ECTopic *topic = [self.topics objectAtIndex:indexPath.row];

        static NSString *cellIdentifier = @"cell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        cell.textLabel.text = topic.content;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        return cell;
    }
    else{
        ECTopic *topic = [self.topics objectAtIndex:indexPath.row + 1];

        ECTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.delegate = self;
        [cell configureWithEvent:topic];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        ECAttendanceDetailsViewController *ecAttendanceDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAttendanceDetailsViewController"];
        ECTopic *topic = [self.topics objectAtIndex:indexPath.row];
        ecAttendanceDetailsViewController.selectedFeedItem = self.selectedFeedItem;
        
        [self.navigationController pushViewController:ecAttendanceDetailsViewController animated:YES];
    }
    else{
        ECEventTopicCommentsViewController *ecEventTopicCommentsViewController = [[ECEventTopicCommentsViewController alloc] init];
        ECTopic *topic = [self.topics objectAtIndex:indexPath.row + 1];
        NSLog(@"%@", topic.topicId);
        ecEventTopicCommentsViewController.selectedFeedItem = self.selectedFeedItem;
        ecEventTopicCommentsViewController.selectedTopic = topic;
        ecEventTopicCommentsViewController.topicId = topic.topicId;
        
        [self.navigationController pushViewController:ecEventTopicCommentsViewController animated:YES];
    }
}

- (IBAction)didTapAddTopicButton:(id)sender{
    ECAddTopicViewController *ecAddTopicViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECAddTopicViewController"];
    ecAddTopicViewController.selectedFeedItem = self.selectedFeedItem;
    
    [self.navigationController pushViewController:ecAddTopicViewController animated:YES];
}

@end
