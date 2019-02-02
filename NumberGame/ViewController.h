//
//  ViewController.h
//  NumberGame
//
//  Created by Anchu Lee on 1/30/19.
//  Copyright © 2019 Anchu Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>
#import "Tile.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *cell00;
@property (nonatomic, strong) IBOutlet UILabel *cell01;
@property (nonatomic, strong) IBOutlet UILabel *cell02;
@property (nonatomic, strong) IBOutlet UILabel *cell03;

@property (nonatomic, strong) IBOutlet UILabel *cell10;
@property (nonatomic, strong) IBOutlet UILabel *cell11;
@property (nonatomic, strong) IBOutlet UILabel *cell12;
@property (nonatomic, strong) IBOutlet UILabel *cell13;

@property (nonatomic, strong) IBOutlet UILabel *cell20;
@property (nonatomic, strong) IBOutlet UILabel *cell21;
@property (nonatomic, strong) IBOutlet UILabel *cell22;
@property (nonatomic, strong) IBOutlet UILabel *cell23;

@property (nonatomic, strong) IBOutlet UILabel *cell30;
@property (nonatomic, strong) IBOutlet UILabel *cell31;
@property (nonatomic, strong) IBOutlet UILabel *cell32;
@property (nonatomic, strong) IBOutlet UILabel *cell33;

@property (nonatomic, strong) IBOutlet UIButton *resetButton;

@property (nonatomic, strong) IBOutlet UILabel *scoreDisplay;

@end

