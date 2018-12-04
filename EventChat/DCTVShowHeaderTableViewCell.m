//
//  DCTVShowHeaderTableViewCell.m
//  EventChat
//
//  Created by Jigish Belani on 1/7/18.
//  Copyright © 2018 Jigish Belani. All rights reserved.
//

#import "DCTVShowHeaderTableViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "AFHTTPRequestOperationManager.h"

@interface DCTVShowHeaderTableViewCell()
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@end
@implementation DCTVShowHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - AF
- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager)
    {
        _operationManager = [[AFHTTPRequestOperationManager alloc] init];
        _operationManager.responseSerializer = [AFImageResponseSerializer serializer];
    };
    
    return _operationManager;
}

- (void)configureWithFeedItem:(DCFeedItem *)feedItem{
    if( feedItem.digital.imageUrl != nil){
        UIImageView *feedItemImageView = [[UIImageView alloc] init];
        [feedItemImageView.associatedObject cancel];
        
        feedItemImageView.associatedObject =
        [self.operationManager GET:feedItem.digital.imageUrl
                        parameters:nil
                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                               feedItemImageView.image = responseObject;
                               
                               [self.topImageView setImage:feedItemImageView.image];
                               UIView *view = [[UIView alloc] initWithFrame: _topImageView.frame];
                               CAGradientLayer *gradient = [[CAGradientLayer alloc] init];
                               gradient.frame = view.frame;
                               gradient.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor] ];
                               gradient.locations = @[@0.0, @0.9];
                               [view.layer insertSublayer: gradient atIndex: 0];
                               [_topImageView addSubview: view];
                               [_topImageView bringSubviewToFront: view];
                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               NSLog(@"Failed with error %@.", error);
                           }];
    }
}

@end
