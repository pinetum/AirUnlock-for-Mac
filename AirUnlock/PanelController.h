#import "BackgroundView.h"
#import "StatusItemView.h"


@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    

}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;
@property (unsafe_unretained) IBOutlet NSImageView *mImgView;
@property (unsafe_unretained) SecKeychainRef keychain;

@property (nonatomic) NSString *keyChain_serviceName ;
@property (nonatomic) NSString *keyChain_accountName ;
@property (nonatomic) NSString *keyChain_passwordData;


- (void)openPanel;
- (void)closePanel;
- (void)showUpdatePasswordDialog;
@end
