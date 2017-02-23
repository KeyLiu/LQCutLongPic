原文地址 http://www.jianshu.com/p/9215f8860af5


屏幕截屏的操作是项目中常见的，在很多项目中用于分享到第三方，在之前项目中写了一篇文章生成分享的图片，这里我们探讨一下如何生成长图。

[iOS截图（1）生成分享图片](http://www.jianshu.com/p/7c8e7e5102bc)

下面我们来截取一张网页的图片，`webView`是一个滚动视图，在截图时需要知道截图的长度宽度，然后才能渲染上面的信息。例如，我们截取简书的网页。

![打开网页](http://upload-images.jianshu.io/upload_images/1378903-80fef5446d98a1b5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

从[iOS截图（1）生成分享图片](http://www.jianshu.com/p/7c8e7e5102bc)中了解到，所谓截图操作的实现，是生成一个`view`，然后根据这个`view`生成图片，生成图片的方法是在两个C语言函数中实现的。代码写在两个函数中间。

 
    UIGraphicsBeginImageContext(imageSize);
    UIGraphicsEndImageContext();

与截取短图不同的是，因为截取长图，尤其是滚动视图，我们能够获取到图片的宽度（`webView.scrollView.contentSize.width`），高度（`webView.scrollView.contentSize.height`），但要如何截取，就要用到循环，截取若干张图片，然后拼接成一张。

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

以上操作做完，截图也就end了，接下来就要拼接图片了，使用`image` 的` drawInRect `方法画一张。

    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
    [image drawInRect:CGRectMake(0,
                  scale * boundsHeight * idx,
                  scale * boundsWidth,
                  scale * boundsHeight)];
      }];

最后生成的图片就是这样了。

![生成图片](http://upload-images.jianshu.io/upload_images/1378903-27af15ebb7ec6baa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

［注］由于现在的网页都做了适配，因此只考虑了宽度，对于上下左右均能滚动的网页可以用双重循环实现，再根据宽度来个循环。

Demo地址：https://github.com/KeyLiu/LQCutLongPic.git
