#import "MenubarController.h"
#import "PanelController.h"
#import <IOBluetooth/IOBluetooth.h>
#import <CoreBluetooth/CoreBluetooth.h>


extern void SACLockScreenImmediate();
extern void IOBluetoothPreferenceSetControllerPowerState();
@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate, CBPeripheralManagerDelegate>
@property AuthorizationRef authRef;


- (IBAction)togglePanel:(id)sender;



@end


