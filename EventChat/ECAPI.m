//
//  ECAPI.m
//  EventChat
//
//  Created by Jigish Belani on 2/4/16.
//  Copyright © 2016 Jigish Belani. All rights reserved.
//

#import "ECAPI.h"
#import "ECAppInfo.h"
#import "NSObject+TypeValidation.h"
#import "ECEventBriteSearchResult.h"
#import "ECEventBriteEventList.h"
#import "ECUser.h"
#import "ECComment.h"
#import "ECNotification.h"
#import "ECEventBriteVenue.h"
#import "ECTopic.h"
#import "ECAttendee.h"
#import "ECEvent.h"
#import "ECEventBriteEvent.h"
#import "AFOAuth2Manager.h"
#import "ECAuthAPI.h"
#import "DCFeedItem.h"
#import "DCDigital.h"
#import "DCPlaylist.h"
#import "DCFeedItemCategory.h"
#import "DCFeedItemFilter.h"
#import "DCPost.h"

typedef void (^DCNodeApiClientRetryBlock)(AFHTTPRequestOperation *task, NSError *error);
typedef AFHTTPRequestOperation *(^DCNodeApiClientCreateTask)(DCNodeApiClientRetryBlock retryBlock);

static NSString * const kEvenBriteAuthToken = @"GNXIQJKH5EJNBBGXDQP6";
static NSString * const kGoogleAPIKey = @"AIzaSyAvHDxO6C13Zi3sMFCewFBzczyyIR5MT0I";
//static NSString * const kBaseURL = @"http://localhost:3000/api";
static NSString * const kClientID = @"iOS";
static NSString * const kClientSecret = @"7A1017A3-7309-4F7F-8F88-F32B11EFB71A";
static const int kRetryCount = 3;

@interface ECAPI()
@property (nonatomic, strong) ECUser *signedInUser;
@end

@implementation ECAPI

#pragma mark - Singleton methods
+(id)sharedManager
{
    static ECAPI *sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
//        NSURL *baseURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]];
//        sharedManager = [[self alloc] initWithBaseURL:baseURL];
//        AFOAuthCredential *credential = [[ECAuthAPI sharedClient] retrieveCredential];
//        [sharedManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credential.accessToken] forHTTPHeaderField:@"Authorization"];
//        [sharedManager.requestSerializer setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"DBName"] forHTTPHeaderField:@"x-key-db"];
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Accessors
- (void)updateSignedInUser:(ECUser *)ecUser{
//    self.signedInUser = ecUser;
}

#pragma mark - API authorization
- (void)updateCredential:(AFOAuthCredential *)credential
{
    [[ECAuthAPI sharedClient] updateCredential:credential];
    [[ECHTTPRequestOperationManager sharedManagerDC].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", credential.accessToken] forHTTPHeaderField:@"Authorization"];
}

- (void)refreshAccessToken:(DCNodeApiClientCreateTask)createTaskBlock failure:(DCNodeApiClientFailure)failure retryCount:(int)retryCount
{
    ECAuthAPI *oauthClient = [ECAuthAPI sharedClient];
    [oauthClient refreshTokenWithSuccess:^(AFOAuthCredential *newCredential) {
        NSLog(@"[ECAPI taskWithRetry]: refreshed access token");
        [self updateCredential:newCredential];
        [self taskWithRetry:createTaskBlock failure:failure retryCount:retryCount];
    } failure:^(NSError *error) {
        NSLog(@"[ECAPI taskWithRetry]: failed to refresh access token");
        if (failure) {
            failure(nil, error);
        }
    }];
}

- (void)taskWithRetry:(DCNodeApiClientCreateTask)createTaskBlock failure:(DCNodeApiClientFailure)failure retryCount:(int)retryCount
{
    DCNodeApiClientFailure retryBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[ECAPI taskWithRetry] failure: retryCount: %d", retryCount);
        
        if (retryCount > 0) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 401) {
                NSLog(@"[ECAPI taskWithRetry]: 401 unauthorised");
                [self refreshAccessToken:createTaskBlock failure:failure retryCount:retryCount - 1];
            }
            else {
                NSLog(@"[ECAPI taskWithRetry]: retrying");
                [self taskWithRetry:createTaskBlock failure:failure retryCount:retryCount - 1];
            }
        }
        else {
            NSLog(@"[ECAPI taskWithRetry]: failed");
            if (failure) {
                failure(task, error);
            }
        }
    };
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]] host]];
    if (credential.isExpired) {
        NSLog(@"[ECAPI taskWithRetry]: access token has expired");
        [self refreshAccessToken:createTaskBlock failure:failure retryCount:retryCount];
    }
    else {
        createTaskBlock(retryBlock);
    }
}

- (AFOAuthCredential *)getCurrentCredentials{
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:[[NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"BaseAPIUrl"]] host]];
    return credential;
}

#pragma mark - App Info
- (void)getAppInfo:(NSString *)params failure:(DCNodeApiClientFailure)failure  callback:(void (^)(ECAppInfo *appInfo, NSError *error))callback{
    NSString *endpoint = @"/app/getAppInfo";
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManager]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *infoError = nil;
                                                   ECAppInfo *aAppInfo = [[ECAppInfo alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aAppInfo, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient getProductsWithSuccess]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
    
    [[ECHTTPRequestOperationManager sharedManager]
     GET:endpoint
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         NSError *infoError = nil;
         ECAppInfo *aAppInfo = [[ECAppInfo alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
         if (infoError) {
             NSLog(@"Error fetching app info: %@", infoError);
         }
         callback(aAppInfo, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

#pragma mark - FeedItem calls
- (void)getFeedItems:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/feeditems/all";
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFeedItemById:(NSString *)feedItemId callback:(void (^)(DCFeedItem *dcFeedItem, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/%@", feedItemId];;
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *dcFeedItemError = nil;
                                                   DCFeedItem *aDCFeedItem = [[DCFeedItem alloc] initWithDictionary:responseDictionary[@"data"] error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(aDCFeedItem, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFeedItemCategories:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/feeditems/categories/all";
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemCategoryDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemCategoryError = nil;
                                                   NSMutableArray *dcFeedItemCategories = [[NSMutableArray alloc] init];
                                                   DCFeedItemCategory *newFeedItemCategory = [[DCFeedItemCategory alloc] init];
                                                   newFeedItemCategory.name = @"influencers";
                                                   newFeedItemCategory.type = @"entity";
                                                   [dcFeedItemCategories addObject:newFeedItemCategory];
                                                   [dcFeedItemCategories addObjectsFromArray:[DCFeedItemCategory arrayOfModelsFromDictionaries:dcFeedItemCategoryDictionaries error:&dcFeedItemCategoryError]];
                                                   
//                                                   NSMutableArray *categories = [[NSMutableArray alloc] init];
//                                                   [categories addObject:@"all"];
//                                                   [categories addObject:@"influencers"];
//                                                   for(int i = 0; i < [dcFeedItemCategories count]; i++){
//                                                       DCFeedItemCategory *category = [dcFeedItemCategories  objectAtIndex:i];
//                                                       [categories addObject:category.name];
//                                                   }
                                                   if (dcFeedItemCategoryError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemCategoryError);
                                                   }
                                                   callback(dcFeedItemCategories, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFeedItemFilters:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/feeditems/filters/all";
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemFilterDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemFilterError = nil;
                                                   NSMutableArray *dcFeedItemFilters = [[NSMutableArray alloc] initWithArray:[DCFeedItemFilter arrayOfModelsFromDictionaries:dcFeedItemFilterDictionaries error:&dcFeedItemFilterError]];
                                               
                                                   if (dcFeedItemFilterError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemFilterError);
                                                   }
                                                   callback(dcFeedItemFilters, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)filterFeedItemsByCatagory:(NSString *)category callback:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *encodedParams = [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/filterFeedItemsByCatetory/%@", encodedParams];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)filterFeedItemsByEntityType:(NSString *)category callback:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *encodedParams = [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/filterFeedItemsByEntityType/%@", encodedParams];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}
//** 1st time api call from feedVC **//
- (void)filterFeedItemsByFilterObject:(DCFeedItemFilter *)filter callback:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/filterFeedItemsByFilterObject"];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        NSLog(@"here now");
        AFOAuthCredential *credential = [[ECAuthAPI sharedClient] retrieveCredential];
        NSLog(@"credential.accessToken: %@", credential.accessToken);
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:[filter toDictionary]
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:retryBlock];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)searchFeedItemsByText:(NSString *)keywords callback:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *encodedParams = [keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/searchFeedItemsByText/%@", encodedParams];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSDictionary *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries[@"results"] error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getRelatedEpisodes:(NSString *)series callback:(void (^)(NSArray *searchResult, NSError *error))callback{
    NSString *encodedParams = [series stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feeditems/getRelatedEpisodes/%@", encodedParams];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcFeedItemDictionaries = responseDictionary[@"data"];
                                                   NSError *dcFeedItemError = nil;
                                                   NSArray *dcFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:dcFeedItemDictionaries error:&dcFeedItemError];
                                                   if (dcFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", dcFeedItemError);
                                                   }
                                                   callback(dcFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFeedItems]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - EventBrite calls
- (void)getEventsByLocation:(NSString *)params callback:(void (^)(ECEventBriteSearchResult *searchResult, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/v3/events/search?%@", params];
    NSLog(@"LocationParams: %@", params);
    [[ECHTTPRequestOperationManager sharedManager]
     GET:endpoint
     parameters:@{@"token": kEvenBriteAuthToken}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         NSLog(@"%@", responseDictionary);
         NSError *infoError = nil;
         ECEventBriteSearchResult *aSearchResult = [[ECEventBriteSearchResult alloc] initWithDictionary:responseDictionary error:&infoError];
         NSMutableArray *aEventList = [[NSMutableArray alloc] initWithArray:[responseDictionary objectForKey:@"events"]];
         aSearchResult.events = aEventList;
         if (infoError) {
             NSLog(@"Error fetching app info: %@", infoError);
         }
         callback(aSearchResult, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

- (void)getEventsByEventId:(NSString *)params callback:(void (^)(ECEventBriteEvent *searchResult, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/v3/events/%@", params];
    NSLog(@"LocationParams: %@", params);
    [[ECHTTPRequestOperationManager sharedManager]
     GET:endpoint
     parameters:@{@"token": kEvenBriteAuthToken}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         NSLog(@"%@", responseDictionary);
         NSError *infoError = nil;
         ECEventBriteEvent *aSearchResult = [[ECEventBriteEvent alloc] initWithDictionary:responseDictionary error:&infoError];
         if (infoError) {
             NSLog(@"Error fetching app info: %@", infoError);
         }
         callback(aSearchResult, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

- (void)searchEventsByText:(NSString *)params callback:(void (^)(ECEventBriteSearchResult *searchResult, NSError *error))callback{
    NSString *encodedParams = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *endpoint = [NSString stringWithFormat:@"/v3/events/search?%@", encodedParams];
    
    [[ECHTTPRequestOperationManager sharedManager]
     GET:endpoint
     parameters:@{@"token": kEvenBriteAuthToken}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         
         NSError *infoError = nil;
         ECEventBriteSearchResult *aSearchResult = [[ECEventBriteSearchResult alloc] initWithDictionary:responseDictionary error:&infoError];
         NSMutableArray *aEventList = [[NSMutableArray alloc] initWithArray:[responseDictionary objectForKey:@"events"]];
         aSearchResult.events = aEventList;
         if (infoError) {
             NSLog(@"Error fetching app info: %@", infoError);
         }
         callback(aSearchResult, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

- (void)getEventVenueDetailsById:(NSString *)params callback:(void (^)(ECEventBriteVenue *ecEventBriteVenue, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/v3/venues/%@", params];
    
    [[ECHTTPRequestOperationManager sharedManager]
     GET:endpoint
     parameters:@{@"token": kEvenBriteAuthToken}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         
         NSError *infoError = nil;
         ECEventBriteVenue *aECEventBriteVenue = [[ECEventBriteVenue alloc] initWithDictionary:responseDictionary error:&infoError];
         if (infoError) {
             NSLog(@"Error fetching app info: %@", infoError);
         }
         callback(aECEventBriteVenue, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

#pragma mark - EventChat calls
- (void)checkIfEmailExists:(NSString *)email callback:(void (^)(BOOL alreadyExists, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/checkIfEmailExists/%@", email];
    
    [[ECHTTPRequestOperationManager sharedManagerDCBasicAuth]
     GET:endpoint
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         BOOL aAlreadyExists = false;
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         int statusCode = [[responseDictionary objectForKey:@"statusCode"] intValue];
         
         if(statusCode == 200){
             aAlreadyExists = TRUE;
         }
         else{
             aAlreadyExists = false;
         }
         
         callback(aAlreadyExists, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}
- (void)getUserByEmail:(NSString *)email callback:(void (^)(ECUser *ecUser, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/email/%@", email];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *aECUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   self.signedInUser = aECUser;
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aECUser, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getUserWithSuccess]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getUserByUsername:(NSString *)username callback:(void (^)(ECUser *ecUser, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/username/%@", username];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *aECUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   self.signedInUser = aECUser;
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aECUser, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getUserWithSuccess]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
    
    
}

#pragma mark - Sign In / Out

- (void)signInUserWithEmail:(NSString *)email callback:(void (^)(NSError *error))callback
{
    if (email.length == 0) {
        NSLog(@"Invalid email address");
        //TODO: Pass a real error back
        callback([NSError errorWithDomain:@"com.eventchat" code:0 userInfo:nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/email/%@", email];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *userError = nil;
                                                   ECUser *aUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&userError];
                                                   if (userError) {
                                                       NSLog(@"Error fetching user with email: %@", userError);
                                                   }
                                                   
                                                   self.signedInUser = aUser;
                                                   if (!self.signedInUser) {
                                                       NSLog(@"No user returned");
                                                       callback([NSError errorWithDomain:@"com.eventhat" code:0 userInfo:nil]);
                                                   } else {
                                                       [[NSUserDefaults standardUserDefaults] setObject:self.signedInUser.email forKey:@"SignedInUserEmail"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       callback(nil);
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient signInUserWithEmail]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)signInUserWithEmail:(NSString *)email password:(NSString *)password callback:(void (^)(NSError *error))callback
{
    if (email.length == 0) {
        NSLog(@"Invalid email address");
        //TODO: Pass a real error back
        callback([NSError errorWithDomain:@"com.eventchat" code:0 userInfo:nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/login/%@/%@", email, password];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *userError = nil;
                                                   ECUser *aUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&userError];
                                                   if (userError) {
                                                       NSLog(@"Error fetching user with email: %@", userError);
                                                   }
                                                   
                                                   self.signedInUser = aUser;
                                                   if (!self.signedInUser) {
                                                       NSLog(@"No user returned");
                                                       callback([NSError errorWithDomain:@"com.eventhcat" code:0 userInfo:nil]);
                                                   } else {
                                                       [[NSUserDefaults standardUserDefaults] setObject:self.signedInUser.email forKey:@"SignedInUserEmail"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       callback(nil);
                                                   }
                                                   
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient signInUserWithEmail]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)signInUserWithSocialUserId:(NSString *)socialUserId callback:(void (^)(NSError *error))callback
{
    if (socialUserId.length == 0) {
        NSLog(@"Invalid socialUserId");
        //TODO: Pass a real error back
        callback([NSError errorWithDomain:@"com.eventchat" code:0 userInfo:nil]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/social/%@", socialUserId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *userError = nil;
                                                   ECUser *aUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&userError];
                                                   if (userError) {
                                                       NSLog(@"Error fetching user with email: %@", userError);
                                                   }
                                                   
                                                   self.signedInUser = aUser;
                                                   if (!self.signedInUser) {
                                                       NSLog(@"No user returned");
                                                       callback([NSError errorWithDomain:@"com.eventhat" code:0 userInfo:nil]);
                                                   } else {
                                                       [[NSUserDefaults standardUserDefaults] setObject:self.signedInUser.email forKey:@"SignedInUserEmail"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       callback(nil);
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient signInUserWithSocialUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
    
    
}

- (void)signOutUser
{
    //???: Do we want to be this aggressive? Fine for now since everything is couple-centric. Later maybe not.
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    self.signedInUser = nil;
}

#pragma mark - User
- (void)fetchUserByUserId:(NSString *)userId
                   callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/singleUser/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   self.signedInUser = responseUser;
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchUserByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)createUserWithSocial:(NSString *)userEmail
                   firstName:(NSString *)firstName
                    lastName:(NSString *)lastName
                 deviceToken:(NSString *)deviceToken
              facebookUserId:(NSString *)facebookUserId
                googleUserId:(NSString *)googleUserId
               twitterUserId:(NSString *)twitterUserId
               socialConnect:(NSString *)socialConnect
                    username:(NSString *)username
                    password:(NSString *)password
                    callback:(void (^)(NSError *error))callback{
    NSString *endpoint = @"/rest/v4/users/create";
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"email"] = userEmail;
    mutableParameters[@"firstName"] = firstName;
    mutableParameters[@"lastName"] = lastName;
    mutableParameters[@"deviceToken"] = deviceToken;
    mutableParameters[@"facebookUserId"] = facebookUserId;
    mutableParameters[@"googleUserId"] = googleUserId;
    mutableParameters[@"twitterUserId"] = twitterUserId;
    mutableParameters[@"socialConnect"] = socialConnect;
    mutableParameters[@"username"] = username;
    mutableParameters[@"password"] = password;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
//    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
//        AFHTTPRequestOperation *createdTask =
//        return createdTask;
//    };
//    
//    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
//        NSLog(@"[DCNodeApiClient createUserWithSocial]: error %@", error);
//    };
//    
//    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
    
    [[ECHTTPRequestOperationManager sharedManagerDCNoAuth]
     POST:endpoint
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         
         NSError *infoError = nil;
         ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
         
         if (infoError) {
             NSLog(@"Error fetching user by email: %@", infoError);
             callback(infoError);
             return;
         }
         self.signedInUser = responseUser;
         callback(nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Failure:%@",error.localizedDescription);
         
         callback(error);
     }];
}

- (void)updateProfilePicUrl:(NSString *)userId
              profilePicUrl:(NSString *)profilePicUrl
                       callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/update/profilePicUrl/%@", userId];
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"profilePicUrl"] = profilePicUrl;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   self.signedInUser = responseUser;
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient updateProfilePicUrl]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)clearNotificationCount:(NSString *)userId
                   callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/notifications/clearNotificationCount/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient clearNotificationCount]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getAllUsers:(void (^)(NSArray *users, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/all"];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   NSMutableArray *aUsers = [[NSMutableArray alloc] initWithArray:[responseDictionary objectForKey:@"data"]];
                                                   NSLog(@"All Users: %@", aUsers);
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aUsers, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getAllUsers]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)updateUser:(ECUser *)ecUser
                   callback:(void (^)(ECUser *ecUser, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/updateUser/%@", ecUser.userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:[ecUser toDictionary]
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseUser, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient updateProfilePicUrl]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Follow feature methods
- (void)getFollowers:(NSString *)userId callback:(void (^)(NSArray *users, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/%@/followers", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   NSMutableArray *aUsers = [[NSMutableArray alloc] initWithArray:[responseDictionary objectForKey:@"data"]];
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aUsers, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFollowers]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFollowing:(NSString *)userId callback:(void (^)(NSArray *users, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/%@/followees", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   NSMutableArray *aUsers = [[NSMutableArray alloc] initWithArray:[responseDictionary objectForKey:@"data"]];
                                                   if (infoError) {
                                                       NSLog(@"Error fetching app info: %@", infoError);
                                                   }
                                                   callback(aUsers, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFollowing]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)followUserByUserId:(NSString *)userId followeeId:(NSString *)followeeId callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/%@/followees/%@", userId, followeeId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   self.signedInUser = responseUser;
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient followUserByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)unfollowUserByUserId:(NSString *)userId followeeId:(NSString *)followeeId callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/users/%@/followees/%@", userId, followeeId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               DELETE:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   ECUser *responseUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&infoError];
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   self.signedInUser = responseUser;
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient unfollowUserByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Comments
- (void)postComment:(NSString *)topicId
            feedItemId:(NSString *)feedItemId
            userId:(NSString *)userId
       displayName:(NSString *)displayName
           content:(NSString *)content
          parentId:(NSString *)parentId
             postId:(NSString *)postId
          callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/comments/add";
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"topicId"] = topicId;
    mutableParameters[@"feedItemId"] = feedItemId;
    mutableParameters[@"userId"] = userId;
    mutableParameters[@"displayName"] = displayName;
    mutableParameters[@"content"] = content;
    mutableParameters[@"parentId"] = parentId;
    mutableParameters[@"postId"] = postId;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding comment: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient postComment]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}
-(void)postImageComment:(NSString *)topicId
                feedItemId:(NSString *)feedItemId
                 userId:(NSString *)userId
            displayName:(NSString *)displayName
       imageSizeInBytes:(NSInteger )imageSize
           thumbnailURL:(NSString *)thumbnailURL
               imageURL:(NSString *)imageURL
            commentType:(NSString *)commentType
               parentId:(NSString *)parentId
                 postId:(NSString *)postId
               callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback {
    
    NSString *endpoint = @"/rest/v4/comments/add";
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"topicId"]               = topicId;
    mutableParameters[@"feedItemId"]            = feedItemId;
    mutableParameters[@"userId"]                = userId;
    mutableParameters[@"displayName"]           = displayName;
    mutableParameters[@"commentType"]           = commentType;
    mutableParameters[@"parentId"]              = parentId;
    mutableParameters[@"imageSizeInBytes"]      = [NSNumber numberWithInteger:imageSize];
    mutableParameters[@"thumbnailUrl"]          = thumbnailURL;
    if ([commentType isEqualToString:@"video"])
    {
        mutableParameters[@"videoUrl"]              = imageURL;
    }
    else
    {
        mutableParameters[@"imageUrl"]              = imageURL;
    }
    mutableParameters[@"parentId"]              = parentId;
    mutableParameters[@"postId"] = postId;

    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding comment: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient postImageComment]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
    
}
- (void)likeComment:(NSString *)commentId
             userId:(NSString *)userId
           callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
        NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/like/%@/%@", commentId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding comment: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient likeComment]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)reportComment:(NSString *)commentId
             userId:(NSString *)userId
           callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/report/%@/%@", commentId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding comment: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient reportComment]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)deleteCommentById:(NSString *)commentId
                  callback:(void (^)(ECComment *comment, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/%@", commentId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               DELETE:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *commentError = nil;
                                                   ECComment *aComment = [[ECComment alloc] initWithDictionary:responseDictionary[@"data"] error:&commentError];
                                                   
                                                   if (commentError) {
                                                       NSLog(@"Error deleting comment by Id: %@", commentError);
                                                       callback(nil, commentError);
                                                       return;
                                                   }
                                                   callback(aComment, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient deleteFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)fetchCommentsByTopicId:(NSString *)eventId callback:(void (^)(NSArray *comments, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/topic/%@", eventId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *commentDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *commentError = nil;
                                                   NSArray *comments = [ECComment arrayOfModelsFromDictionaries:commentDictionaries error:&commentError];
                                                   if (commentError) {
                                                       NSLog(@"Error fetching app info: %@", commentError);
                                                   }
                                                   callback(comments, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchCommentsByTopicId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)fetchCommentByCommentId:(NSString *)commentId callback:(void (^)(ECComment *ecComment, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/%@", commentId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *commentError = nil;
                                                   ECComment *aComment = [[ECComment alloc] initWithDictionary:responseDictionary[@"data"] error:&commentError];
                                                   
                                                   if (commentError) {
                                                       NSLog(@"Error fetching app info: %@", commentError);
                                                   }
                                                   callback(aComment, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchCommentByCommentId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];

}

- (void)fetchCommentsByPostId:(NSString *)postId callback:(void (^)(NSArray *comments, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/comments/getCommentsByPostId/%@", postId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *commentDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *commentError = nil;
                                                   NSArray *comments = [ECComment arrayOfModelsFromDictionaries:commentDictionaries error:&commentError];
                                                   if (commentError) {
                                                       NSLog(@"Error fetching app info: %@", commentError);
                                                   }
                                                   callback(comments, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchCommentsByTopicId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Posts
- (void)addPost:(DCPost *)post
       callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/posts/add";
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:[post toDictionary]
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding comment: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient postImageComment]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getPostByUserId:(NSString *)userId callback:(void (^)(NSArray *posts, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/posts/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *postDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *postError = nil;
                                                   NSArray *posts = [DCPost arrayOfModelsFromDictionaries:postDictionaries error:&postError];
                                                   if (postError) {
                                                       NSLog(@"Error fetching app info: %@", postError);
                                                   }
                                                   callback(posts, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchCommentsByTopicId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)deletePostById:(NSString *)postId
                 callback:(void (^)(NSArray *posts, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/posts/%@", postId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               DELETE:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *postDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *postError = nil;
                                                   NSArray *posts = [DCPost arrayOfModelsFromDictionaries:postDictionaries error:&postError];
                                                   if (postError) {
                                                       NSLog(@"Error fetching app info: %@", postError);
                                                   }
                                                   callback(posts, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient deleteFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getOthersPostByUserId:(NSString *)userId callback:(void (^)(NSArray *posts, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/posts/others/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *postDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *postError = nil;
                                                   NSArray *posts = [DCPost arrayOfModelsFromDictionaries:postDictionaries error:&postError];
                                                   if (postError) {
                                                       NSLog(@"Error fetching app info: %@", postError);
                                                   }
                                                   callback(posts, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchCommentsByTopicId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Topics
- (void)fetchTopicsByFeedItemId:(NSString *)feedItemId callback:(void (^)(NSArray *topics, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/topics/%@", feedItemId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *topicDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *topicError = nil;
                                                   NSArray *topics = [ECTopic arrayOfModelsFromDictionaries:topicDictionaries error:&topicError];
                                                   if (topicError) {
                                                       NSLog(@"Error fetching app info: %@", topicError);
                                                   }
                                                   callback(topics, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient fetchTopicsByEventId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)addTopic:(NSString *)eventId
             userId:(NSString *)userId
            content:(NSString *)content
           parentId:(NSString *)parentId
           callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
    NSString *endpoint = @"/rest/v4/topics/add";
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"eventId"] = eventId;
    mutableParameters[@"userId"] = userId;
    mutableParameters[@"content"] = content;
    mutableParameters[@"parentId"] = parentId;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding topic: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient addTopic]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Notifications
- (void)getNotificationsByUserId:(NSString *)userId callback:(void (^)(NSArray *notifications, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/notifications/user/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *notificationDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *notificationError = nil;
                                                   NSArray *notifications = [ECNotification arrayOfModelsFromDictionaries:notificationDictionaries error:&notificationError];
                                                   if (notificationError) {
                                                       NSLog(@"Error fetching app info: %@", notificationError);
                                                   }
                                                   callback(notifications, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getNotificationsByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)acknowledgeNotification:(NSString *)notificationId
                      callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/notifications/acknowledgeNotification/%@", notificationId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient acknowledgeNotification]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)archiveNotification:(NSString *)notificationId
                       callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/notifications/archiveNotification/%@", notificationId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               PUT:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient acknowledgeNotification]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Attendance
- (void)setAttendeeResponse:(NSString *)userId
                    feedItemId:(NSString *)feedItemId
                   response:(NSString *)response
                       callback:(void (^)(NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/attendees/setAttendeeResponse/%@/%@/%@", userId, feedItemId, response];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:[endpoint stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error fetching user by email: %@", infoError);
                                                       callback(infoError);
                                                       return;
                                                   }
                                                   callback(nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setAttendeeResponse]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getAttendeeResponse:(NSString *)userId
                 feedItemId:(NSString *)feedItemId
                   callback:(void (^)(ECAttendee *attendances, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/attendees/getAttendingFeedItemsByUserId/%@/%@", userId, feedItemId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   //NSArray *attendeeDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *attendeeError = nil;
                                                   ECAttendee *attendees = [[ECAttendee alloc] initWithDictionary:responseDictionary[@"data"] error:&attendeeError];
                                                   if (attendeeError) {
                                                       NSLog(@"Error fetching app info: %@", attendeeError);
                                                   }
                                                   callback(attendees, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getAttendeeResponse]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getAttendeeList:(NSString *)feedItemId
                        callback:(void (^)(NSArray *attendees, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/attendees/getAttendeeList/%@", feedItemId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *attendeeDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *attendeeError = nil;
                                                   NSArray *attendees = [ECAttendee arrayOfModelsFromDictionaries:attendeeDictionaries error:&attendeeError];
                                                   if (attendeeError) {
                                                       NSLog(@"Error fetching app info: %@", attendeeError);
                                                   }
                                                   callback(attendees, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getAttendeeList]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Event Methods
- (void)getECEventByEBEventId:(NSString *)eventId
               callback:(void (^)(NSArray *events, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/events/getEventDetailsById/%@", eventId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *ecEventDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *ecEventError = nil;
                                                   NSArray *ecEvents = [ECEvent arrayOfModelsFromDictionaries:ecEventDictionaries error:&ecEventError];
                                                   if (ecEventError) {
                                                       NSLog(@"Error fetching app info: %@", ecEventError);
                                                   }
                                                   callback(ecEvents, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getECEventByEBEventId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)setFavoriteFeedItem:(NSString *)feedItemId
                  userId:(NSString *)userId
                callback:(void (^)(ECUser *user, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/setFavorite/%@/%@", feedItemId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *userError = nil;
                                                   ECUser *aUser = [[ECUser alloc] initWithDictionary:responseDictionary[@"data"] error:&userError];
                                                   
                                                   if (userError) {
                                                       NSLog(@"Error fetching user by email: %@", userError);
                                                       callback(nil, userError);
                                                       return;
                                                   }
                                                   callback(aUser, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)deleteFavoriteFeedItem:(NSString *)feedItemId
                    playlistId:(NSString *)playlistId
                     userId:(NSString *)userId
                   callback:(void (^)(DCPlaylist *playlist, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/deleteFavorite/%@/%@/%@", feedItemId, playlistId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSError *playlistError = nil;
                                                   DCPlaylist *aPlaylist = [[DCPlaylist alloc] initWithDictionary:responseDictionary[@"data"] error:&playlistError];
                                                   
                                                   if (playlistError) {
                                                       NSLog(@"Error deleting playlist by id: %@", playlistError);
                                                       callback(nil, playlistError);
                                                       return;
                                                   }
                                                   callback(aPlaylist, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient deleteFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFavoriteFeedItemsByUserId:(NSString *)userId
                            callback:(void (^)(NSArray *favorites, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/getFavoriteFeedItems/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *ebFeedItemDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *ebFeedItemError = nil;
                                                   NSArray *ebFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:ebFeedItemDictionaries error:&ebFeedItemError];
                                                   if (ebFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", ebFeedItemError);
                                                   }
                                                   callback(ebFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFavoriteEventsByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)addToPlaylist:(NSString *)playlistId
           feedItemId:(NSString *)feedItemId
               userId:(NSString *)userId
             callback:(void (^)(NSArray *playlists, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/addToPlaylist/%@/%@/%@", playlistId, feedItemId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcPlaylistDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *playlistError = nil;
                                                   NSArray *dcPlaylists = [DCPlaylist arrayOfModelsFromDictionaries:dcPlaylistDictionaries error:&playlistError];
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(dcPlaylists, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getPlaylistsByUserId:(NSString *)userId
                            callback:(void (^)(NSArray *playlists, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/getPlaylists/%@", userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcPlaylistDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *playlistError = nil;
                                                   NSArray *dcPlaylists = [DCPlaylist arrayOfModelsFromDictionaries:dcPlaylistDictionaries error:&playlistError];
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(dcPlaylists, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFavoriteEventsByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getFavoriteFeedItemsByFeedItemId:(NSArray *)feedItemIds
                            callback:(void (^)(NSArray *favorites, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/getFavoriteFeedItemsByFeedItemId/%@", [feedItemIds componentsJoinedByString:@","]];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               GET:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *ebFeedItemDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *ebFeedItemError = nil;
                                                   NSArray *ebFeedItems = [DCFeedItem arrayOfModelsFromDictionaries:ebFeedItemDictionaries error:&ebFeedItemError];
                                                   if (ebFeedItemError) {
                                                       NSLog(@"Error fetching app info: %@", ebFeedItemError);
                                                   }
                                                   callback(ebFeedItems, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient getFavoriteEventsByUserId]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)createPlaylist:(NSString *)userId
           playlistName:(NSString *)playlistName
             callback:(void (^)(DCPlaylist *playlists, NSError *error))callback{
    
    NSString *endpoint = [[NSString stringWithFormat:@"/rest/v4/feedItems/createPlaylist/%@/%@", userId, playlistName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSError *playlistError = nil;
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   DCPlaylist *aPlaylist = [[DCPlaylist alloc] initWithDictionary:responseDictionary[@"data"] error:&playlistError];
                                                   
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(aPlaylist, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)deletePlaylistById:(NSString *)playlistId
                      callback:(void (^)(NSArray *playlists, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/deletePlaylistById/%@", playlistId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               DELETE:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   NSArray *dcPlaylistDictionaries = responseDictionary[@"data"];
                                                   
                                                   NSError *playlistError = nil;
                                                   NSArray *dcPlaylists = [DCPlaylist arrayOfModelsFromDictionaries:dcPlaylistDictionaries error:&playlistError];
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(dcPlaylists, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient deleteFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)updatePlaylist:(NSString *)playlistId
          playlistName:(NSString *)playlistName
              callback:(void (^)(DCPlaylist *playlists, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/createPlaylist/%@/%@", playlistId, playlistName];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSError *playlistError = nil;
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   DCPlaylist *aPlaylist = [[DCPlaylist alloc] initWithDictionary:responseDictionary[@"data"] error:&playlistError];
                                                   
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(aPlaylist, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)downloadSharedPlaylistById:(NSString *)playlistId
          userId:(NSString *)userId
              callback:(void (^)(DCPlaylist *playlists, NSError *error))callback{
    
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/feedItems/downloadSharedPlaylistById/%@/%@", playlistId, userId];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:nil
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSError *playlistError = nil;
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   DCPlaylist *aPlaylist = [[DCPlaylist alloc] initWithDictionary:responseDictionary[@"data"] error:&playlistError];
                                                   
                                                   if (playlistError) {
                                                       NSLog(@"Error fetching app info: %@", playlistError);
                                                   }
                                                   callback(aPlaylist, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient setFavoriteEvent]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)cloneEventBriteEventToDB:(NSString *)eventId
                       eventJson:(NSString *)eventJson
                        callback:(void (^)(NSDictionary *jsonDictionary, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/rest/v4/events/cloneEventBriteEventToDB/%@", eventId];
    
    NSDictionary *parameters = [eventJson dictionaryOrNilValue];
    
    DCNodeApiClientCreateTask createTaskBlock = ^AFHTTPRequestOperation *(void (^retryBlock)(AFHTTPRequestOperation *task, NSError *error)) {
        AFHTTPRequestOperation *createdTask = [[ECHTTPRequestOperationManager sharedManagerDC]
                                               POST:endpoint
                                               parameters:parameters
                                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                   NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
                                                   
                                                   NSError *infoError = nil;
                                                   
                                                   if (infoError) {
                                                       NSLog(@"Error adding topic: %@", infoError);
                                                       callback(nil, infoError);
                                                       return;
                                                   }
                                                   callback(responseDictionary, nil);
                                               }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                   callback(nil, error);
                                               }];
        return createdTask;
    };
    
    DCNodeApiClientFailure failureBlock = ^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"[DCNodeApiClient cloneEventBriteEventToDB]: error %@", error);
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

#pragma mark - Google API calls
- (void)getLongitudeLatitudeFromAddress:(NSString *)address
                               callback:(void (^)(NSString *lat, NSString *lng, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/geocode/json?address=%@&key=%@", address, kGoogleAPIKey];
    
    [[ECHTTPRequestOperationManager sharedManagerGoogle]
     GET:endpoint
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         NSError *googleError = nil;
         NSLog(@"%@", [responseDictionary objectForKey:@"lat"]);
         NSLog(@"%@", [[responseDictionary valueForKeyPath:@"results.geometry.location.lat"] lastObject]);
         NSString *aLat = [[responseDictionary valueForKeyPath:@"results.geometry.location.lat"] lastObject];
         NSString *aLng = [[responseDictionary valueForKeyPath:@"results.geometry.location.lng"] lastObject];
         
         if (googleError) {
             NSLog(@"Error fetching location: %@", googleError);
             callback(nil, nil, googleError);
             return;
         }
         callback(aLat, aLng, nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, nil, error);
     }];
}

#pragma mark - EdgeTV
- (void)getPlaybackUrl:(NSString *)cid
                               callback:(void (^)(NSString *aPlaybackUrl, NSError *error))callback{
    NSString *endpoint = [NSString stringWithFormat:@"/edgetv/uplynkGetPlaybackUrl.php?cid=%@", cid];
    
    [[ECHTTPRequestOperationManager sharedManagerDCWeb]
     GET:endpoint
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary *responseDictionary = [responseObject dictionaryOrNilValue];
         callback([responseDictionary valueForKeyPath:@"playbackUrl"], nil);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         callback(nil, error);
     }];
}

- (void)testPlaybackUrl:(NSString *)cid
               callback:(void (^)(NSString *aPlaybackUrl, NSError *error))callback{
    
}
@end
