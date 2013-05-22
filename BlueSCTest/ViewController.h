//
//  ViewController.h
//  BlueSCTest
//
//  Created by junpeiwada on 2013/05/20.
//  Copyright (c) 2013年 soneru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueController.h"
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *cadenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartrateLabel;
@property (nonatomic) BlueController *blueC;
- (IBAction)disconnectAll:(id)sender;
- (IBAction)connectAll:(id)sender;

@end
