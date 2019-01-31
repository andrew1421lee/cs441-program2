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

- (void)viewDidLoad {
    [super viewDidLoad];
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
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"DOWN");
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"LEFT");
    }
    
    if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"RIGHT");
    }
}


@end
