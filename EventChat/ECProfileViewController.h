#import <UIKit/UIKit.h>
#import "ECUser.h"

@class ECUser;

@interface ECProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, assign) BOOL isSignedInUser;
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, strong)ECUser *profileUser;
@end
