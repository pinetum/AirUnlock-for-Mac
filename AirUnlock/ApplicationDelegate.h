#import "MenubarController.h"
#import "PanelController.h"
#import <IOBluetooth/IOBluetooth.h>
#import <CoreBluetooth/CoreBluetooth.h>


extern const NSString *lockScript;
@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate, CBPeripheralManagerDelegate>
@property AuthorizationRef authRef;


- (IBAction)togglePanel:(id)sender;



@end


