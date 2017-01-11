//
//  ViewController.m
//  LQCutLongPic
//
//  Created by 0000 on 17/1/9.
//  Copyright © 2017年 wisdomparents. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

@property(nonatomic, strong)UIWebView *webView ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://nba.hupu.com"]]];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"截图" style:UIBarButtonItemStylePlain target:self action:@selector(cutPic)];
    [self.navigationItem setRightBarButtonItem:cancelButton];
}

- (void)cutPic{
    CGRect snapshotFrame = CGRectMake(0, 0, _webView.scrollView.contentSize.width, _webView.scrollView.contentSize.height);
    UIEdgeInsets snapshotEdgeInsets = UIEdgeInsetsZero;
    UIImage *shareImage = [self snapshotViewFromRect:snapshotFrame withCapInsets:snapshotEdgeInsets];
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    
    NSString *imagePath = [path_document stringByAppendingString:@"/Documents/picc.png"];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    
    NSLog(@"%@",imagePath);
    
    [UIImagePNGRepresentation(shareImage) writeToFile:imagePath atomically:YES];
}


- (UIImage *)snapshotViewFromRect:(CGRect)rect withCapInsets:(UIEdgeInsets)capInsets {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize boundsSize = self.webView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    CGFloat contentWidth = contentSize.width;
    
    CGPoint offset = self.webView.scrollView.contentOffset;
    
    [self.webView.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, [UIScreen mainScreen].scale);
        [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = self.webView.scrollView.contentOffset.y;
        [self.webView.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    
    [self.webView.scrollView setContentOffset:offset];
    
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView * snapshotView = [[UIImageView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    
    snapshotView.image = [fullImage resizableImageWithCapInsets:capInsets];
    return snapshotView.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
