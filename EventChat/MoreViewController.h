#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <ContactsUI/ContactsUI.h>
#import "SignUpLoginViewController.h"
#import "RegisterViewController.h"

@interface MoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate,SignUpLoginViewControllerDelegate, RegisterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *moreTableView;
@property (retain, nonatomic) NSString *storyBoardIdentifier;
- (void)pushToSignInVC :(NSString*)stbIdentifier;

@end
