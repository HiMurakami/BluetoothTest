//
//  BlueController.h
//  BlueSCTest
//
//  Created by junpeiwada on 2013/05/20.
//  Copyright (c) 2013年 soneru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueController : NSObject
@property (nonatomic, readonly) NSMutableArray *discoverdPeripherals;

@property (nonatomic, readonly) BOOL isBTPoweredOn;
@property (nonatomic, readonly) BOOL isScanning;

@property (nonatomic, readonly) int  deviceRSSI;
@property (nonatomic, readonly) int  txPower;
@property (nonatomic, readonly) int  batteryLevel;

@property (nonatomic, readonly) double  speed;
@property (nonatomic, readonly) double  cadence;
@property (nonatomic, readonly) int  wheelRevolutions;
@property (nonatomic, readonly) int  crankRevolutions;

@property (nonatomic, readonly) int  heartrate;

@property (nonatomic,readonly) CBPeripheral *connectedBlueSC;
@property (nonatomic,readonly) CBPeripheral *connectedBlueHR;



-(void)startScanning;
-(void)stopScanning;

-(void)connect:(CBPeripheral *)p;
-(void)disconnect:(CBPeripheral *)p;
-(void)disconnectAll;
@end
