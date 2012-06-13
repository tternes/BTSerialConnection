//
//  BTSerialDemo.m
//  BTSerialDemo
//
//  Created by Thaddeus Ternes on 6/12/12.
//  Copyright (c) 2012 Bluetoo Ventures. All rights reserved.
//

#import "BTSerialDemo.h"

@implementation BTSerialDemo

- (void)startDemo
{
    // Instantiate and specify ourselves as the delegate
    serial = [[BTSerialConnection alloc] init];
    [serial setDelegate:self];
    
    // Set the connection details
    [serial setPort:@"/dev/tty.PL2303-000012FA"];
    [serial setBaud:9600];

    // Messages from the connected device end in newline
    [serial setMessageTerminator:@"\n"];
    
    // Open the connection; the connected device emits messages immediately
    [serial openConnection];
    
    // Close the connection after 10 seconds (though the runloop will continue indefinitely)
    [self performSelector:@selector(stopDemo) withObject:nil afterDelay:10.0];
}

- (void)stopDemo
{
    NSLog(@"Closing connection...");
    [serial closeConnection];
    [serial release];
    serial = nil;
}

- (void)connectionOpened:(BTSerialConnection *)connection
{
    NSLog(@"Connection Opened: %@", [connection port]);
}

- (void)connectionClosed:(BTSerialConnection *)connection
{
    NSLog(@"Connection Closed: %@", [connection port]);    
}

- (void)connection:(BTSerialConnection *)connection didReceiveTerminatedMessage:(NSString *)message
{
    NSLog(@"Connection message received: %@", message);
}

@end
