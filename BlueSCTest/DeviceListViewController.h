//
//  DeviceListViewController.h
//  BlueSCTest
//
//  Created by junpeiwada on 2013/05/21.
//  Copyright (c) 2013年 soneru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueController.h"
@interface DeviceListViewController : UITableViewController{
    
}
@property (nonatomic) BlueController *blueC;
- (IBAction)cancel:(id)sender;
@end
