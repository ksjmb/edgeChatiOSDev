//
//  ConnectionManager.m
//  LVP Client IOS
//
//  Created by Ayush Jain on 14/08/12.
//  Copyright (c) 2012 ayush.jain@mindbowser.com. All rights reserved.
//

#import "ConnectionManager.h"
#import "Reachability.h"

@implementation ConnectionManager
{
    NSString *selfAPI;
    NSDictionary *selfDictionary;
    NSObject *selfObject;
    BOOL internetActive;
}

@synthesize connection;
@synthesize countForFacebookAlert;
@synthesize paramForFacebookPost;


BOOL connectionRequired;
static ConnectionManager *sharedConnectionManager = nil;

+(ConnectionManager *)sharedConnectionManager
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{ sharedConnectionManager = [[self alloc] init]; });
    }
    return sharedConnectionManager;
}

-(id)init
{
    if (self=[super init]) 
    {
        // subscribe to notification
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called. 
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
                
        internetReach = [Reachability reachabilityForInternetConnection];
        [internetReach startNotifier];
        
//        wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
//        [wifiReach startNotifier];
        
        connectionRequired= [internetReach connectionRequired];
	}
    return self;
}

+ (BOOL)currentNetworkStatus
{
    //	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	BOOL connected;
	const char *host = "www.apple.com";
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
	SCNetworkReachabilityFlags flags;
	connected = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL isConnected = NO;
	isConnected = connected && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	    
	return isConnected;
}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    connectionRequired= [curReach connectionRequired];
    
    //[self callAPI:selfAPI withDictionary:selfDictionary forConnectionDelegateObject:selfObject];
}




@end
