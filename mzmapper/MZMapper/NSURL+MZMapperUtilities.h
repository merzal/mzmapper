//
//  NSURL+MZMapperUtilities.h
//  MZMapper
//
//  Created by Zalan Mergl on 11/27/12.
//
//

@interface NSURL (MZMapperUtilities)

+ (NSURL*)urlForChangesetCreation;
+ (NSURL*)urlForChangesetClosingForChangesetID:(NSString*)changesetID;
+ (NSURL*)urlForDeleteNodeForNodeID:(NSString*)nodeID;
+ (NSURL*)urlForCreateNode;
+ (NSURL*)urlForUpdateNodeForNodeID:(NSString*)nodeID;

@end
