//==============================================================================
/**
@file       MyStreamDeckPlugin.m

@brief      A Stream Deck plugin displaying the number of unread emails in Apple's Mail

@copyright  (c) 2018, Corsair Memory, Inc.
			This source code is licensed under the MIT-style license found in the LICENSE file.

**/
//==============================================================================

#import "MyStreamDeckPlugin.h"

#import "ESDSDKDefines.h"
#import "ESDConnectionManager.h"
#import "ESDUtilities.h"
#import <AppKit/AppKit.h>


// Check for Coda current edited file extention timer in second
#define REFRESH_UNREAD_COUNT_TIME_INTERVAL 1.0

// Name of streamdeck device to switch profil on
#define DEVICE_TARGET_NAME "BIG SD"




// Utility function to get the fullpath of an resource in the bundle
//
static NSString * GetResourcePath(NSString *inFilename)
{
	NSString *outPath = nil;
	
	if([inFilename length] > 0)
	{
		NSString * bundlePath = [ESDUtilities pluginPath];
		if(bundlePath != nil)
		{
			outPath = [bundlePath stringByAppendingPathComponent:inFilename];
		}
	}
	
	return outPath;
}


// MARK: - MyStreamDeckPlugin

@interface MyStreamDeckPlugin ()

// tell us if Coda 2 is running
@property (assign) BOOL isCode2Running ;

// id of targeted StreamDeck device
//@property (strong) NSString *deviceTargetName;

// id of targeted StreamDeck device
@property (strong) NSString *deviceTargetId;

// A timer fired each minute to update the number of unread email from Apple's Mail
@property (strong) NSTimer *refreshTimer;

// The list of visible contexts
@property (strong) NSMutableArray *knownContexts;

@end


@implementation MyStreamDeckPlugin



// MARK: - Setup the instance variables if needed

- (void)setupIfNeeded
{
	// Create the array of known contexts
	if(_knownContexts == nil)
	{
		_knownContexts = [[NSMutableArray alloc] init];
	}
	
	// Create a timer to repetivily update the actions
	if(_refreshTimer == nil)
	{
		_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_UNREAD_COUNT_TIME_INTERVAL target:self selector:@selector(SwithProfileFromExtension) userInfo:nil repeats:YES];
	}
    
//    if( self.deviceTargetName == nil ){
//         self.deviceTargetName = [NSString stringWithContentsOfFile:GetResourcePath(@"device.txt") encoding:NSUTF8StringEncoding error:nil];
//    }
    
    
    
}


// MARK: - Refresh all actions

- (void)SwithProfileFromExtension
{
	if(!self.isCode2Running)
	{
		return;
	}
	
	// Execute the getCodaExtension.scpt Applescript tp retrieve the extenstion of current opened file in Coda
	NSString *codaExtension ;
	NSURL* url = [NSURL fileURLWithPath:GetResourcePath(@"getCodaExtension.scpt")];
	
	NSDictionary *errors = nil;
	NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
	if(appleScript != nil)
	{
		NSAppleEventDescriptor *eventDescriptor = [appleScript executeAndReturnError:&errors];
		if(eventDescriptor != nil && [eventDescriptor descriptorType] != kAENullEvent)
		{
            codaExtension = [eventDescriptor stringValue];
		}
	}
 
    
    
    NSString *targetProfil ;
    
    if([codaExtension isEqualToString:@"not in front"]) {
        targetProfil = @"";
    }else if([codaExtension isEqualToString:@"php"])
    {
        targetProfil = @"Coda PHP";
    }else if([codaExtension isEqualToString:@"html"])
    {
        targetProfil = @"Coda HTML";
    }else if([codaExtension isEqualToString:@"js"])
    {
        targetProfil = @"Coda JS";
    }else if([codaExtension isEqualToString:@"css"])
    {
        targetProfil = @"Coda CSS";
    }else if([codaExtension isEqualToString:@"less"])
    {
        targetProfil = @"Coda CSS";
    }else{
        targetProfil = @"";
    }

    [self.connectionManager switchToProfile:targetProfil deviceId:self.deviceTargetId];
}








// MARK: - Events handler


- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    // Nothing to do
}

- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	// Nothing to do
}

- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	// Set up the instance variables if needed
	[self setupIfNeeded];
	
	// Add the context to the list of known contexts
	[self.knownContexts addObject:context];
    
    [self SwithProfileFromExtension];
}

- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	// Remove the context from the list of known contexts
	[self.knownContexts removeObject:context];
}

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo
{
    // get opaque device ID of the targeted Device to use with switchProfile
    if ([deviceInfo[@kESDSDKDeviceInfoName] isEqualToString:@DEVICE_TARGET_NAME] )
    {
        self.deviceTargetId = deviceID ;
    }
}

- (void)deviceDidDisconnect:(NSString *)deviceID
{
	// Nothing to do
}


- (void)applicationDidLaunch:(NSDictionary *)applicationInfo
{
    if([applicationInfo[@kESDSDKPayloadApplication] isEqualToString:@"com.panic.Coda2"])
    {
        self.isCode2Running = YES;

        [self setupIfNeeded];
        [self SwithProfileFromExtension];
    }
}



- (void)applicationDidTerminate:(NSDictionary *)applicationInfo
{
    if([applicationInfo[@kESDSDKPayloadApplication] isEqualToString:@"com.panic.Coda2"])
    {
        self.isCode2Running = NO;
    }
}

@end
