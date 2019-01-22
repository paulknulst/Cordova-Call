#import "AppDelegate.h"
#import "Intents/Intents.h"
#import <CallKit/CallKit.h>
#import <objc/runtime.h>

@implementation AppDelegate (CordovaCall)

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	BOOL isBackground = application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.nfon.applicationstate.isBackground" object:[NSNumber numberWithBool:isBackground]];
	
	return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
{
    INInteraction *interaction = userActivity.interaction;
    INIntent *intent = interaction.intent;
    BOOL isVideo = [intent isKindOfClass:[INStartVideoCallIntent class]];
    INPerson *contact;
    if(isVideo) {
        INStartVideoCallIntent *startCallIntent = (INStartVideoCallIntent *)intent;
        contact = startCallIntent.contacts.firstObject;
    } else {
        INStartAudioCallIntent *startCallIntent = (INStartAudioCallIntent *)intent;
        contact = startCallIntent.contacts.firstObject;
    }
    INPersonHandle *personHandle = contact.personHandle;
    NSString *callId = personHandle.value;
    NSString *callName = [[NSUserDefaults standardUserDefaults] stringForKey:callId];
    if(!callName) {
        callName = callId;
    }
    NSDictionary *intentInfo = @{ @"callName" : callName, @"callId" : callId, @"isVideo" : isVideo?@YES:@NO};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RecentsCallNotification" object:intentInfo];
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.nfon.applicationstate.isBackground" object:@NO];
}

- (void) applicationWillResignActive:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.nfon.applicationstate.isBackground" object:@YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.nfon.applicationstate.isBackground" object:@YES];
	
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.nfon.applicationstate.isBackground" object:@NO];
	
}

@end
