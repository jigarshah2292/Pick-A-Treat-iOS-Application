//
//  MapPinAnnotation.m
//  Pick-A-Treat
//
//  Created by Jigar Shah on 4/24/16.
//  Copyright © 2016 Jigar Shah. All rights reserved.
//

#import "MapPinAnnotation.h"

@implementation MapPinAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;
{
    self = [super init];
    if (self)
    {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    
    return self;
}

@end
