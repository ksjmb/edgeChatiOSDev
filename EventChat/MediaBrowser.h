//
//  MediaBrowser.h
//  WhoTree
//
//  Created by Mindbowser on 15/11/13.
//  Copyright (c) 2013 Bhushan Biniwale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaBrowser : NSObject
typedef void (^MediaBrowserCompletionHandler)(id selectedMedia);

+ (id)sharedInstance;

- (BOOL)startMediaBrowserFromViewController:(UIViewController *)controller mediaOutputSettings:(NSDictionary *)outputSettings completionHandler:(MediaBrowserCompletionHandler)completion;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(UIImage *)generatePhotoThumbnail:(UIImage *)image;
- (UIImage *)resizeImage:(UIImage *)captureImage ToSize:(CGSize)targetSize;
@end
