//
//  MZMapperViewController.h
//  MZMapper
//
//  Created by Zalan Mergl on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MZMapView.h"
#import "MZTiledScrollView.h"
#import "MZLoginViewController.h"
#import "MZBlockView.h"

@class MZMessageView;
@class MZPullView;
@class MZLoupeView;
@class MZLoginViewController;
@class MZNode;

@interface MZMapperViewController : UIViewController <CLLocationManagerDelegate, MZLoginViewControllerDelegate>
{
    MZTiledScrollView*      _scrollView;
	MZMapView*              _map;
    MZPullView*             _pullView;
    BOOL                    _gettingCurrentLocationIsInProgress;
    BOOL                    _editingModeIsActive;
    BOOL                    _waitingForLogInToSwitchToEditingMode;
    MZNode*                 _selectedPointObject;
    
    @private
    MZMessageView*          _messageView;
    MZBlockView*            _blockView;
    CLLocationManager*      _locationManager;
    UIButton*               _currentLocButton;
    UIButton*               _searchButton;
    UIButton*               _editButton;
    UIButton*               _openStreetBugButton;
    MZLoupeView*            _loupeView;
    MZLoginViewController*  _loginViewController;
    NSMutableArray*         _openStreetBugs;
    UIView*                 _openStreetBugView;
    UIView*                 _selectedPointObjectBackgroundView;
}

@property (nonatomic, assign)   BOOL gettingCurrentLocationIsInProgress;
@property (nonatomic, retain)   MZNode* selectedPointObject;

- (void)showMessageViewWithMessage:(NSString*)message;
- (void)hideMessageView;
- (void)showBlockView;
- (void)hideBlockView;
- (void)jumpToCoordinateLongitude:(CGFloat)lon latitude:(CGFloat)lat;
- (void)handleBugTap:(UITapGestureRecognizer*)gesture;
- (void)refreshOpenStreetBugs;

@end
