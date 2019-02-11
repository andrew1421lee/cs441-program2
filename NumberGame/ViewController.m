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

@synthesize resetButton, scoreDisplay;

static NSArray *backgroundCells;
static NSArray *tileValues;

static NSMutableArray *currentTiles;
static NSMutableArray *takenCells;

static bool animationPlaying;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Put background cells into an array
    backgroundCells = [NSArray arrayWithObjects:
                       cell00, cell01, cell02, cell03,
                       cell10, cell11, cell12, cell13,
                       cell20, cell21, cell22, cell23,
                       cell30, cell31, cell32, cell33, nil];
    tileValues = [NSArray arrayWithObjects: [NSNumber numberWithInt:2], [NSNumber numberWithInt:4], nil];
    currentTiles = [[NSMutableArray alloc] init];
    takenCells = [[NSMutableArray alloc] init];
    
    animationPlaying = true;
    
    // SWIPE GESTURE RECOGNIZERS
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
    
    [self spawnTile];
    [self spawnTile];
    [self updateScore];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction) resetButtonPressed:(id) sender {
    NSLog(@"[resetButtonPressed] RESETTING GAME");
    // Animate tiles falling!
    [self animateFallingTiles:0];
    
    animationPlaying = true;
    // Animate button disappearing based on how many tiles need to be animated
    [UIView animateWithDuration:0.2 * [currentTiles count] animations:^{
        [self.resetButton setAlpha:0.0f];
    } completion:^(BOOL finished) {
        // Once animation is done, reset the game variables
        [self.resetButton setAlpha:1.0f];

        currentTiles = [[NSMutableArray alloc] init];
        takenCells = [[NSMutableArray alloc] init];
        
        // Spawn new tiles and update the score
        [self spawnTile];
        [self spawnTile];
        [self updateScore];
        
        animationPlaying = false;
    }];
}

// The gesture recognizers will call this method, which will then send data to the moveTiles method
// to move the tiles
- (void) handleSwipe:(UISwipeGestureRecognizer*) sender {
    
    // Lock movement if animation is playing
    if(animationPlaying) {
        return;
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"[handleSwipe] Incoming Gesture: UP");
        [self moveTiles:@"UP"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"[handleSwipe] Incoming Gesture: DOWN");
        [self moveTiles:@"DOWN"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"[handleSwipe] Incoming Gesture: LEFT");
        [self moveTiles:@"LEFT"];
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"[handleSwipe] Incoming Gesture: RIGHT");
        [self moveTiles:@"RIGHT"];
    }
}

- (void) gameOver {
    // Create new popup to display game over message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GAME OVER" message:@"You lost! Too bad" preferredStyle:UIAlertControllerStyleAlert];
    
    // Assign button to reset thegame
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self resetButtonPressed:nil];
     }];
    
    [alert addAction:ok];
    
    // Show the popup
    [self presentViewController:alert animated:YES completion:nil];
}

// Returns true if game over
- (BOOL) checkGameOver {
    // Do not call recursive function if board is not filled
    if([currentTiles count] != 16) {
        return false;
    }
    // Call recursive function with starting index
    return [self _checkGameOverRecursive:0];
}

- (BOOL) _checkGameOverRecursive:(int) index {
    // Get the tile by index
    Tile *src = [self getTileByPositionIndex:[NSNumber numberWithInt:index]];
    
    // DO NOT CHECK ABOVE IF TILE IS TOPMOST
    if(index != 3 && index != 7 && index != 11 && index != 15) {
        // check tile above (+ 1)
        Tile *above = [self getTileByPositionIndex:[NSNumber numberWithInt:index + 1]];
        
        // Found a match, no need to continue to recurse
        if(src.value == above.value) {
            return false;
        }
    }
    
    // DO NOT CHECK RIGHT IF TILE IS RIGHTMOST
    if(index != 12 && index != 13 && index != 14 && index != 15) {
        // check tile to the right (+4)
        Tile *right = [self getTileByPositionIndex:[NSNumber numberWithInt:index + 4]];
        
        // Found a match, no need to continue to recurse
        if(src.value == right.value) {
            return false;
        }
    }
    
    // No match left or right, call on tile above
    if(index != 3 && index != 7 && index != 11 && index != 15) {
        // Match found, stop
        if(![self _checkGameOverRecursive:index + 1]) {
            return false;
        }
    }
    
    // No match after checking top, check right
    if(index != 12 && index != 13 && index != 14 && index != 15) {
        if(![self _checkGameOverRecursive:index + 1]) {
            return false;
        }
    }
    
    // No matches found, game over
    return true;
}

// Returns index in backgroundCells that is empty, -1 if full
- (NSNumber*) getEmptyPositionIndex {
    bool foundIndex = false;
    bool boardIsFull = false;
    
    // Grab a random position index
    NSNumber *index = [NSNumber numberWithUnsignedInteger:arc4random_uniform(16)];
    
    // Loop
    while(!foundIndex && !boardIsFull){
        // check if no empty positions
        if([takenCells count] == 16) {
            NSLog(@"[getEmptyPositionIndex] No empty positions!");
            boardIsFull = true;
            break;
        }
        
        // Check if position is empty, otherwise get new position
        if(![takenCells containsObject:(index)]) {
            foundIndex = true;
        } else {
            index = [NSNumber numberWithUnsignedInteger:arc4random_uniform(16)];
        }
    }
    
    // If no empty positions, return -1
    if(boardIsFull)
    {
        index = [NSNumber numberWithInt:-1];
    }
    
    return index;
}

// Returns tile at given position index
- (Tile*) getTileByPositionIndex:(NSNumber*) index {
    for (Tile* t in currentTiles) {
        if([t.index intValue] == [index intValue]) {
            return t;
        }
    }
    return nil;
}

// Will determine color based the value of x (2^x = value)
- (UIColor*) chooseColor:(int) value {
    
    //there is a bug here, 64 and 128 both return 6 somehow??????????
    int modifier = log10f(value) / log10f(2);

    // Decrease green value by x * 5
    float greenValue = (255.0f - ((float)pow(2, modifier) * 5.0f)) / 255.0f;
    float blueValue = 1.0f;
    
    // If green value is 0, decrease blue value by value 5.0 as well
    if(greenValue < 0) {
        blueValue = (255.0f - ((float)pow(2, modifier - 4) * 5.0f)) / 255.0f;
    }
    
    // Return new color
    return [[UIColor alloc] initWithRed:1.0f green:greenValue blue:blueValue alpha:1.0f];
}

// Given two positions, see if they can be combined
- (NSNumber*) tryCombineTilesByIndex:(int) srcIndex destinationIndex:(int) dstIndex {
    // Get the two tile objects
    Tile* srcTile = [self getTileByPositionIndex:[NSNumber numberWithInt:srcIndex]];
    Tile* dstTile = [self getTileByPositionIndex:[NSNumber numberWithInt:dstIndex]];
    
    // Check if either tile was already combined in the same move
    if(dstTile.changed || srcTile.changed) {
        return nil;
    }
    
    // If the values are the same, combine
    if([srcTile.value intValue] == [dstTile.value intValue]) {
        // Delete destination tile, change value of src to 2x
        [takenCells removeObject:dstTile.index];
        [currentTiles removeObject:dstTile];
        srcTile.value = [NSNumber numberWithInt:[srcTile.value intValue] * 2];
        // Update the label of src
        [srcTile.label setText:[NSString stringWithFormat:@"%d", [srcTile.value intValue]]];
        // set color
        [srcTile.label setBackgroundColor:[self chooseColor:[srcTile.value intValue]]];
        [srcTile.label.layer setBorderColor: [self chooseColor:8].CGColor];
        [srcTile.label.layer setBorderWidth: 2.0f];
        // set changed flag
        srcTile.changed = true;
        dstTile.changed = true;
        
        // Animate dst deletion
        [UIView animateWithDuration:0.1 animations:^{
            dstTile.label.transform = CGAffineTransformScale(dstTile.label.transform, 0.25, 0.25);
            [dstTile.label setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [dstTile.label removeFromSuperview];
        }];
        // Return position for src to go to
        return dstTile.index;
    }
    
    if([srcTile.value intValue] >= 2048) {
        [self animateWinTile:srcTile];
    }
    
    // Cannot be combined
    return nil;
}

// 1 = up, 2 = down, 3 = right, 4 = left
- (NSNumber*) findDestination:(NSNumber*) startIndex direction:(int) dir {
    // How to reach the next tile in given direction
    int modifier = 0;
    
    // Used to stop code from checking tiles not next to it
    int bound = -1;
    
    // Set modifier and bound based on direction and starting index
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
    
    NSLog(@"[findDestination] startIndex: %d direction: %d bound: %d", [startIndex intValue], dir, bound);
    
    bool found = false;
    
    // current position
    int lastIndex = [startIndex intValue];
    
    // Next position
    int destIndex = [startIndex intValue] + modifier;
    
    while(!found) {
        // Stop if bound is reached
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
        
        // If next position has a tile
        if([takenCells containsObject:[NSNumber numberWithInt:destIndex]]) {
            // CHECK IF IT CAN BE "EATEN"
            NSNumber* dest = [self tryCombineTilesByIndex:[startIndex intValue] destinationIndex:destIndex];
            // Cannot be eaten, use previous position
            if(dest != nil) {
                lastIndex = [dest intValue];
            }
            found = true;
            
        // Otherwise, continue to next tiles
        } else {
            lastIndex = destIndex;
            destIndex = destIndex + modifier;
        }
    }
    
    NSLog(@"[findDestination] destination: %d", lastIndex);
    
    // If position is where we found it, tile does not move
    if(lastIndex == [startIndex intValue]) {
        return [NSNumber numberWithInt:-1];
    }
    else {
        return [NSNumber numberWithInt:lastIndex];
    }
}

- (int) moveTilesHelper:(int) index direction:(int) dir{
    if([takenCells containsObject:[NSNumber numberWithInt:index]]) {
        // See how far we can go
        NSNumber* destination = [self findDestination:[NSNumber numberWithInt:index] direction:dir];
        // Oh we can't go right at all, ok go do the next tile
        if ([destination intValue] < 0) return 0;
        
        // Get our current tile
        Tile* t = [self getTileByPositionIndex:[NSNumber numberWithInt:index]];
        
        // Update values
        t.index = destination;
        [takenCells removeObject:[NSNumber numberWithInt:index]];
        [takenCells addObject:t.index];
        
        // Get destination cell and animate tile to position
        UILabel *bkgdCell = [backgroundCells objectAtIndex:[destination intValue]];
        [self animateTileMovement:t destination:bkgdCell.frame];
        return 1;
    }
    return 0;
}

- (void) moveTiles:(NSString*) direction {
    int tilesMoved = 0;
    
    if([direction isEqualToString:@"RIGHT"]) {
        // Loop through starting from topright and ending at bottomleft
        // Skip rightmost column as they cannot move right
        for (int i = 11; i > -1; i--) {
            tilesMoved += [self moveTilesHelper:i direction:3];
        }
    }
    
    if([direction isEqualToString:@"LEFT"]) {
        for (int i = 4; i < 16; i++) {
            tilesMoved += [self moveTilesHelper:i direction:4];
        }
    }
    
    if([direction isEqualToString:@"UP"]) {
        for (int i = 2; i < 15; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:1];
        }
        for (int i = 1; i < 14; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:1];
        }
        for (int i = 0; i < 13; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:1];
        }
    }
    
    if([direction isEqualToString:@"DOWN"]) {
        for (int i = 1; i < 14; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:2];
        }
        for (int i = 2; i < 15; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:2];
        }
        for (int i = 3; i < 16; i += 4) {
            tilesMoved += [self moveTilesHelper:i direction:2];
        }
    }
    
    NSLog(@"[moveTiles] %d tiles moved!", tilesMoved);
    
    if(tilesMoved > 0) {
        for(Tile *t in currentTiles) {
            t.changed = false;
        }
        
        [self updateScore];
        [self spawnTile];
    } else if ([[self getEmptyPositionIndex] intValue] < 0)
    {
        if([self checkGameOver]) {
            [self gameOver];
            return;
        }
    }
}

// Adds up all the values in current tiles
- (void) updateScore {
    int totalScore = 0;
    
    for (Tile *t in currentTiles) {
        totalScore += [t.value intValue];
    }
    
    [scoreDisplay setText:[NSString stringWithFormat:@"%d", totalScore]];
}

- (void) spawnTile {
    // Get index of empty position
    NSNumber *spawnPosition = [self getEmptyPositionIndex];
    if([spawnPosition intValue] < 0){
        if([self checkGameOver]) {
            [self gameOver];
            return;
        }
    }
    
    NSLog(@"[spawnTile] Spawning tile at: %d", [spawnPosition intValue]);
    [takenCells addObject:spawnPosition];
    
    // Get background cell of index
    UILabel *bkgdCell = [backgroundCells objectAtIndex:[spawnPosition intValue]];
    //NSLog(@"%@", [bkgdCell text]);
    
    // Get tile position and size
    int x = bkgdCell.frame.origin.x;
    int y = bkgdCell.frame.origin.y;
    int height = bkgdCell.frame.size.height;
    int width = bkgdCell.frame.size.width;
    
    // Get value of Tile
    int randomValue = arc4random_uniform((uint32_t)[tileValues count]);
    int value = [[tileValues objectAtIndex:randomValue] intValue];
    
    // Create new Tile
    UILabel *madeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [madeLabel setText:[NSString stringWithFormat:@"%d", value]];
    [madeLabel setTextAlignment:NSTextAlignmentCenter];
    [madeLabel setAlpha:0.0f];
    madeLabel.layer.cornerRadius = 8;
    madeLabel.layer.masksToBounds = TRUE;
    
    // set tile color
    [madeLabel setBackgroundColor: [self chooseColor:value]];
    [madeLabel.layer setBorderColor: [self chooseColor:8].CGColor];
    [madeLabel.layer setBorderWidth: 2.0f];
    
    
    animationPlaying = true;
    // Animate tile appearing so it is not delayed
    [UIView animateWithDuration:0.5 animations:^{
        [madeLabel setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //
        animationPlaying = false;
    }];
    
    Tile* tile = [[Tile alloc] init];
    tile.label = madeLabel;
    tile.index = spawnPosition;
    tile.value = [NSNumber numberWithInt:value];
    
    [currentTiles addObject:tile];
    
    [[self view] addSubview:madeLabel];
}

// Animate falling tile when reset, given position index
- (void) animateFallingTiles:(int) index{
    if(index > 15) return;
    
    // Grab label from tile at index
    UILabel *label = [self getTileByPositionIndex:[NSNumber numberWithInt:index]].label;
    
    // Get initial values of label
    int x = label.frame.origin.x;
    int y = label.frame.origin.y;
    int width = label.frame.size.width;
    int height = label.frame.size.height;
    
    // Randomly choose position modifier (1-4) and determine left or right by index
    int xModify = 1 + arc4random_uniform(5);
    int leftRight;
    if(index % 2 == 0) {
        leftRight = 1;
    } else {
        leftRight = -1;
    }
    
    // Animate upwards at an angle defined by modifier and leftRight
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [label setFrame:CGRectMake(x + (xModify * leftRight), y - 15, width, height)];
    } completion:^(BOOL finished) {
        // Once tile is at the peak, animate the next tile
        [self animateFallingTiles:index + 1];
        
        // Then animate the falling tile
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [label setFrame:CGRectMake(x + (xModify * 20 * leftRight), y + [UIScreen mainScreen].bounds.size.height, width, height)];
        } completion:^(BOOL finished) {
            //
        }];
    }];
}

// Given tile and pos, move tile to pos
- (void) animateTileMovement:(Tile*)tile destination:(CGRect) newPos {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [tile.label setFrame:newPos];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void) animateWinTile: (Tile*) tile {
    
}

@end
