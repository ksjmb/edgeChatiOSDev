//
//  ECHTTPRequestOperationManager.h
//  EventChat
//
//  Created by Jigish Belani on 2/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class AFOAuthCredential;

@interface ECHTTPRequestOperationManager : AFHTTPRequestOperationManager

+ (ECHTTPRequestOperationManager *)sharedManager;
+ (ECHTTPRequestOperationManager *)sharedManager:(NSString *)baseUrl;
+ (ECHTTPRequestOperationManager *)sharedManagerDCWeb;
+ (ECHTTPRequestOperationManager *)sharedManagerDCWeb:(NSString *)baseUrl;
+ (ECHTTPRequestOperationManager *)sharedManagerDCNoAuth;
+ (ECHTTPRequestOperationManager *)sharedManagerDCNoAuth:(NSString *)baseUrl;
+ (ECHTTPRequestOperationManager *)sharedManagerDCBasicAuth;
+ (ECHTTPRequestOperationManager *)sharedManagerDCBasicAuth:(NSString *)baseUrl;
+ (ECHTTPRequestOperationManager *)sharedManagerDC;
+ (ECHTTPRequestOperationManager *)sharedManagerDC:(NSString *)baseUrl;
+ (ECHTTPRequestOperationManager *)sharedManagerGoogle;
+ (ECHTTPRequestOperationManager *)sharedManagerGoogle:(NSString *)baseUrl;

@end
