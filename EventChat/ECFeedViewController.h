//
//  ECFeedViewController.h
//  EventChat
//
//  Created by Jigish Belani on 1/31/16.
//  Copyright © 2016 Apex Ventures, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECFeedCell.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//
#import "ECNewTableViewCell.h"
#import "SignUpLoginViewController.h"

@class AFOAuthCredential;

//@interface ECFeedViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ECFeedCellDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIActionSheetDelegate, FBSDKSharingDelegate, UISearchResultsUpdating>
@interface ECFeedViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ECNewTableViewCellDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIActionSheetDelegate, FBSDKSharingDelegate, UISearchResultsUpdating, SignUpLoginViewControllerDelegate>

@property (retain, nonatomic) NSString *sbIdentifierString;
@property (nonatomic, assign) BOOL isCommingFromLogin;

-(void)pushToSignInVC;
@end
