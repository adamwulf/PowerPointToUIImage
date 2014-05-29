//
//  MMViewController.m
//  PowerPointThumb
//
//  Created by Adam Wulf on 5/28/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMThumbnailPPTController.h"

@implementation MMThumbnailPPTController{
    // the webview we'll use to generate thumbnails
    UIWebView *webView;
    // a uiview will help us hide the webview
    // while generation is going on
    UIView* hidingView;

    // maximum allowed size of thumbnails
    CGFloat maxThumbnailDimension;
    
    // button and status to show what's going on
    UIButton* loadPPTButton;
    UILabel* status;
    
    // scrollview to show image output
    UIScrollView* scrollView;
}

- (id)init{
    if(self = [super init]){
        
        hidingView = [[UIView alloc] initWithFrame:self.view.bounds];
        hidingView.alpha = 0;
        [self.view addSubview:hidingView];
        
        loadPPTButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loadPPTButton setTitle:@"Load PPT" forState:UIControlStateNormal];
        [loadPPTButton sizeToFit];
        [loadPPTButton addTarget:self action:@selector(loadPPT:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loadPPTButton];
        
        CGRect fr = loadPPTButton.frame;
        fr.origin.x = (self.view.bounds.size.width - loadPPTButton.bounds.size.width) / 2;
        fr.origin.y = 40;
        loadPPTButton.frame = fr;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        status = [[UILabel alloc] init];
        status.textAlignment = NSTextAlignmentCenter;
        status.text = @"Ready";
        [status sizeToFit];
        fr = loadPPTButton.frame;
        fr.size.width = self.view.bounds.size.width;
        fr.origin.x = 0;
        fr.origin.y = 80;
        status.frame = fr;
        [self.view addSubview:status];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width, self.view.bounds.size.height - 120)];
        [self.view addSubview:scrollView];
        
        
        maxThumbnailDimension = 300;
    }
    return self;
}

// handle button press to load the default powerpoint file
-(IBAction) loadPPT:(id)sender{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"WorstPresentationEverStandAlone" ofType:@"ppt"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [self generateThumbnailsForFile:fileUrl];
    
    status.text = [@"Generating thumbs for " stringByAppendingString:[filePath lastPathComponent]];
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    scrollView.contentSize = CGSizeZero;
}

// handle opening a powerpoint from any URL
- (void)generateThumbnailsForFile:(NSURL *)url {
    if(webView){
        @throw [NSException exceptionWithName:@"ThumbnailException" reason:@"Already generating thumbnails. Can only generate for 1 file at a time." userInfo:nil];
    }
    
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView removeFromSuperview];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.scrollView.minimumZoomScale = 0;
    webView.scrollView.maximumZoomScale = 1;
    [hidingView addSubview:webView];
    
    [webView setUserInteractionEnabled:YES];
    [webView loadRequest:requestObj];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)_webView{
    
    // show that UIWebView transforms ppt into html.
    // here is the raw html if you want to do anything else,
    // like text search / modify it / change slide order / etc
    NSString* html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"html:\n%@", html);
    
    // start generating thumbnails at the first slide
    [self generateThumbnailForAllSlides];
    
    [webView removeFromSuperview];
    webView = nil;
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"error: %@", error);
}


#pragma mark - Helper Methods

-(void) generateThumbnailForAllSlides{
    // first, find out how many slides there are
    // and if we're asking for an existing slide
    int slideCount = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('slide').length"] intValue];
    
    // now loop though all slides, and generate a thumbnail
    // for each one.
    //
    // for this sample code, we just save them to the documents
    // folder, but it generates a UIImage per slide so they could
    // easily be used pretty much anywhere
    for(int slideIndex = 0; slideIndex < slideCount; slideIndex++){
        @autoreleasepool {
            NSLog(@"generating: %i", slideIndex);
            // now find the dimensions of that slide
            int height = [[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('slide')[%d].style.height", slideIndex]] intValue];
            int width= [[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('slide')[%d].style.width", slideIndex]] intValue];
            
            // set the webview to be the same ratio of dimensions
            // as the slide, with our maximum dimension as our input.
            //
            // this way, we will only generate thumbnails that are less
            // then or equal to maxThumbnailDimension in width and height
            CGRect bounds = webView.bounds;
            CGFloat scale = 1;
            if(width > height){
                bounds.size.width = maxThumbnailDimension;
                bounds.size.height = (float)height / (float)width * maxThumbnailDimension;
                scale = maxThumbnailDimension / width;
            }else{
                scale = bounds.size.width / bounds.size.height;
                bounds.size.width = (float)width / (float)height * maxThumbnailDimension;
                bounds.size.height = maxThumbnailDimension;
                scale = maxThumbnailDimension / height;
            }
            webView.bounds = bounds;
            
            // next, find out how far down in the webview this slide is
            // and scroll to it
            int offset = [[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('slide')[%d].offsetTop", slideIndex]] intValue];
            CGPoint so = webView.scrollView.contentOffset;
            so.y = offset * scale;
            webView.scrollView.contentOffset = so;
            
            // now that the webview's bounds are exactly the same size
            // then save the webview as a PNG image of the slide
            UIGraphicsBeginImageContext(bounds.size);
            [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *slideThumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // save the slide to our Documents directory.
            // you can verify the output in Xcode's Organizer,
            // or by modifying the project to show UIImageViews
            // or however you like
            NSString* filename = [NSString stringWithFormat:@"slide%i.png", slideIndex];
            NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *outputImagePath = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:filename];
            [UIImagePNGRepresentation(slideThumbnailImage) writeToFile:outputImagePath atomically:YES];
            
            
            CGFloat x = 34 + slideIndex % 2 * 350;
            CGFloat y = floorf(slideIndex / 2) * 310;
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 300, 300)];
            imgView.contentMode = UIViewContentModeCenter;
            imgView.image = slideThumbnailImage;
            [scrollView addSubview:imgView];
        }
    }

    scrollView.contentSize = CGSizeMake(MAX(768,self.view.bounds.size.width), (floorf(slideCount / 2)+1) * 300);
    status.text = [NSString stringWithFormat:@"Generated %i thumbnails", slideCount];
}

@end
