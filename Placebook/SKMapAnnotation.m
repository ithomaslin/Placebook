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

#define kBaseSize 90.0

@implementation SKMapAnnotation

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    self.frame = CGRectMake(0, 0, kBaseSize, kBaseSize);
    
    _imageView = [[UIImageView alloc] initWithFrame:self.frame];
//    [_imageView setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
//                   placeholderImage:[UIImage imageNamed:@"pin.png"]];
    [_imageView setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"] placeholderImage:[UIImage imageNamed:@"self"] options:SDWebImageContinueInBackground completed:
     ^void (UIImage *image, NSError *error, SDImageCacheType cacheType) {
         [self setNeedsDisplay];
    }];
    
    _imageView.backgroundColor = [UIColor whiteColor];

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
    self.frame = CGRectMake(0, 0, floor(kBaseSize * _cluster.relSize), floor(kBaseSize * _cluster.relSize));
    [_imageView setImageWithURL:[NSURL URLWithString:cluster.thumbs[0]]
               placeholderImage:[UIImage imageNamed:@"self"] options:SDWebImageContinueInBackground completed:
     ^void (UIImage *image, NSError *error, SDImageCacheType cacheType) {
         [self setNeedsDisplay];
     }];
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
            CGFloat badgeSize = 14;
            CGRect badgeRect = CGRectMake(rect.size.width - badgeSize - 2, 0, badgeSize, badgeSize);
            
            CGContextFillEllipseInRect(context, badgeRect);
            
            NSString *count = [NSString stringWithFormat:@"%i", _cluster.count];
            
            CGFloat vertShift = 1.0;
            CGFloat hozShift = 0.0;
            CGFloat fontSize = 10;
            if (_cluster.count > 9)
            {
                fontSize = 8;
                hozShift = 2.0;
                vertShift = 2.0;
            }
            if (_cluster.count > 99)
            {
                fontSize = 6;
                hozShift = 3.0;
                vertShift = 3.0;
            }
            
            UIFont *font = [UIFont fontWithName: @"Courier" size: fontSize];
            NSDictionary *dictionary = @{ NSFontAttributeName: font, NSForegroundColorAttributeName : [UIColor whiteColor]};
            
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
                                          
            [count drawAtPoint:CGPointMake(CGRectGetMidX(badgeRect)-2.0 - hozShift, CGRectGetMinY(badgeRect)+vertShift) withAttributes:dictionary];
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
