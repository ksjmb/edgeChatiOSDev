//
//  ECHTTPRequestOperationManager.m
//  EventChat
//
//  Created by Jigish Belani on 2/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECHTTPRequestOperationManager.h"
#import "AFOAuth2Manager.h"
#import "ECAuthAPI.h"

static NSString * const kEvenBriteAuthToken = @"GNXIQJKH5EJNBBGXDQP6";
static NSString * const ECHTTPBasePath = @"https://www.eventbriteapi.com";
//static NSString * const ECHTTPBasePathDC = @"http://eventchat-dev-v2.us-west-1.elasticbeanstalk.com";
//static NSString * const ECHTTPBasePathDC = @"http://localhost:3000/api";
static NSString * const ECHTTPBasePathGoogle = @"https://maps.googleapis.com";
static NSString * const DCWebBasePath = @"http://www.diddychat.com";
@implementation ECHTTPRequestOperationManager

+ (instancetype)sharedManager
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:ECHTTPBasePath];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManager:(NSString *)baseUrl{
    {
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:baseUrl];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
        sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    return sharedInstance;
    }
}

#pragma mark - DiddyChat Web
+ (instancetype)sharedManagerDCWeb
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:DCWebBasePath];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManagerDCWeb:(NSString *)baseUrl{
    {
        static ECHTTPRequestOperationManager *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *baseURL = [NSURL URLWithString:baseUrl];
            sharedInstance = [[self alloc] initWithBaseURL:baseURL];
            sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        });
        return sharedInstance;
    }
}


#pragma mark - DiddyChat no Auth
+ (instancetype)sharedManagerDCNoAuth
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
        [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManagerDCNoAuth:(NSString *)baseUrl{
    {
        static ECHTTPRequestOperationManager *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *baseURL = [NSURL URLWithString:baseUrl];
            sharedInstance = [[self alloc] initWithBaseURL:baseURL];
            sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
        });
        return sharedInstance;
    }
}

#pragma mark - DiddyChat Basic Auth
+ (instancetype)sharedManagerDCBasicAuth
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
        [sharedInstance.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Basic Auth Token"]] forHTTPHeaderField:@"Authorization"];
        [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManagerDCBasicAuth:(NSString *)baseUrl{
    {
        static ECHTTPRequestOperationManager *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *baseURL = [NSURL URLWithString:baseUrl];
            sharedInstance = [[self alloc] initWithBaseURL:baseURL];
            sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
            [sharedInstance.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Basic Auth Token"]] forHTTPHeaderField:@"Authorization"];
            [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
        });
        return sharedInstance;
    }
}

#pragma mark - DiddyChat
+ (instancetype)sharedManagerDC
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
        sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        AFOAuthCredential *credential = [[ECAuthAPI sharedClient] retrieveCredential];
        [sharedInstance.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credential.accessToken] forHTTPHeaderField:@"Authorization"];
        [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManagerDC:(NSString *)baseUrl{
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:baseUrl];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
        sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        AFOAuthCredential *credential = [[ECAuthAPI sharedClient] retrieveCredential];
        [sharedInstance.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credential.accessToken] forHTTPHeaderField:@"Authorization"];
        [sharedInstance.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
    });
    return sharedInstance;
    }
}

#pragma mark - Google
+ (instancetype)sharedManagerGoogle
{
    static ECHTTPRequestOperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:ECHTTPBasePathGoogle];
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
    });
    return sharedInstance;
}

+ (ECHTTPRequestOperationManager *)sharedManagerGoogle:(NSString *)baseUrl{
    {
        static ECHTTPRequestOperationManager *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *baseURL = [NSURL URLWithString:baseUrl];
            sharedInstance = [[self alloc] initWithBaseURL:baseURL];
            sharedInstance.responseSerializer.acceptableContentTypes = [sharedInstance.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        });
        return sharedInstance;
    }
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    // Add any headers values etc. here
    
    AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:mutableRequest success:success failure:failure];
    return operation;
}



@end
