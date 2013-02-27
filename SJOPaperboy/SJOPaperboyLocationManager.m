//
//  PaperboyLocationManager.m
//  Pinner
//
//  Created by Sam Oakley on 16/02/2013.
//  Copyright (c) 2013 Sam Oakley. All rights reserved.
//

#import "SJOPaperboyLocationManager.h"

@implementation SJOPaperboyLocationManager

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        self.radius = 20;
        self.updateOnEnter = NO;
        self.updateOnExit = YES;
    }
    return self;
}

+ (SJOPaperboyLocationManager*)sharedInstance
{
    static SJOPaperboyLocationManager *sharedLocationManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLocationManagerInstance = [[self alloc] init];
    });
    return sharedLocationManagerInstance;
}


+ (CLLocationManager*)sharedLocationManager
{
    return [SJOPaperboyLocationManager sharedInstance].locationManager;
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if (self.updateOnEnter)
        [self locationChanged];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if (self.updateOnExit)
        [self locationChanged];
}

-(void)locationChanged
{
    /*
     * There is a bug in iOS that causes didEnter/didExitRegion to be called multiple
     * times for one location change (http://openradar.appspot.com/radar?id=2484401). 
     * Here, we rate limit it to prevent performing the update twice in quick succession.
     */
    
    static long timestamp;
    
    if (timestamp == 0) {
        timestamp = [[NSDate date] timeIntervalSince1970];
    } else {
        if ([[NSDate date] timeIntervalSince1970] - timestamp < 10) {
            return;
        }
    }
    
    if (self.locationChangedBlock) {
        self.locationChangedBlock();
    }
}

-(void) updateGeofencedLocations
{
        // Cancel previous update locations before setting new ones
    NSArray *regionArray = [[[SJOPaperboyLocationManager sharedLocationManager] monitoredRegions] allObjects];
    for (int i = 0; i < [regionArray count]; i++) {
        [[SJOPaperboyLocationManager sharedLocationManager] stopMonitoringForRegion:[regionArray objectAtIndex:i]];
    }
    
    if ([SJOPaperboyLocationManager isBackgroundUpdatingEnabled]) {
        
        NSMutableArray *geofences = [NSMutableArray array];
        NSArray* locations = [SJOPaperboyLocationManager locationsForUpdate];
        
        for(CLLocation *location in locations) {
            NSString* identifier = [NSString stringWithFormat:@"%f%f", location.coordinate.latitude, location.coordinate.longitude];
            
            CLRegion* geofence = [[CLRegion alloc] initCircularRegionWithCenter:location.coordinate
                                                                         radius:self.radius
                                                                     identifier:identifier];
            [geofences addObject:geofence];
        }
        
        if (geofences.count > 0) {
            for(CLRegion *geofence in geofences) {
                [[SJOPaperboyLocationManager sharedLocationManager] startMonitoringForRegion:geofence];
            }
        }
        
    }
}

#pragma mark Static helpers

+ (BOOL) isBackgroundUpdatingEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kBackgroundUpdates];
}

+ (NSArray*) locationsForUpdate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *savedLocations = [userDefaults objectForKey:kLocations];
    
    NSMutableArray* locations = [NSMutableArray array];
    for (NSData* data in [savedLocations allValues]) {
        CLLocation* location = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [locations addObject:location];
    }
    return [NSArray arrayWithArray:locations];
}

@end
