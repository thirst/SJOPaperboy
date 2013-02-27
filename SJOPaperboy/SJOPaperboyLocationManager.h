//
//  PaperboyLocationManager.h
//  Pinner
//
//  Created by Sam Oakley on 16/02/2013.
//  Copyright (c) 2013 Sam Oakley. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define kBackgroundUpdates @"paperboy_background_updates"
#define kLocations @"paperboy_location_array"

@interface SJOPaperboyLocationManager : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (copy, nonatomic) dispatch_block_t locationChangedBlock;

@property (nonatomic)       NSUInteger      radius;
@property (nonatomic)       BOOL            updateOnEnter;
@property (nonatomic)       BOOL            updateOnExit;

-(void) updateGeofencedLocations;

+ (BOOL) isBackgroundUpdatingEnabled;
+ (NSArray*) locationsForUpdate;

+ (CLLocationManager*) sharedLocationManager;
+ (SJOPaperboyLocationManager*) sharedInstance;

@end
