
#import <Foundation/Foundation.h>

@interface Setting : NSObject
+ (Setting *)instance;

@property (nonatomic,weak)NSString *targetBlueSC_UUID;
@property (nonatomic,weak)NSString *targetBlueHR_UUID;

@end
