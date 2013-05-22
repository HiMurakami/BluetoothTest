//
//  BlueController.m
//  BlueSCTest
//
//  Created by junpeiwada on 2013/05/20.
//  Copyright (c) 2013年 soneru. All rights reserved.
//

#import "BlueController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define kSpeedCadenceServiceUUID            @"1816" //BlueSC
#define kCscMesurementCharacteristicsUUID   @"2A5B" //スピードケイデンスキャラクタリスティクス

#define kHeartrateServiceUUID               @"180D" // Heartrate
#define kHeartrateMesurementCharacteristicsUUID @"2A37" // ハートレート計測キャラクタリスティクス

@interface BlueController() <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *_centralManager;
    
    CBCharacteristic *_cscMeasurementCharacteristic;
    CBCharacteristic *_hrMeasurementCharacteristic;
    
    CBUUID *_cscServiceUUID;
    CBUUID *_cscMesureCharacteristicsUUID;
    
    CBUUID *_hrServiceUUID;
    CBUUID *_hrMesureCharactaristicsUUID;;
    
    uint32_t _preWheelRev;
    uint16_t _preWheelTime;
    uint16_t _preCrankRev;
    uint16_t _preCrankTime;
    
    CFAbsoluteTime _speedLastUpdateTime;
    CFAbsoluteTime _cadenceLastUpdateTime;
}
@property (nonatomic) double  speed;
@property (nonatomic) double  cadence;
@property (nonatomic) NSMutableArray *discoverdPeripherals;

@property (nonatomic) CBPeripheral *connectedBlueSC;
@property (nonatomic) CBPeripheral *connectedBlueHR;
@end


@implementation BlueController
-(id)init {
    self = [super init];
    
    _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    _cscServiceUUID = [CBUUID UUIDWithString:kSpeedCadenceServiceUUID];
    _cscMesureCharacteristicsUUID = [CBUUID UUIDWithString:kCscMesurementCharacteristicsUUID];
    
    _hrServiceUUID = [CBUUID UUIDWithString:kHeartrateServiceUUID];
    _hrMesureCharactaristicsUUID = [CBUUID UUIDWithString:kHeartrateMesurementCharacteristicsUUID];
    
    _preWheelRev = 0;
    _preWheelTime = 0;
    _preCrankRev = 0;
    _preCrankTime = 0;
    
    _speedLastUpdateTime = 0;
    _cadenceLastUpdateTime = 0;
    
    self.discoverdPeripherals = [NSMutableArray array];
    
    return self;
}

-(void)startScanning {
    if( !_isBTPoweredOn || _isScanning ) return;
    
    // BLEデバイスのスキャン時には、検索対象とするサービスを指定することが推奨です
    NSArray *scanServices = [NSArray arrayWithObjects:
                             _cscServiceUUID,
                             _hrServiceUUID,
                             nil];
    // スキャンにはオプションが指定できます。いまあるオプションは、ペリフェラルを見つけた時に重複して通知するか、の指定です。
    // 近接検出など、コネクションレスでデバイスの状態を取得する用途などでは、これをYESに設定します。デフォルトでNOです。
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:@NO
                                                            forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    // デバイスのスキャン開始。iPhoneはアドバタイズメント・パケットの受信を開始します。
    // このスキャンは、明示的に停止しない限り、スキャンし続けます。このスキャンは、アドバタイズメント・パケットの(2.4GHzの)受信処理で、RF回路は電力を消費します。
    [_centralManager scanForPeripheralsWithServices:scanServices options:scanOptions];
    
    _isScanning = YES;
}
-(void)stopScanning{
    if(!_isScanning) return;
    
    [_centralManager stopScan];
    
    _isScanning = NO;
}
-(void)connect:(CBPeripheral *)p {
    //ターゲットを発見、接続します
    [_centralManager connectPeripheral:p options:nil];
}
-(void)disconnect:(CBPeripheral *)p{
    // 切断
    [_centralManager cancelPeripheralConnection:p];
}
-(void)disconnectAll{
    // 切断
    for (CBPeripheral *p in _discoverdPeripherals) {
        if (p.isConnected){
            [_centralManager cancelPeripheralConnection:p];
        }
    }
    
    _preWheelRev = 0;
    _preWheelTime = 0;
    _preCrankRev = 0;
    _preCrankTime = 0;
}


#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch ([_centralManager state]) {
        case CBCentralManagerStatePoweredOff:
            // BTがOFFです
            _isBTPoweredOn = NO;
            _isScanning    = NO;
            //            _isConnected   = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            _isBTPoweredOn = YES;
            [self startScanning];
            break;
            
        case CBCentralManagerStateResetting:
            break;
            
        case CBCentralManagerStateUnauthorized:
            // BTが使えない状態
            break;
            
        case CBCentralManagerStateUnknown:
            // ダウン
            break;
            
        case CBCentralManagerStateUnsupported:
            // サポート外のイベント
            break;
    }
}

// ペリフェラルの発見後の処理
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)p
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if (![self.discoverdPeripherals containsObject:p] ){
        [self.discoverdPeripherals addObject:p];
        NSNotification *n = [NSNotification notificationWithName:@"FoundPeripheral" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([localName hasPrefix:@"Wahoo BlueSC"]){
        if ([Setting instance].targetBlueSC_UUID){
            CBUUID *targetUUID = [CBUUID UUIDWithString:[Setting instance].targetBlueSC_UUID];
            if(p.UUID == nil || ! [[CBUUID UUIDWithCFUUID:p.UUID].data isEqualToData:targetUUID.data]){
                [self connect:p];
                NSLog(@"接続開始 - BlueSC");
            }
        }else{
            [self connect:p];
            NSLog(@"接続開始 - Unknown BlueSC");
        }
    }
    
    if ([localName hasPrefix:@"Wahoo HRM"]){
        if ([Setting instance].targetBlueHR_UUID){
            CBUUID *targetUUID = [CBUUID UUIDWithString:[Setting instance].targetBlueHR_UUID];
            if(p.UUID == nil || ! [[CBUUID UUIDWithCFUUID:p.UUID].data isEqualToData:targetUUID.data]){
                [self connect:p];
                NSLog(@"接続開始 - BlueHR");
            }
        }else{
            [self connect:p];
            NSLog(@"接続開始 - Unknown BlueHR");
        }
    }
}

-(void)disconnectIntrinsic {
    _batteryLevel   = 0;
    _isScanning  = NO;
}

// 接続失敗
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    [self disconnectIntrinsic];
}

// 接続
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)p {
    // サービスを探します
    p.delegate = self;
    
    [p discoverServices:nil];
    NSLog(@"Connected! %@",p.name);
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    
    [self disconnectIntrinsic];
}


#pragma mark CBPeripheralDelegate
//発見したサービスに対して、Characteristicsを探します
- (void)peripheral:(CBPeripheral *)p didDiscoverServices:(NSError *)error {
    for (CBService *service in p.services) {
        // BSC
        if ([service.UUID.data isEqualToData:_cscServiceUUID.data]) {
            [p discoverCharacteristics:[NSArray arrayWithObjects:
                                        _cscMesureCharacteristicsUUID,
                                        nil]
                            forService:service];
        }
        
        // HR
        if ([service.UUID.data isEqualToData:_hrServiceUUID.data]) {
            [p discoverCharacteristics:[NSArray arrayWithObjects:
                                        _hrMesureCharactaristicsUUID,
                                        nil]
                            forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)p didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *c in service.characteristics) {
        
        // BSCのキャラクタリスティクスをNotify
        if ([service.UUID.data isEqualToData:_cscServiceUUID.data]) {
            _cscMeasurementCharacteristic = [self findCharacteristics:service.characteristics uuid:_cscMesureCharacteristicsUUID];
            if (_cscMeasurementCharacteristic) {
                [p setNotifyValue:YES forCharacteristic:_cscMeasurementCharacteristic];
                [p readValueForCharacteristic:_cscMeasurementCharacteristic];
            }
        }
        
        // HRのキャラクタリスティクスをNotify
        if ([service.UUID.data isEqualToData:_hrServiceUUID.data]) {
            _hrMeasurementCharacteristic = [self findCharacteristics:service.characteristics uuid:_hrMesureCharactaristicsUUID];
            if (_hrMeasurementCharacteristic) {
                [p setNotifyValue:YES forCharacteristic:_hrMeasurementCharacteristic];
                [p readValueForCharacteristic:_hrMeasurementCharacteristic];
            }
        }
    }
    
}
-(CBCharacteristic *)findCharacteristics:(NSArray *)cs uuid:(CBUUID *)uuid
{
    for (CBCharacteristic *c in cs) {
        if ([c.UUID.data isEqualToData:uuid.data]) {
            return c;
        }
    }
    return nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self notifyBSC:peripheral UpdateValueForCharacteristic:characteristic];
}


-(void)notifyBSC:(CBPeripheral *)peripheral UpdateValueForCharacteristic:(CBCharacteristic *)characteristic{
    
    if(characteristic == _cscMeasurementCharacteristic) {
        uint8_t mandatory = 0;
        
        uint32_t wheelRev = 0;
        uint16_t wheelTime = 0;
        
        uint16_t crankRev = 0;
        uint16_t crankTime = 0;
        
        // スピード、ケイデンスがサポートされているか調べる
        [characteristic.value getBytes:&mandatory range:NSMakeRange(0, 1)];
        if (mandatory & 0x1) {
            [characteristic.value getBytes:&wheelRev range:NSMakeRange(1, 4)];
            [characteristic.value getBytes:&wheelTime range:NSMakeRange(5, 2)];
        }
        if (mandatory & 0x2) {
            [characteristic.value getBytes:&crankRev range:NSMakeRange(7, 2)];
            [characteristic.value getBytes:&crankTime range:NSMakeRange(9, 2)];
        }
        
        // 0に戻す処理。2秒センサーに変化がなければ0
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime diffSpeed = now - _speedLastUpdateTime;
        if (diffSpeed >2){
            self.speed = 0;
        }
        CFAbsoluteTime diffCadence = now - _cadenceLastUpdateTime;
        if (diffCadence >2){
            self.cadence = 0;
        }
        
        // 速度の計算
        if (_preWheelTime > 0){
            if (_preWheelTime != wheelTime){
                // この２つはbitが一周することを考えないといけない
                int diffWheel = wheelRev - _preWheelRev;
                if(diffWheel <0){
                    wheelRev = 0xFFFFFFFF - _preWheelRev + wheelRev;
                }
                double diffWheelTime = wheelTime - _preWheelTime;
                if(diffWheelTime <0){
                    diffWheelTime = 0xFFFF - _preWheelTime + wheelTime;
                } //一周したのを戻す
                double speed = diffWheel / (diffWheelTime / 1024) * 3600 * 0.002096;
                //NSLog(@"Speed = %f diffTime = %f",speed,diffWheelTime);
                
                if (speed < 0){
                    NSLog(@"スピードがマイナスw");
                }
                
                self.speed = speed;
                _speedLastUpdateTime= CFAbsoluteTimeGetCurrent();
            }
        }
        
        // ケイデンスの計算
        if (_preCrankTime > 0){
            if (_preCrankTime != crankTime){
                // この２つはbitが一周することを考えないといけない
                int diffCrank = crankRev - _preCrankRev;
                if(diffCrank <0){
                    diffCrank = 0xFFFF - _preCrankRev + crankRev;
                }
                double diffCrankTime = crankTime - _preCrankTime;
                if(diffCrankTime <0){
                    diffCrankTime = 0xFFFF - _preCrankTime + crankTime;
                }
                double cadence = diffCrank / (diffCrankTime / 1024) * 60;
                //NSLog(@"cadence = %f diffTime = %f",cadence,diffCrankTime);
                
                if (cadence < 0){
                    NSLog(@"ケイデンスがマイナスw");
                }
                
                self.cadence = cadence;
                _cadenceLastUpdateTime= CFAbsoluteTimeGetCurrent();
            }
        }
        _preWheelRev = wheelRev;
        _preWheelTime = wheelTime;
        
        _preCrankRev = crankRev;
        _preCrankTime = crankTime;
        
        NSNotification *n = [NSNotification notificationWithName:@"UpdateValue" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
    
    if(characteristic == _hrMeasurementCharacteristic) {
        uint8_t mandatory = 0;
        uint16_t heartrate = 0;
        
        [characteristic.value getBytes:&mandatory range:NSMakeRange(0, 1)];
        
        if (mandatory & 0x1) {
            // HRMが16bit
            [characteristic.value getBytes:&heartrate range:NSMakeRange(1, 2)];
        }else{
            // HRMが8bit
            [characteristic.value getBytes:&heartrate range:NSMakeRange(1, 1)];
        }
        
        _heartrate = heartrate;
        
        NSNotification *n = [NSNotification notificationWithName:@"UpdateValue" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];
    }
}
@end
