//
//  SKMapAnnotation.m
//  Placebook
//
//  Created by Shaun Dowling on 03/11/2013.
//  Copyright (c) 2013 AppCanvas. All rights reserved.
//

#import "SKMapAnnotation.h"
#import "SKCluster.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"

@implementation SKMapAnnotation

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    self.frame = CGRectMake(0, 0, 30, 30);
    
    _imageView = [[UIImageView alloc] initWithFrame:self.frame];
//    [_imageView setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
//                   placeholderImage:[UIImage imageNamed:@"pin.png"]];
    [_imageView setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"] placeholderImage:[UIImage imageNamed:@"placePin.png"] options:SDWebImageContinueInBackground completed:
     ^void (UIImage *image, NSError *error, SDImageCacheType cacheType) {
         [self setNeedsDisplay];
    }];
    

//    
//    _imageView.image = [UIImage imageNamed:@"pin.png"];
//    [self addSubview:_imageView];
//    
//    _insideView = [[UIImageView alloc] initWithFrame:CGRectInset(self.frame, 2, 2)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.path = [UIBezierPath bezierPathWithOvalInRect:_insideView.bounds].CGPath;
//    _insideView.layer.mask = maskLayer;
//    _insideView.image = [UIImage imageNamed:@"placePin.png"];
//    [self addSubview:_insideView];
//
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)setCluster:(SKCluster *)cluster
{
    _cluster = cluster;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
            [super drawRect:rect];
    if (_cluster != nil)
    {
        if (_cluster.count  > 0)
        {
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextAddEllipseInRect(context, rect);
            CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
            CGContextFillPath(context);
            
            CGContextSaveGState(context);
            
            CGContextAddEllipseInRect(context, CGRectInset(rect,2,2));
            CGContextClip(context);
            UIImage *icon = _imageView.image;
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            CGContextConcatCTM(context, transform);
            
            CGContextDrawImage(context, rect, ((UIImage*)icon).CGImage);
            
            CGContextRestoreGState(context);
            
//                        CGContextAddEllipseInRect(context, rect);
            [[UIColor darkGrayColor] setFill];
            CGRect badgeRect = CGRectMake(rect.size.width - 10, 0, 10, 10);
            
            CGContextFillEllipseInRect(context, badgeRect);
            
            NSString *count = [NSString stringWithFormat:@"%li", _cluster.count];
            
            UIFont *font = [UIFont fontWithName: @"Courier" size: 10.0];
            NSDictionary *dictionary = @{ NSFontAttributeName: font};
            
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
                                          
            [count drawAtPoint:CGPointMake(CGRectGetMidX(badgeRect)-2.0, CGRectGetMinY(badgeRect)) withAttributes:dictionary];
        }
    }
    
//
//    CGContextAddEllipseInRect(context, CGRectInset(rect, 10, 10));
//    
    
////    UIGraphicsBeginImageContext(rect.size);
//    if (_cluster == nil)
//    {
//        UIImage *icon = [UIImage imageNamed:@"pin.png"];
//        [icon drawInRect:rect];
////        UIGraphicsEndImageContext();
//    }
//    else
//    {
////        UIImage *icon = [UIImage imageNamed:@"pin.png"];
////        
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
//        transform = CGAffineTransformScale(transform, 1.0, -1.0);
//        CGContextConcatCTM(context, transform);
////
////        CGContextDrawImage(context, rect, ((UIImage*)icon).CGImage);
////        [icon drawInRect:rect];
////        UIGraphicsEndImageContext();
//    }
}

@end
