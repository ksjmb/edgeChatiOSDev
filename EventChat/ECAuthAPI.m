//
//  ECAuthAPI.m
//  EventChat
//
//  Created by Jigish Belani on 7/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "ECAuthAPI.h"

@implementation ECAuthAPI

//static NSString * const kClientBaseURL  = @"http://localhost:3000/api";
static NSString * const kClientID       = @"iOS";
static NSString * const kClientSecret   = @"7A1017A3-7309-4F7F-8F88-F32B11EFB71A";

+ (ECAuthAPI *)sharedClient {
    static ECAuthAPI *_sharedClient = nil;
    static dispatch_once_t _onceToken;
    
    dispatch_once(&_onceToken, ^{
        NSURL *url = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]];
        _sharedClient = [ECAuthAPI clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
    });
    
    return _sharedClient;
}

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure {
    NSLog(@"[ECAuthAPI signInWithUsernameAndPassword]");
    //**@kj_undo_change
    
//    [self authenticateUsingOAuthWithURLString:@"/rest/v4/oauth/token"
     [self authenticateUsingOAuthWithURLString:@"/rest/v3/oauth/token"
                                username:username
                                password:password
                                   scope:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"]
                                 success:^(AFOAuthCredential *credential) {
                                     NSLog(@"[ECAuthAPI signInWithUsernameAndPassword]: received access token %@", credential.accessToken);
                                     
                                     [AFOAuthCredential storeCredential:credential withIdentifier:self.serviceProviderIdentifier];
                                     
                                     if (success) {
                                         success(credential);
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(error);
                                 }];
}

- (void)signInWithEmailAndPassword:(NSString *)email
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure {
    NSLog(@"[ECAuthAPI signInWithEmailAndPassword]");
    //**@kj_undo_change
//    [self authenticateUsingOAuthWithURLString:@"/rest/v4/oauth/token"
     [self authenticateUsingOAuthWithURLString:@"/rest/v3/oauth/token"
                                     email:email
                                     password:password
                                        scope:@"edgetvchat_dev"
                                      success:^(AFOAuthCredential *credential) {
                                          NSLog(@"[ECAuthAPI signInWithUsernameAndPassword]: received access token %@", credential.accessToken);
                                          
                                          [AFOAuthCredential storeCredential:credential withIdentifier:self.serviceProviderIdentifier];
                                          
                                          if (success) {
                                              success(credential);
                                          }
                                      }
                                      failure:^(NSError *error) {
                                          NSLog(@"Error: %@", error);
                                          failure(error);
                                      }];
}

- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure
{
    NSLog(@"[ECAuthAPI refreshTokenWithSuccess]");
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential == nil) {
        NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: credential is nil");
        if (failure) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:errorDetail];
            failure(error);
        }
        return;
    }
    
    NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: refreshing credential, credential.refreshToken: %@", credential.refreshToken);
    //**@kj_undo_change
    [self authenticateUsingOAuthWithURLString:@"/rest/v3/oauth/token"
                                 refreshToken:credential.refreshToken
                                        scope:@"edgetvchat_dev"
                                      success:^(AFOAuthCredential *newCredential) {
                                          NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: refreshed access token %@", newCredential.accessToken);
                                          [AFOAuthCredential storeCredential:newCredential withIdentifier:self.serviceProviderIdentifier];
                                          
                                          if (success) {
                                              success(newCredential);
                                          }
                                      }
                                      failure:^(NSError *error) {
                                          NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: an error occurred refreshing credential: %@", error);
                                          if (failure) {
                                              failure(error);
                                          }
                                      }];

    /*
    [self authenticateUsingOAuthWithURLString:@"/rest/v4/oauth/token"
                            refreshToken:credential.refreshToken
                                        scope:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"]
                                 success:^(AFOAuthCredential *newCredential) {
                                     NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: refreshed access token %@", newCredential.accessToken);
                                     [AFOAuthCredential storeCredential:newCredential withIdentifier:self.serviceProviderIdentifier];
                                     
                                     if (success) {
                                         success(newCredential);
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"[ECAuthAPI refreshTokenWithSuccess]: an error occurred refreshing credential: %@", error);
                                     if (failure) {
                                         failure(error);
                                     }
                                 }];
     */
}

- (void)signOut {
    [AFOAuthCredential deleteCredentialWithIdentifier:self.serviceProviderIdentifier];
}

- (bool)isSignInRequired {
    AFOAuthCredential *credential = [self retrieveCredential];
    if (credential == nil) {
        return true;
    }
    
    return false;
}

- (AFOAuthCredential *)retrieveCredential
{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
}

- (void)updateCredential:(AFOAuthCredential *)credential{
    [AFOAuthCredential storeCredential:credential
                        withIdentifier:self.serviceProviderIdentifier];
}

@end
