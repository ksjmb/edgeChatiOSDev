//
//  ConnectionManager.h
//  LVP Client IOS
//
//  Created by Ayush Jain on 14/04/17.
//  Copyright (c) 2012 ayush.jain@mindbowser.com. All rights reserved.
//



#import <Foundation/Foundation.h>

@class Reachability;
@interface ConnectionManager : NSObject
{    
    Reachability* internetReach;
    Reachability *wifiReach;
    NSURLConnection *connection;
    int countForFacebookAlert;
    NSMutableDictionary *paramForFacebookPost;
}


@property (nonatomic, retain) NSURLConnection *connection;
@property(nonatomic,assign) int countForFacebookAlert;
@property(nonatomic,retain) NSMutableDictionary *paramForFacebookPost;

+ (BOOL)currentNetworkStatus;
+(ConnectionManager *)sharedConnectionManager;
//-(void)callAPI:(NSString *)API withDictionary:(NSDictionary *)dictionary forConnectionDelegateObject:(NSObject *)object;

@end
