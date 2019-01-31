//
//  ViewController.m
//  NumberGame
//
//  Created by Anchu Lee on 1/30/19.
//  Copyright © 2019 Anchu Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// Cells are in regular coordinate order, meaning 00 is bottom left and 33 is top right!
@synthesize cell00, cell01, cell02, cell03,
            cell10, cell11, cell12, cell13,
            cell20, cell21, cell22, cell23,
            cell30, cell31, cell32, cell33;

static NSArray *backgroundCells;
static NSMutableArray *currentTiles;
static NSMutableArray *takenCells;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Put background cells into an array
    backgroundCells = [NSArray arrayWithObjects:
                       cell00, cell01, cell02, cell03,
                       cell10, cell11, cell12, cell13,
                       cell20, cell21, cell22, cell23,
                       cell30, cell31, cell32, cell33, nil];
    currentTiles = [[NSMutableArray alloc] init];
    takenCells = [[NSMutableArray alloc] init];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) handleSwipe:(UISwipeGestureRecognizer*) sender {
    if(sender.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"UP");
        [self moveTiles:@"UP"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"DOWN");
        [self moveTiles:@"DOWN"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"LEFT");
        [self moveTiles:@"LEFT"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"RIGHT");
        [self moveTiles:@"RIGHT"];
    }
    
    //[self spawnTile];
}

- (void) gameOver {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GAME OVER" message:@"You lost! Too bad" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

// Returns index in backgroundCells that is empty
- (NSNumber*) getEmptyIndex {
    bool found = false;
    bool gameOver = false;
    NSNumber *index = [NSNumber numberWithUnsignedInteger:arc4random_uniform(16)];
    
    while(!found && !gameOver){
        if([takenCells count] == 16) {
            NSLog(@"GAME OVER");
            gameOver = true;
            break;
        }
        
        if(![takenCells containsObject:(index)]) {
            found = true;
        } else {
            index = [NSNumber numberWithUnsignedInteger:arc4random_uniform(16)];
        }
    }
    
    if(gameOver)
    {
        index = [NSNumber numberWithInt:-1];
    }
    
    return index;
}

- (Tile*) getTile:(NSNumber*) index {
    for (Tile* t in currentTiles) {
        if([t.index intValue] == [index intValue]) {
            return t;
        }
    }
    return nil;
}

- (void) animateTileMovement:(Tile*)tile destination:(CGRect) newPos {
    //int height = newPos.size.height;
    //int width = newPos.size.width;
    
    [UIView animateWithDuration:0.5 animations:^{
        [tile.label setFrame:newPos];
    } completion:^(BOOL finished) {
        //
    }];
}

// 1 = up, 2 = down, 3 = right, 4 = left
- (NSNumber*) findDestination:(NSNumber*) startIndex direction:(int) dir {
    int modifier = 0;
    int bound = -1;
    //int boundComp = 0; // 1 = must be greater than bound, 2 = must be les than bound
    
    if(dir == 1) {
        modifier = 1;
        bound = (([startIndex intValue] / 4) + 1) * 4;
    }
    if(dir == 2) {
        modifier = -1;
        if([startIndex intValue] > 11) bound = 11;
        else if([startIndex intValue] > 7) bound = 7;
        else if([startIndex intValue] > 3) bound = 3;
        else bound = -1;
    }
    if(dir == 3) {
        modifier = 4;
        bound = 16;
    }
    if(dir == 4) {
        modifier = -4;
        bound = -1;
    }
    
    NSLog(@"findDestination - startIndex: %d direction: %d bound: %d", [startIndex intValue], dir, bound);
    
    bool found = false;
    int lastIndex = [startIndex intValue];
    int destIndex = [startIndex intValue] + modifier;
    
    while(!found) {
        if(modifier < 0) {
            if(destIndex <= bound)
            {
                found = true;
                break;
            }
        }else{
            if(destIndex >= bound)
            {
                found = true;
                break;
            }
        }
        
        if([takenCells containsObject:[NSNumber numberWithInt:destIndex]]) {
            found = true;
        } else {
            lastIndex = destIndex;
            destIndex = destIndex + modifier;
        }
    }
    
    NSLog(@"findDestination - destination: %d", lastIndex);
    
    if(lastIndex == [startIndex intValue]) {
        //return CGRectMake(0, 0, 0, 0);
        return [NSNumber numberWithInt:-1];
    }
    else {
        //return ((UILabel*)[backgroundCells objectAtIndex:lastIndex]).frame;
        return [NSNumber numberWithInt:lastIndex];
    }
}

- (void) moveTilesHelper:(int) index direction:(int) dir{
    if([takenCells containsObject:[NSNumber numberWithInt:index]]) {
        // See how far right we can go
        NSNumber* destination = [self findDestination:[NSNumber numberWithInt:index] direction:dir];
        // Oh we can't go right at all, ok go do the next tile
        if ([destination intValue] < 0) return;
        
        // Get our current tile
        Tile* t = [self getTile:[NSNumber numberWithInt:index]];
        
        // Update values
        t.index = destination;
        [takenCells removeObject:[NSNumber numberWithInt:index]];
        [takenCells addObject:t.index];
        
        // Get destination cell and animate tile to position
        UILabel *bkgdCell = [backgroundCells objectAtIndex:[destination intValue]];
        [self animateTileMovement:t destination:bkgdCell.frame];
    }
}

- (void) moveTiles:(NSString*) direction {
    if([direction isEqualToString:@"RIGHT"]) {
        // Loop through starting from topright and ending at bottomleft
        // Skip rightmost column as they cannot move right
        for (int i = 11; i > -1; i--) {
            [self moveTilesHelper:i direction:3];
        }
    }
    
    if([direction isEqualToString:@"LEFT"]) {
        for (int i = 4; i < 16; i++) {
            [self moveTilesHelper:i direction:4];
        }
    }
    
    if([direction isEqualToString:@"UP"]) {
        for (int i = 2; i < 15; i += 4) {
            [self moveTilesHelper:i direction:1];
        }
        for (int i = 1; i < 14; i += 4) {
            [self moveTilesHelper:i direction:1];
        }
        for (int i = 0; i < 13; i += 4) {
            [self moveTilesHelper:i direction:1];
        }
    }
    
    if([direction isEqualToString:@"DOWN"]) {
        for (int i = 1; i < 14; i += 4) {
            [self moveTilesHelper:i direction:2];
        }
        for (int i = 2; i < 15; i += 4) {
            [self moveTilesHelper:i direction:2];
        }
        for (int i = 3; i < 16; i += 4) {
            [self moveTilesHelper:i direction:2];
        }
    }
    
    [self spawnTile];
}

- (void) spawnTile {
    // Get index of empty position
    NSNumber *spawnPosition = [self getEmptyIndex];
    if([spawnPosition intValue] < 0){
        [self gameOver];
        return;
    }
    
    NSLog(@"Spawning tile at: %d", [spawnPosition intValue]);
    [takenCells addObject:spawnPosition];
    
    // Get background cell of index
    UILabel *bkgdCell = [backgroundCells objectAtIndex:[spawnPosition intValue]];
    //NSLog(@"%@", [bkgdCell text]);
    
    // Get tile position and size
    int x = bkgdCell.frame.origin.x;
    int y = bkgdCell.frame.origin.y;
    int height = bkgdCell.frame.size.height;
    int width = bkgdCell.frame.size.width;
    
    // Create new Tile
    UILabel *madeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [madeLabel setText:@"test"];
    [madeLabel setTextAlignment:NSTextAlignmentCenter];
    [madeLabel setBackgroundColor:[UIColor blueColor]];
    [madeLabel setAlpha:0.0f];
    madeLabel.layer.cornerRadius = 8;
    madeLabel.layer.masksToBounds = TRUE;
    
    // Animate tile appearing so it is not delayed
    [UIView animateWithDuration:0.5 animations:^{
        [madeLabel setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //
    }];
    
    Tile* tile = [[Tile alloc] init];
    tile.label = madeLabel;
    tile.index = spawnPosition;
    
    [currentTiles addObject:tile];
    
    [[self view] addSubview:madeLabel];
}

@end
