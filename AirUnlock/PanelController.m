#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "ZXMultiFormatWriter.h"
#import "ZXingObjC.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

//
//#define POPUP_HEIGHT 122
//#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Follow search string
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSearch) name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    
    //NSRect searchRect = [self.searchField frame];
//    searchRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
//    searchRect.origin.x = SEARCH_INSET;
//    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET - NSHeight(searchRect);
    
//    if (NSIsEmptyRect(searchRect))
//    {
//        [self.searchField setHidden:YES];
//    }
//    else
//    {
//        [self.searchField setFrame:searchRect];
//        [self.searchField setHidden:NO];
//    }
    
    //NSRect textRect = [self.textField frame];
//    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
//    textRect.origin.x = SEARCH_INSET;
//    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
//    textRect.origin.y = SEARCH_INSET;
    
//    if (NSIsEmptyRect(textRect))
//    {
//        [self.textField setHidden:YES];
//    }
//    else
//    {
//        [self.textField setFrame:textRect];
//        [self.textField setHidden:NO];
//    }
}

//#pragma mark - Keyboard
//
//- (void)cancelOperation:(id)sender
//{
//    self.hasActivePanel = NO;
//}
//
//- (void)runSearch
//{
//    //NSString *searchFormat = @"";
//    //NSString *searchString = [self.searchField stringValue];
////    if ([searchString length] > 0)
////    {
////        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
////    }
//    //NSString *searchRequest = [NSString stringWithFormat:searchFormat, searchString];
//    //[self.textField setStringValue:searchRequest];
//}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    [_mImgView setImage:[NSImage imageNamed:@"mbp-un"]];
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    //panelRect.size.width = PANEL_WIDTH;
    //panelRect.size.height = POPUP_HEIGHT;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    //[panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

- (IBAction)btn_update:(NSButton *)sender {
        
    
    
    [self showUpdatePasswordDialog];
    
    
}

- (IBAction)btn_generateQR:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* btAddress = [defaults stringForKey:@"ADDRESS"];
    
    NSString *randString = [[NSUUID UUID] UUIDString];
    
    NSString* lockKeyword = [randString substringWithRange:NSMakeRange(0, 20)];
    NSString* unlockKeyword = [randString substringFromIndex:21];
    [defaults setObject:lockKeyword forKey:@"LOCK"];
    [defaults setObject:unlockKeyword forKey:@"UNLOCK"];
    
    NSString *encodeString =[NSString stringWithFormat:@"%@,%@,%@", btAddress, unlockKeyword, lockKeyword];
    NSLog(@"%@", encodeString);
    
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:encodeString
                                  format:kBarcodeFormatQRCode
                                   width:500
                                  height:500
                                   error:&error];
    if (result) {
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        int h = _mImgView.frame.size.height;
        NSImage *qrImg = [[NSImage alloc] initWithCGImage:image size:(NSSize) {h, h}];
        
        [_mImgView setImage:qrImg];
        
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"%@", errorMessage);
    }
    
    
    
    
    
    
}


-(void)showUpdatePasswordDialog{
    [NSApp activateIgnoringOtherApps:YES];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Password will save in System Keychain"];
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];
    [[[alert buttons] objectAtIndex:0] setKeyEquivalent: @"\r"];
    
    //[alert setAlertStyle:NSCriticalAlertStyle];
    NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@""];
    [alert setAccessoryView:input];
    [alert setIcon:[NSImage imageNamed:@"mbp-un"]];
    [[alert window] setInitialFirstResponder:input];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn && [input.stringValue length]!=0 ) {
        self.keyChain_passwordData = input.stringValue;
        SecKeychainItemRef itemRef = NULL;
        // to check password is exist?
        OSStatus status = SecKeychainFindGenericPassword(self.keychain,
                                                         (UInt32)[self.keyChain_serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                         self.keyChain_serviceName.UTF8String,
                                                         (UInt32)[self.keyChain_accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                         self.keyChain_accountName.UTF8String,
                                                         NULL,NULL,
                                                         &itemRef);
        if(status == noErr){ // exist - modify it
            OSStatus ModifStatus = SecKeychainItemModifyAttributesAndData (itemRef,
                                                                           NULL,
                                                                           (UInt32)[self.keyChain_passwordData lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                                           self.keyChain_passwordData.UTF8String);
            if(ModifStatus == noErr){
                NSLog(@"Password saved");
            }
            
            else
                NSLog((__bridge NSString *)SecCopyErrorMessageString(status, NULL));
        }
        else if (status == errSecItemNotFound){ // not exist - add it
            OSStatus status= SecKeychainAddGenericPassword(self.keychain,
                                                           (UInt32)[self.keyChain_serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ,
                                                           self.keyChain_serviceName.UTF8String,
                                                           (UInt32)[self.keyChain_accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                           self.keyChain_accountName.UTF8String,
                                                           (UInt32)[self.keyChain_passwordData lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                           self.keyChain_passwordData.UTF8String,
                                                           NULL);
            if(status == noErr)
                NSLog(@"Password saved");
            else
                NSLog((__bridge NSString *)SecCopyErrorMessageString(status, NULL));
        }
        else
            NSLog((__bridge NSString *)SecCopyErrorMessageString(status, NULL));
        
        
    }


}
@end
