#import <UIKit/UIKit.h>

@class RegisterViewController;
@protocol RegisterViewControllerDelegate <NSObject>
-(void)didTapSignUpButton:(NSString *)storyboardIdentifier;
@end

@interface RegisterViewController : UIViewController

@property (retain, nonatomic) NSString *storyboardIdentifierStr;
@property (nonatomic, weak) id <RegisterViewControllerDelegate> mDelegate;

@end
