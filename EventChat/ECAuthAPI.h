//
//  ECAuthAPI.h
//  EventChat
//
//  Created by Jigish Belani on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import <AFOAuth2Manager/AFOAuth2Manager.h>

@interface ECAuthAPI : AFOAuth2Manager

+ (ECAuthAPI *)sharedClient;

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure;

- (void)signInWithEmailAndPassword:(NSString *)email
                          password:(NSString *)password
                           success:(void (^)(AFOAuthCredential *credential))success
                           failure:(void (^)(NSError *error))failure;

- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure;

- (void)signOut;

- (bool)isSignInRequired;

- (AFOAuthCredential *)retrieveCredential;
- (void)updateCredential:(AFOAuthCredential *)credential;

@end
