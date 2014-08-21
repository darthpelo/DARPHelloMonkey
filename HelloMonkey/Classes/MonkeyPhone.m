//
//  Copyright 2011 Twilio. All rights reserved.
//
 
#import "MonkeyPhone.h"

#import "TCDevice.h"
#import "TCConnection.h"
#import "TCDeviceDelegate.h"

@interface MonkeyPhone () <TCDeviceDelegate>

@property (nonatomic, strong) TCDevice *device;
@property (nonatomic, strong) TCConnection *connection;

@end

@implementation MonkeyPhone

-(id)init
{
	if ( self = [super init] ){
        [self twilioLogin];
	}
    
	return self;
}

#pragma mark - Public methods

- (void)connect:(NSString *)phoneNumber
{
    NSDictionary* parameters = nil;
    
    if ( [phoneNumber length] > 0 ) {
        parameters = [NSDictionary dictionaryWithObject:phoneNumber forKey:@"PhoneNumber"];
    }
    
    _connection = [self.device connect:parameters delegate:nil];
}

- (void)disconnect
{
    [self.connection disconnect];
    self.connection = nil;
}

#pragma mark - Private methods

- (void)twilioLogin
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue,^{
        // Replace the URL with your Capabilities Token URL
        NSURL* url = [NSURL URLWithString:@"http://localhost/twilio/auth.php"];
        NSURLResponse*  response = nil;
        NSError*  	error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:
                        [NSURLRequest requestWithURL:url]
                                             returningResponse:&response
                                                         error:&error];
        if (data) {
            NSHTTPURLResponse*  httpResponse = (NSHTTPURLResponse*)response;
            
            if (httpResponse.statusCode == 200) {
                NSString* capabilityToken = [[[NSString alloc] initWithData:data
                                                                   encoding:NSUTF8StringEncoding]
                                             autorelease];
                
                _device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken
                                                           delegate:self];
            } else {
                NSString*  errorString = [NSString stringWithFormat:
                                          @"HTTP status code %ld",
                                          (long)httpResponse.statusCode];
                NSLog(@"Error logging in: %@", errorString);
            }
        } else {
            NSLog(@"Error logging in: %@", [error localizedDescription]);
        }
    });
}

#pragma mark TCDeviceDelegate

- (void)device:(TCDevice*)device didReceiveIncomingConnection:(TCConnection*)connection
{
    if (self.connection) {
        [self disconnect];
    }
    self.connection = [connection retain];
    [self.connection accept];
}

- (void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent
{
    
}

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error
{
    if ( !error ) {
        NSLog(@"Device is no longer listening for incoming connections");
    } else {
        NSLog(@"Device no longer listening for incoming connections due to error: %@", [error localizedDescription]);
    }
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice *)device
{
    NSLog(@"Device is now listening for incoming connections");
}

@end
