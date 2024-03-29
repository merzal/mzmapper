//
//  MZCategoryItemView.m
//  MZMapper
//
//  Created by Zalan Mergl on 10/10/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "MZCategoryItemView.h"
#import "MZCategoryViewController.h"
#import "MZDraggedCategoryItemView.h"

@interface MZCategoryItemView ()
{
    UILongPressGestureRecognizer* _longPressGesture;
    UIPanGestureRecognizer* _panGesture;
    CGPoint _delta;
}
@end

@implementation MZCategoryItemView

@synthesize categoryViewController, itemType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(enableMove:)];
        [self addGestureRecognizer:_longPressGesture];
    }
    return self;
}

- (void)didMoveToSuperview
{
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 10.0, self.bounds.size.width - 60.0, 30.0)];
    [titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [titleLabel setText:[NSString nameOfPointCategoryElement:itemType]];
    
    [self addSubview:titleLabel];
}

- (void)enableMove:(UILongPressGestureRecognizer *)gestureRecognizer
{    
    CGPoint recognizedAtPoint = [gestureRecognizer locationInView:self.window.rootViewController.view];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _draggedView = [[MZDraggedCategoryItemView alloc] initWithFrame:CGRectMake(9.0, 9.0, 32.0, 32.0) withImage:[UIImage imageForPointCategoryElement:itemType]];
        [_draggedView setAlpha:0.7];
        [_draggedView setArrowIsVisible:YES];
        
        CGPoint convertedCenterPoint = [self convertPoint:_draggedView.center toView:self.window.rootViewController.view];
        [_draggedView setCenter:convertedCenterPoint];
        [self.window.rootViewController.view addSubview:_draggedView];
        
        _delta = CGPointMake(recognizedAtPoint.x - _draggedView.center.x, recognizedAtPoint.y - _draggedView.center.y);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [_draggedView setCenter:CGPointMake(recognizedAtPoint.x - _delta.x, recognizedAtPoint.y - _delta.y)];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //hide arrow and animate dragged view into the map
        [_draggedView setArrowIsVisible:NO];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [_draggedView setAlpha:1.0];
                        
            CGRect newFrame = _draggedView.frame;
            newFrame = CGRectMake(_draggedView.frame.origin.x + _draggedView.frame.size.width / 4.0, _draggedView.frame.origin.y + _draggedView.frame.size.height + _draggedView.arrowHeight - 8.0, 16.0, 16.0);
            [_draggedView setFrame:newFrame];
        
        } completion:^(BOOL finished) {
            [self.categoryViewController addCategoryItemType:self.itemType toPoint:_draggedView.center];
            
            [_draggedView release], _draggedView = nil;
        }];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //draw item image
    [[UIImage imageForPointCategoryElement:itemType] drawInRect:CGRectMake(17.0, 17.0, 16.0, 16.0)];
}

- (void)dealloc
{
    [_longPressGesture release];
    [_panGesture release];
    
    [super dealloc];
}

@end
