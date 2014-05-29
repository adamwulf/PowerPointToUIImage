//
//  MMViewController.h
//  PowerPointThumb
//
//  Created by Adam Wulf on 5/28/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMThumbnailPPTController : UIViewController<UIWebViewDelegate>

-(void)generateThumbnailsForFile:(NSURL *)url;

@end