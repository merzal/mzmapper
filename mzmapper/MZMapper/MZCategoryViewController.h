//
//  MZCategoryViewController.h
//  MZMapper
//
//  Created by Zalan Mergl on 10/10/12.
//
//


@class MZEditViewController;

@interface MZCategoryViewController : UIViewController
{
    MZMapperPointCategory   _categoryType;
    
    IBOutlet UILabel*       _titleLabel;
    
    IBOutlet UIButton*      _showMoreButton;
}

@property (nonatomic, assign) MZEditViewController* editViewController;

// designated initializer
- (id)initWithCategoryType:(MZMapperPointCategory)type;

- (IBAction)showMoreButtonTouched:(id)sender;

- (void)addCategoryItemType:(NSUInteger)type toPoint:(CGPoint)toPoint;

@end
