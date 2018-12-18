#import "MoreViewController.h"
#import "ECProfileViewController.h"
#import "NotificationSettingsViewController.h"
#import "ECUser.h"
#import "ECAPI.h"
#import "ECCommonClass.h"
#import "ECFavoritesViewController.h"
#import "ECHowToViewController.h"
#import "AppDelegate.h"
#import "ECColor.h"
#import "TermsConditionsViewController.h"
#import "DCPlaylistsTableViewController.h"
#import "DCProfileTableViewController.h"
#import "TestTableViewController.h"
#import "SignUpLoginViewController.h"
#import "ECCommonClass.h"

@interface MoreViewController ()
@property (nonatomic, strong)ECUser *signedInUser;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) CNContactPickerViewController *peoplePicker;
@property (nonatomic, assign) NSString *userEmail;
//@property(nonatomic, assign) int myValue;

@end

@implementation MoreViewController

#pragma mark:- ViewController LifeCycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Get logged in user
    self.signedInUser = [[ECAPI sharedManager] signedInUser];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    self.userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInUserEmail"];
    [self.moreTableView reloadData];
}

#pragma mark:- Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MoreCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Profile";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 1) {
        cell.textLabel.text = @"Playlists";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 2) {
        cell.textLabel.text = @"Notification Settings";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 3) {
        cell.textLabel.text = @"Invite People";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 4) {
        cell.textLabel.text = @"Terms Of Use";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 5) {
        cell.textLabel.text = @"Privacy Policy";
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 6) {
        cell.textLabel.text = @"How To";
    }
    else if(indexPath.row == 7) {
        if (self.userEmail != nil){
            cell.textLabel.text = @"Sign out";
        }else{
            cell.textLabel.text = @"Sign In";
        }
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
    else if(indexPath.row == 8) {
        NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        cell.textLabel.text = [NSString stringWithFormat:@"Build v%@(%@)", version, build];
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0) {
        if (self.userEmail != nil){
            DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
            dcProfileTableViewController.isSignedInUser = true;
            dcProfileTableViewController.profileUser = self.signedInUser;
            [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
        }else{
            [self pushToSignInVC:@"DCProfileTableViewController"];
        }
    }
    else if(indexPath.row == 1) {
        if (self.userEmail != nil){
            DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
            dcPlaylistsTableViewController.isFeedMode = false;
            dcPlaylistsTableViewController.isSignedInUser = true;
            [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
        }else{
            [self pushToSignInVC:@"DCPlaylistsTableViewController"];
        }
    }
    else if(indexPath.row == 2) {
        if (self.userEmail != nil){
            NotificationSettingsViewController *notificationSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSettingsViewController"];
            [self.navigationController pushViewController:notificationSettingsViewController animated:YES];
        }else{
            [self pushToSignInVC:@"NotificationSettingsViewController"];
        }
    }
    else if(indexPath.row == 3) {
        [self showAddressBook];
    }
    else if(indexPath.row == 4) {
        TermsConditionsViewController *termsConditionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsConditionsViewController"];
        
        termsConditionsViewController.urlToOpen = @"https://docs.google.com/document/d/e/2PACX-1vS2KQuYMEsZ6F5OEsEyCEidH-Afg8rFvjldhA_gbvVnO5nCFq6LK9yHA3bDLf8Qco5uumCsRyge7sPg/pub";
        termsConditionsViewController.title = @"Terms Of Use";
        [self.navigationController pushViewController:termsConditionsViewController animated:YES];
    }
    else if(indexPath.row == 5) {
        TermsConditionsViewController *termsConditionsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsConditionsViewController"];
        
        termsConditionsViewController.urlToOpen = @"https://docs.google.com/document/d/e/2PACX-1vQGAPSY9BYAXnlQC0GK0PXl3Uloa1HQrNDbpI4bpqMepMf3iGeAVYxfGkKrV3dl_HMv04hTt-27cOOg/pub";
        termsConditionsViewController.title = @"Privacy Policy";
        [self.navigationController pushViewController:termsConditionsViewController animated:YES];
    }
    else if(indexPath.row == 6) {
        [self.appDelegate switchTabToIndex:0];
        ECHowToViewController *addController = [self.storyboard instantiateViewControllerWithIdentifier:@"ECHowToViewController"];
        addController.providesPresentationContextTransitionStyle = YES;
        addController.definesPresentationContext = YES;
        [addController setModalPresentationStyle:UIModalPresentationOverFullScreen];
        //[self.navigationController presentViewController:addController animated:YES completion: nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window makeKeyAndVisible];
        [appDelegate.window.rootViewController presentViewController:addController animated:YES completion:NULL];
    }
    else if(indexPath.row == 7) {
        ECCommonClass *instance = [ECCommonClass sharedManager];
        if (self.userEmail != nil){
            instance.isUserLogoutTap = true;
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] signOut];
        }else{
            instance.isUserLogoutTap = false;
            [self pushToSignInVC:@""];
        }
    }
    else if(indexPath.row == 8) {
        /*
        TestTableViewController *testTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TestTableViewController"];
        [self.navigationController pushViewController:testTableViewController animated:YES];
         */
    }
}

#pragma mark:- Addressbook Method

-(void)showAddressBook{
    CNContactPickerViewController *peoplePicker = [[CNContactPickerViewController alloc] init];
    peoplePicker.delegate = self;
//    NSArray *arrKeys = @[CNContactPhoneNumbersKey]; //display only phone numbers
//    peoplePicker.displayedPropertyKeys = arrKeys;
    [[UINavigationBar appearance] setTranslucent:NO];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark:- Instance Method

- (void)pushToSignInVC :(NSString*)stbIdentifier{
    UIStoryboard *signUpLoginStoryboard = [UIStoryboard storyboardWithName:@"SignUpLogin" bundle:nil];
    SignUpLoginViewController *signUpVC = [signUpLoginStoryboard instantiateViewControllerWithIdentifier:@"SignUpLoginViewController"];
    signUpVC.delegate = self;
    signUpVC.hidesBottomBarWhenPushed = YES;
    signUpVC.storyboardIdentifierString = stbIdentifier;
    [self.navigationController pushViewController:signUpVC animated:true];
}


-(void)sendToSpecificVC:(NSString*)identifier{
    if([identifier isEqualToString:@"DCProfileTableViewController"]) {
        DCProfileTableViewController *dcProfileTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCProfileTableViewController"];
        dcProfileTableViewController.isSignedInUser = true;
        dcProfileTableViewController.profileUser = self.signedInUser;
        [self.navigationController pushViewController:dcProfileTableViewController animated:YES];
    }
    else if([identifier isEqualToString:@"DCPlaylistsTableViewController"]) {
        DCPlaylistsTableViewController *dcPlaylistsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DCPlaylistsTableViewController"];
        dcPlaylistsTableViewController.isSignedInUser = true;
        dcPlaylistsTableViewController.isFeedMode = false;
        [self.navigationController pushViewController:dcPlaylistsTableViewController animated:YES];
    }
    else if([identifier isEqualToString:@"NotificationSettingsViewController"]) {
        NotificationSettingsViewController *notificationSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSettingsViewController"];
        [self.navigationController pushViewController:notificationSettingsViewController animated:YES];
    }
}

#pragma mark:- SignUpLoginDelegate Methods

- (void)didTapLoginButton:(NSString *)storyboardIdentifier{
    NSLog(@"didTapLoginButton: MoreVC: storyboardIdentifier: %@", storyboardIdentifier);
    [self sendToSpecificVC:storyboardIdentifier];
}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
//    CNLabeledValue *emailValue = contactProperty.contact.emailAddresses.firstObject;
//    NSString *emailString = emailValue.value;
//    
//    CNLabeledValue *phoneNumberValue = contactProperty.contact.phoneNumbers.firstObject;
//    CNPhoneNumber *phoneNumber = phoneNumberValue.value;
//    NSString *phoneNumberString = phoneNumber.stringValue;
//}

@end
