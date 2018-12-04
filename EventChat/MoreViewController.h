#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <ContactsUI/ContactsUI.h>
#import "SignUpLoginViewController.h"

@interface MoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate,SignUpLoginViewControllerDelegate>

@property (retain, nonatomic) NSString *storyBoardIdentifier;
- (void)pushToSignInVC :(NSString*)stbIdentifier;

@end
