//
//  MZMapView.m
//  MZMapper
//
//  Created by Zalan Mergl on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MZMapView.h"
#import "MZNode.h"
#import "MZWay.h"

@interface MZMapView ()
{
    NSMutableArray* _pointObjects;
}
@end

@implementation MZMapView

@synthesize minLatitude = _minLatitude, maxLatitude = _maxLatitude, minLongitude = _minLongitude, maxLongitude = _maxLongitude;
@synthesize scale = _scale;
 
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _logging = NO;
        
        // Initialization code
        //[self setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
        [self setBackgroundColor:[UIColor colorWithRed:234.0/255.0 green:216.0/255.0 blue:189.0/255.0 alpha:1.0]];
        
        _nodes = [[NSMutableDictionary alloc] init];
        
        _ways = [[NSMutableArray alloc] init];
        
        _levels = [[NSMutableDictionary alloc] init];
        
        NSMutableArray* level0 = [NSMutableArray array];
        NSMutableArray* level1 = [NSMutableArray array];
        NSMutableArray* level2 = [NSMutableArray array];
        NSMutableArray* level3 = [NSMutableArray array];
        NSMutableArray* level4 = [NSMutableArray array];
        NSMutableArray* level5 = [NSMutableArray array];
        NSMutableArray* level6 = [NSMutableArray array];
        
        [_levels setValue:level0 forKey:@"level0"];
        [_levels setValue:level1 forKey:@"level1"];
        [_levels setValue:level2 forKey:@"level2"];
        [_levels setValue:level3 forKey:@"level3"];
        [_levels setValue:level4 forKey:@"level4"];
        [_levels setValue:level5 forKey:@"level5"];
        [_levels setValue:level6 forKey:@"level6"];
        
        _scale = 1.0;
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNodeFromMap:) name:@"NodeDeletedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNodeToTheMap:) name:@"NodeAddedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNodeOnTheMap:) name:@"NodeUpdatedNotification" object:nil];
    }
    
    return self;
}

- (void)setupWithXML:(NSString*)xml
{
    if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    _parser = [[NSXMLParser alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding]];
        
    [_parser setDelegate:self];
    
    [_parser parse];
    
    [_parser release];
}

#pragma mark -
#pragma mark xmlparser delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    _startTime = [NSDate date];
    
    if (_nodes) 
    {
        [_nodes removeAllObjects];
    }
    
    if (_ways) 
    {
        [_ways removeAllObjects];
    }
    
    if (_pointObjects)
    {
        [_pointObjects release];
    }
    
    _pointObjects = [[NSMutableArray alloc] init];
    
    [[MZMapperContentManager sharedContentManager].actualPointObjects removeAllObjects];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    [self setNeedsDisplay];
    
    MZMapperContentManager* cm = [MZMapperContentManager sharedContentManager];
    
    cm.actualPointObjects = _pointObjects;
    
    [self updatePointObjectsLayerView];
}

- (void)updatePointObjectsLayerView
{
    MZMapperContentManager* cm = [MZMapperContentManager sharedContentManager];
    
    if (_pointObjectsLayerView)
    {
        [_pointObjectsLayerView removeFromSuperview];
        
        [_pointObjectsLayerView release];
    }
    
    _pointObjectsLayerView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self addSubview:_pointObjectsLayerView];
    
    for (MZNode* node in cm.actualPointObjects)
    {
        //get the image name of the point object
        NSString* type = [cm typeNameInServerRepresentationForNode:node];
        NSString* subType = [cm subTypeNameInServerRepresentationForNode:node];
        
        NSString* imageName = [NSString stringWithFormat:@"%@_%@.png", type ,subType];
        
        UIImageView* imageViewForPointObject = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        
        [imageViewForPointObject setCenter:[self realPositionForNode:node]];
        [imageViewForPointObject setUserInteractionEnabled:YES];
        [imageViewForPointObject setTag:[node.nodeid integerValue]];
        
        [_pointObjectsLayerView addSubview:imageViewForPointObject];
        
        [imageViewForPointObject release];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    if ([elementName isEqual:@"bounds"]) 
    {
        _minLatitude = [[attributeDict valueForKey:@"minlat"] floatValue];
        _maxLatitude = [[attributeDict valueForKey:@"maxlat"] floatValue];
        _minLongitude = [[attributeDict valueForKey:@"minlon"] floatValue];
        _maxLongitude = [[attributeDict valueForKey:@"maxlon"] floatValue];
    }
    else if ([elementName isEqual:@"node"])
    {
        if (_currentNode) 
        {
            _currentNode = nil;
        }
        
        _currentNode = [[MZNode alloc] init];
        
        _currentNode.latitude = [[attributeDict valueForKey:@"lat"] floatValue];
        _currentNode.longitude = [[attributeDict valueForKey:@"lon"] floatValue];
        _currentNode.nodeid = [attributeDict valueForKey:@"id"];
        _currentNode.version = [[attributeDict valueForKey:@"version"] intValue];
    }
    else if ([elementName isEqual:@"way"])
    {
        if (_currentWay) 
        {
            _currentWay = nil;
        }
        
        _currentWay = [[MZWay alloc] init];
        
        _currentWay.wayid = [attributeDict valueForKey:@"id"];
    }
    else if ([elementName isEqual:@"nd"])
    {
        if (_currentWay) 
        {
            [_currentWay.nodes addObject:[_nodes valueForKey:[attributeDict valueForKey:@"ref"]]];
        }
    }
    else if ([elementName isEqual:@"tag"])
    {
        if (_currentNode) 
        {
            NSString* tagKey = [attributeDict valueForKey:@"k"];
            NSString* tagValue = [attributeDict valueForKey:@"v"];
            
            [_currentNode.tags setValue:tagValue forKey:tagKey];
            
            if ([tagKey isEqualToString:@"tourism"]
                || [tagKey isEqualToString:@"emergency"]
                || [tagKey isEqualToString:@"man_made"]
                || [tagKey isEqualToString:@"barrier"]
                || [tagKey isEqualToString:@"landuse"]
                || [tagKey isEqualToString:@"place"]
                || [tagKey isEqualToString:@"power"]
                || [tagKey isEqualToString:@"highway"]
                || [tagKey isEqualToString:@"railway"]
                || [tagKey isEqualToString:@"shop"]
                || [tagKey isEqualToString:@"leisure"]
                || [tagKey isEqualToString:@"historic"]
                || [tagKey isEqualToString:@"aeroway"]
                || [tagKey isEqualToString:@"amenity"])
            {
                [_pointObjects addObject:_currentNode];
            }
        }
        else if (_currentWay) 
        {
            NSString* tagKey = [attributeDict valueForKey:@"k"];
            NSString* tagValue = [attributeDict valueForKey:@"v"];
            
            [_currentWay.tags setValue:tagValue forKey:tagKey];
            
            if ([tagKey isEqual:@"highway"]) 
            {
                if ([tagValue isEqual:@"residential"]) 
                {
                    _currentWay.lineWidth = 5.0;
                    _currentWay.strokeColor = [UIColor whiteColor];
                    _currentWay.fillColor = [UIColor clearColor];
                    [[_levels objectForKey:@"level4"] addObject:_currentWay];
                }
                else if ([tagValue isEqual:@"primary"])
                {
                    _currentWay.lineWidth = 5.0;
					_currentWay.strokeColor = [UIColor redColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level5"] addObject:_currentWay];
                }
                else if ([tagValue isEqual:@"secondary"]) 
				{
					_currentWay.lineWidth = 5.0;
					_currentWay.strokeColor = [UIColor orangeColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level5"] addObject:_currentWay];
				}
				else 
				{
					_currentWay.lineWidth = 2.0;
					_currentWay.strokeColor = [UIColor whiteColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level4"] addObject:_currentWay];
				}
            }
            else if ([tagKey isEqual:@"building"]) 
			{
				if ([tagValue isEqual:@"yes"]) 
				{
					_currentWay.lineWidth = 1.0;
					_currentWay.strokeColor = [UIColor blackColor];
					_currentWay.fillColor = [UIColor brownColor];
					[[_levels objectForKey:@"level5"] addObject:_currentWay];
				}
				else 
				{
					_currentWay.lineWidth = 1.0;
					_currentWay.strokeColor = [UIColor blackColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level5"] addObject:_currentWay];
				}
			}
            else if ([tagKey isEqual:@"leisure"]) 
			{
				if ([tagValue isEqual:@"park"]) 
				{
					_currentWay.lineWidth = 0.0;
					_currentWay.strokeColor = [UIColor clearColor];
					_currentWay.fillColor = [UIColor greenColor];
					[[_levels objectForKey:@"level2"] addObject:_currentWay];
				}
				else if ([tagValue isEqual:@"water_park"]) 
				{
					_currentWay.lineWidth = 0.0;
					_currentWay.strokeColor = [UIColor clearColor];
					_currentWay.fillColor = [UIColor colorWithRed:210.0/255.0 green:188.0/255.0 blue:150.0/255.0 alpha:1.0];
					[[_levels objectForKey:@"level3"] addObject:_currentWay];
				}
				else 
				{
					_currentWay.lineWidth = 1.0;
					_currentWay.strokeColor = [UIColor blackColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level3"] addObject:_currentWay];
				}
			}
            else if ([tagKey isEqual:@"waterway"]) 
			{
				if ([tagValue isEqual:@"river"]) 
				{
					_currentWay.lineWidth = 0.0;
					_currentWay.strokeColor = [UIColor clearColor];
					_currentWay.fillColor = [UIColor blueColor];
					[[_levels objectForKey:@"level1"] addObject:_currentWay];
				}
				else if ([tagValue isEqual:@"riverbank"]) 
				{
					_currentWay.lineWidth = 0.0;
					_currentWay.strokeColor = [UIColor clearColor];
					_currentWay.fillColor = [UIColor blueColor];
					[[_levels objectForKey:@"level1"] addObject:_currentWay];
				}
				else 
				{
					_currentWay.lineWidth = 1.0;
					_currentWay.strokeColor = [UIColor blackColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level1"] addObject:_currentWay];
				}
			}
            else if ([tagKey isEqual:@"natural"]) 
			{
				if ([tagValue isEqual:@"water"]) 
				{
					_currentWay.lineWidth = 0.0;
					_currentWay.strokeColor = [UIColor clearColor];
					_currentWay.fillColor = [UIColor blueColor];
					[[_levels objectForKey:@"level6"] addObject:_currentWay];
				}
				else 
				{
					_currentWay.lineWidth = 1.0;
					_currentWay.strokeColor = [UIColor blackColor];
					_currentWay.fillColor = [UIColor clearColor];
					[[_levels objectForKey:@"level6"] addObject:_currentWay];
				}
			}
            else if ([tagKey isEqual:@"name"])
            {
                //NSLog(@"wayname: %@",tagValue);
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    if ([elementName isEqual:@"node"]) 
    {
        [_nodes setValue:_currentNode forKey:_currentNode.nodeid];
        
        [_currentNode release], _currentNode = nil;
        
    } 
    else if ([elementName isEqual:@"way"])
    {
        [_ways addObject:_currentWay];
        
        [_currentWay release], _currentWay = nil;
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //if(_logging) NSLog(@"---%s",__PRETTY_FUNCTION__);
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    
    NSArray* keys = [[_levels allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for (NSString* key in keys) 
    {
        for (MZWay* way in [_levels objectForKey:key]) 
        {
            UIBezierPath* bp = [UIBezierPath bezierPath];
            
            for (MZNode* node in way.nodes) 
            {
                if ([bp isEmpty]) 
                {
                    [bp moveToPoint:[self realPositionForNode:node]];
                }
                else
                {
                    [bp addLineToPoint:[self realPositionForNode:node]];
                }
            }
            
            bp.lineWidth = way.lineWidth * _scale;
            
            [way.fillColor set];
            
            [bp fill];
            
            if (way.strokeColor) 
            {
                [way.strokeColor set];
            } 
            else 
            {
                bp.lineWidth = 1.0 * _scale;
                [[UIColor blackColor] set];
            }
            
            [bp stroke];
        }
        
    }
    
    
    //egyelőre csak a városnevet csapatjuk ki (még lehetne optimalizálni ezt a részt)
    //[[UIColor blackColor] set];
    
//    for (NSString* nodeID in _nodes) 
//    {
//        MZNode* node = [_nodes valueForKey:nodeID];
//        
//        if ([node.tags count] != 0) 
//        {
//            for (NSString* tagKey in node.tags) 
//            {
//                if ([tagKey isEqualToString:@"place"]) 
//                {
//                    NSString* name = [node.tags valueForKey:@"name"];
//                    [name drawAtPoint:[self realPositionForNode:node] withFont:[UIFont systemFontOfSize:16.0]];
//                }
//            }
//        }
//    }
}

#pragma mark -
#pragma mark helper methods

- (CGPoint)realPositionForNode:(MZNode*)node
{
    CGPoint retVal = CGPointZero;
    
    CGFloat xPos = (CGFloat)((node.longitude - _minLongitude) * self.bounds.size.width / (_maxLongitude - _minLongitude));
    
    CGFloat yPos = (_maxLatitude - node.latitude) * self.bounds.size.height / (_maxLatitude - _minLatitude);
    
    retVal = CGPointMake(xPos, yPos);
    
    return retVal;
}

- (MZNode*)nodeForRealPosition:(CGPoint)point
{
    MZNode* retVal = [[MZNode alloc] init];
    
    retVal.longitude = point.x * (_maxLongitude - _minLongitude) / self.bounds.size.width + _minLongitude;
    
    retVal.latitude = _maxLatitude - point.y * (_maxLatitude - _minLatitude) / self.bounds.size.height;
    
    return [retVal autorelease];
}

- (void)deleteNodeFromMap:(NSNotification*)aNotif
{
    MZNode* deletedNode = (MZNode*)[aNotif object];
    
    for (UIView* v in _pointObjectsLayerView.subviews)
    {
        if (v.tag == [deletedNode.nodeid integerValue])
        {
            [v removeFromSuperview];
            break;
        }
    }
    
    [self setNeedsDisplay];
}

- (void)addNodeToTheMap:(NSNotification*)aNotif
{
    [self updatePointObjectsLayerView];
}

- (void)updateNodeOnTheMap:(NSNotification*)aNotif
{    
    [self updatePointObjectsLayerView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_pointObjectsLayerView)
    {
        [_pointObjectsLayerView release];
    }
    
    [_nodes release], _nodes = nil;
    
    [_ways release], _ways = nil;
    
    [_levels release], _levels = nil;
        
    if (_pointObjects)
    {
        [_pointObjects release];
    }
    
    _pointObjects = [[NSMutableArray alloc] init];
    
    [super dealloc];
}

@end
