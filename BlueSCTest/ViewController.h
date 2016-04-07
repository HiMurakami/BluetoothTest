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
