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

static int noMoveCount;

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
    
    noMoveCount = 0;
    
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
    NSLog(@"RESET GAME");
    // Animate tiles falling!
    [self animateFallingTiles:0];
    [UIView animateWithDuration:0.2 * [currentTiles count] animations:^{
        //[self.resetButton setTitle:@"RESETTING..." forState:UIControlStateNormal];
        [self.resetButton setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.resetButton setAlpha:1.0f];
        //[self.resetButton setTitle:@"RESET" forState:UIControlStateNormal];
        currentTiles = [[NSMutableArray alloc] init];
        takenCells = [[NSMutableArray alloc] init];
        noMoveCount = 0;
        [self spawnTile];
        [self spawnTile];
        [self updateScore];
    }];
}

- (void) animateFallingTiles:(int) index{
    if(index > 15) return;
    
    UILabel *label = [self getTile:[NSNumber numberWithInt:index]].label;
    
    int x = label.frame.origin.x;
    int y = label.frame.origin.y;// + [UIScreen mainScreen].bounds.size.height;
    int width = label.frame.size.width;
    int height = label.frame.size.height;
    
    int xModify = 1 + arc4random_uniform(5);
    int leftRight;
    if(index % 2 == 0) {
        leftRight = 1;
    } else {
        leftRight = -1;
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [label setFrame:CGRectMake(x + (xModify * leftRight), y - 15, width, height)];
    } completion:^(BOOL finished) {
        [self animateFallingTiles:index + 1];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [label setFrame:CGRectMake(x + (xModify * 20 * leftRight), y + [UIScreen mainScreen].bounds.size.height, width, height)];
        } completion:^(BOOL finished) {
            //
        }];
    }];
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
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GAME OVER" message:@"You lost! Too bad" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    [resetButton setHidden:false];*/
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
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [tile.label setFrame:newPos];
    } completion:^(BOOL finished) {
        //
    }];
    /*
    [UIView animateWithDuration:0.2 animations:^{
        [tile.label setFrame:newPos];
    } completion:^(BOOL finished) {
        //
    }];*/
}

// Will flatly decrement the green, then red by 10 each time
- (UIColor*) chooseColor:(int) value {
    
    //there is a bug here, 64 and 128 both return 6 somehow??????????
    int modifier = log10f(value) / log10f(2);

    float greenValue = (255.0f - ((float)pow(2, modifier) * 5.0f)) / 255.0f;
    float blueValue = 1.0f;
    
    if(greenValue < 0) {
        blueValue = (255.0f - ((float)pow(2, modifier - 4) * 5.0f)) / 255.0f;
    }
    
    return [[UIColor alloc] initWithRed:1.0f green:greenValue blue:blueValue alpha:1.0f];
}

- (NSNumber*) eatTiles:(int) srcIndex destinationIndex:(int) dstIndex {
    Tile* srcTile = [self getTile:[NSNumber numberWithInt:srcIndex]];
    Tile* dstTile = [self getTile:[NSNumber numberWithInt:dstIndex]];
    
    if(dstTile.changed || srcTile.changed) {
        return nil;
    }
    
    if([srcTile.value intValue] == [dstTile.value intValue]) {
        // Delete destination tile, change value of src to 2x
        [takenCells removeObject:dstTile.index];
        [currentTiles removeObject:dstTile];
        srcTile.value = [NSNumber numberWithInt:[srcTile.value intValue] * 2];
        [srcTile.label setText:[NSString stringWithFormat:@"%d", [srcTile.value intValue]]];
        // set color
        [srcTile.label setBackgroundColor:[self chooseColor:[srcTile.value intValue]]];
        [srcTile.label.layer setBorderColor: [self chooseColor:8].CGColor];
        [srcTile.label.layer setBorderWidth: 2.0f];
        srcTile.changed = true;
        dstTile.changed = true;
        
        [UIView animateWithDuration:0.1 animations:^{
            dstTile.label.transform = CGAffineTransformScale(dstTile.label.transform, 0.25, 0.25);
            [dstTile.label setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [dstTile.label removeFromSuperview];
        }];
        return dstTile.index;
    }
    return nil;
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
            // CHECK IF IT CAN BE "EATEN"
            NSNumber* dest = [self eatTiles:[startIndex intValue] destinationIndex:destIndex];
            if(dest != nil) {
                lastIndex = [dest intValue];
            }
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

- (int) moveTilesHelper:(int) index direction:(int) dir{
    if([takenCells containsObject:[NSNumber numberWithInt:index]]) {
        // See how far we can go
        NSNumber* destination = [self findDestination:[NSNumber numberWithInt:index] direction:dir];
        // Oh we can't go right at all, ok go do the next tile
        if ([destination intValue] < 0) return 0;
        
        // Get our current tile
        Tile* t = [self getTile:[NSNumber numberWithInt:index]];
        
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
    
    NSLog(@"%d tiles moved!", tilesMoved);
    
    if(tilesMoved > 0) {
        noMoveCount = 0;
        
        for(Tile *t in currentTiles) {
            t.changed = false;
        }
        
        [self updateScore];
        [self spawnTile];
    } else if ([[self getEmptyIndex] intValue] < 0)
    {
        if(noMoveCount > 4) {
            [self gameOver];
            return;
        } else {
            noMoveCount++;
        }
    }
}

- (void) updateScore {
    int totalScore = 0;
    
    for (Tile *t in currentTiles) {
        totalScore += [t.value intValue];
    }
    
    [scoreDisplay setText:[NSString stringWithFormat:@"%d", totalScore]];
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
    
    // Animate tile appearing so it is not delayed
    [UIView animateWithDuration:0.5 animations:^{
        [madeLabel setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //
    }];
    
    Tile* tile = [[Tile alloc] init];
    tile.label = madeLabel;
    tile.index = spawnPosition;
    tile.value = [NSNumber numberWithInt:value];
    
    [currentTiles addObject:tile];
    
    [[self view] addSubview:madeLabel];
}

@end
