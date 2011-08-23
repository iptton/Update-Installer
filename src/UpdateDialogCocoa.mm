#include "UpdateDialogCocoa.h"

#include <Cocoa/Cocoa.h>

#include "Log.h"
#include "StringUtils.h"

@interface UpdateDialogDelegate : NSObject
{
	@public UpdateDialogPrivate* dialog;
}
- (void) finishClicked;
- (void) reportUpdateError:(id)arg;
- (void) reportUpdateProgress:(id)arg;
- (void) reportUpdateFinished:(id)arg;
@end

class UpdateDialogPrivate
{
	public:
		UpdateDialogDelegate* delegate;
		NSAutoreleasePool* pool;
		NSWindow* window;
		NSButton* finishButton;
		NSTextField* progressLabel;
		NSProgressIndicator* progressBar;
};

@implementation UpdateDialogDelegate
- (void) finishClicked
{
	[NSApp stop:self];
}
- (void) reportUpdateError: (id)arg
{
	NSMutableString* message;
	[message appendString:@"There was a problem installing the update: "];
	[message appendString:arg];
	[dialog->progressLabel setTitleWithMnemonic: message];
}
- (void) reportUpdateProgress: (id)arg
{
	int percentage = [arg intValue];
	[dialog->progressBar setDoubleValue:(percentage/100.0)];
}
- (void) reportUpdateFinished: (id)arg
{
	[dialog->progressLabel setTitleWithMnemonic:@"Updates installed.  Click 'Finish' to restart the application."];
}
@end

UpdateDialogCocoa::UpdateDialogCocoa()
: d(new UpdateDialogPrivate)
{
	[NSApplication sharedApplication];
	d->pool = [[NSAutoreleasePool alloc] init];
}

UpdateDialogCocoa::~UpdateDialogCocoa()
{
	[d->pool release];
}

void UpdateDialogCocoa::init()
{
	d->delegate = [[UpdateDialogDelegate alloc] init];
	d->delegate->dialog = d;

	int width = 370;
	int height = 100;

	d->window = [[NSWindow alloc] initWithContentRect:NSMakeRect(200, 200, width, height)
	        styleMask:NSTitledWindowMask | NSClosableWindowMask |
		              NSMiniaturizableWindowMask
	        backing:NSBackingStoreBuffered defer:NO];
	[d->window setTitle:@"Mendeley Updater"];

	d->finishButton = [[NSButton alloc] init];
	[d->finishButton setTitle:@"Finish"];
	[d->finishButton setButtonType:NSMomentaryLightButton];
	[d->finishButton setBezelStyle:NSRoundedBezelStyle];
	[d->finishButton setTarget:d->delegate];
	[d->finishButton setAction:@selector(finishClicked)];

	d->progressBar = [[NSProgressIndicator alloc] init];
	[d->progressBar setIndeterminate:false];
	[d->progressBar setMinValue:0.0];
	[d->progressBar setMaxValue:1.0];

	d->progressLabel = [[NSTextField alloc] init];
	[d->progressLabel setEditable:false];
	[d->progressLabel setSelectable:false];
	[d->progressLabel setTitleWithMnemonic:@"Installing Updates"];
	[d->progressLabel setBezeled:false];
	[d->progressLabel setDrawsBackground:false];

	NSView* windowContent = [d->window contentView];
	[windowContent addSubview:d->progressLabel];
	[windowContent addSubview:d->progressBar];
	[windowContent addSubview:d->finishButton];

	[d->progressLabel setFrame:NSMakeRect(10,70,width - 10,20)];
	[d->progressBar setFrame:NSMakeRect(10,40,width - 20,20)];
	[d->finishButton setFrame:NSMakeRect(width - 85,5,80,30)];
}

void UpdateDialogCocoa::exec()
{
	[d->window makeKeyAndOrderFront:d->window];
	[d->window center];
	[NSApp run];
}

void UpdateDialogCocoa::updateError(const std::string& errorMessage)
{
	[d->delegate performSelectorOnMainThread:@selector(reportUpdateError:)
	             withObject:[NSString stringWithUTF8String:errorMessage.c_str()]
	             waitUntilDone:false];
}

bool UpdateDialogCocoa::updateRetryCancel(const std::string& message)
{
	// TODO
}

void UpdateDialogCocoa::updateProgress(int percentage)
{
	[d->delegate performSelectorOnMainThread:@selector(reportUpdateProgress:)
	             withObject:[NSNumber numberWithInt:percentage]
	             waitUntilDone:false];
}

void UpdateDialogCocoa::updateFinished()
{
	[d->delegate performSelectorOnMainThread:@selector(reportUpdateFinished:)
	             withObject:nil
	             waitUntilDone:false];
}

