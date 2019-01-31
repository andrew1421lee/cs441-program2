//
//  Tile.h
//  NumberGame
//
//  Created by Anchu Lee on 1/31/19.
//  Copyright © 2019 Anchu Lee. All rights reserved.
//

#ifndef Tile_h
#define Tile_h

#import <UIKit/UIKit.h>

@interface Tile : NSObject {
    UILabel *label;
    NSNumber *index;
    NSNumber *value;
}

@property UILabel *label;
@property NSNumber *index;
@property NSNumber *value;

@end

#endif /* Tile_h */
