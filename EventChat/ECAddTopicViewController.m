#import "ECAddTopicViewController.h"
#import "ECAPI.h"
#import "ECEventBriteName.h"

@interface ECAddTopicViewController ()

@end

@implementation ECAddTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@", self.selectedFeedItem.title);
    [self.topicTextView becomeFirstResponder];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@", self.selectedFeedItem.title]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapCancelButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapSaveButton:(id)sender{
    if(self.topicTextView.text.length == 0){
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Please enter a topic to proceed"
                                  delegate:nil
                                  cancelButtonTitle:@"Okay"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    else{
        [[ECAPI sharedManager] addTopic:self.eventId userId:@"0" content:self.topicTextView.text parentId:@"0" callback:^(NSDictionary *jsonDictionary, NSError *error){
            if (error) {
                NSLog(@"Error adding user: %@", error);
                NSLog(@"%@", error);
            } else {
                // Code
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
}

@end
