#import "MenubarController.h"
#import "PanelController.h"
#import <IOBluetooth/IOBluetooth.h>



extern const NSString *lockScript;
extern const NSString *unlockScriptBase;
@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate, CBPeripheralManagerDelegate>
@property AuthorizationRef authRef;


- (IBAction)togglePanel:(id)sender;



@end


