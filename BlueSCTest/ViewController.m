#import "ViewController.h"
#import "AppDelegate.h"
#import "DeviceListViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSNotificationCenter *noti = [NSNotificationCenter defaultCenter];
    [noti addObserver:self selector:@selector(hoge) name:@"UpdateValue" object:nil];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blueC = app.blueC;
}
-(void)hoge{
    self.speedLabel.text = [NSString stringWithFormat:@"%0.2f",self.blueC.speed];
    self.cadenceLabel.text = [NSString stringWithFormat:@"%0.0f",self.blueC.cadence];
    
    self.heartrateLabel.text = [NSString stringWithFormat:@"%d",self.blueC.heartrate];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDeviceList"])
    {
        UINavigationController *destNavi = (UINavigationController *)segue.destinationViewController;
        DeviceListViewController *destination = (DeviceListViewController *)destNavi.viewControllers[0];
        destination.blueC = self.blueC;
    }
}
- (IBAction)disconnectAll:(id)sender {
    [self.blueC disconnectAll];
    [self.blueC stopScanning];
}

- (IBAction)connectAll:(id)sender {
    [self.blueC startScanning];
    for (CBPeripheral *p in self.blueC.discoverdPeripherals) {
        [self.blueC connect:p];
    }
}
@end
