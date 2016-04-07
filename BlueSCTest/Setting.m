
#import "Setting.h"

@implementation Setting

+ (Setting *)instance{
    static Setting *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

-(NSString *)targetBlueSC_UUID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"targetBlueSC-UUID"];
}
-(void)setTargetBlueSC_UUID:(NSString *)targetBlueSC_UUID{
    [[NSUserDefaults standardUserDefaults]setValue:targetBlueSC_UUID forKey:@"targetBlueSC-UUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)targetBlueHR_UUID{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"targetBlueHR-UUID"];
}
-(void)setTargetBlueHR_UUID:(NSString *)targetBlueHR_UUID{
    [[NSUserDefaults standardUserDefaults]setValue:targetBlueHR_UUID forKey:@"targetBlueHR-UUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
