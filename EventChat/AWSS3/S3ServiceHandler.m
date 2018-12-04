//
//  S3ServiceHandler.m
//  EventChat
//
//  Created by Mindbowser on 4/4/17.
//  Copyright © 2017 Jigish Belani. All rights reserved.
//

#import "S3ServiceHandler.h"
#import "AWSCredentialsProvider.h"
#import "AWSCore.h"
#import "S3Constants.h"

@implementation S3ServiceHandler

// S3 Sevice Intiliazation 
+ (void)initializeS3Service{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:CognitoPoolID];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}
@end
