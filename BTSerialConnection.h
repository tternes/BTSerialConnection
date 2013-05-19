//
//  BTSerialConnection.h
//  BTSerialConnection
//
//  Created by Thaddeus Ternes on 6/11/12.
//  Copyright (c) 2012 Bluetoo Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTSerialConnection;

/**
 Delegate protocol for events sent from BTSerialConnection objects
 */
@protocol BTSerialConnectionDelegate <NSObject>

@optional

/**
 Sent when the serial device is successfully opened
 @param connection The BTSerialConnection instance sending the message.
 */
- (void)connectionOpened:(BTSerialConnection *)connection;

/**
 Sent when the serial device is closed
 @param connection The BTSerialConnection instance sending the message.
 */
- (void)connectionClosed:(BTSerialConnection *)connection;

/**
 Sent when a block of data is received from the connected device
 @param connection The BTSerialConnection instance sending the message.
 @param data NSData object received
 */
- (void)connection:(BTSerialConnection *)connection didReceiveData:(NSData *)data;

/**
 Sent when a block of data is received from the connected device
 @param connection The BTSerialConnection instance sending the message.
 @param message NSString representation of the data received (NSASCIIStringEncoding)
 */
- (void)connection:(BTSerialConnection *)connection didReceiveMessage:(NSString *)message;

/**
 Sent when a full message has been accumulated by the BTSerialConnection's internal data storage.
 This message will only be sent if the BTSerialConnection messageTerminator property has been set.
 @param connection The BTSerialConnection instance sending the message.
 @param message NSString representation of the data received, converted with NSASCIIStringEncoding.
 */
- (void)connection:(BTSerialConnection *)connection didReceiveTerminatedMessage:(NSString *)message;

@end

/**
 BTSerialConnection is simple API for writing and receiving data from serial devices.
 
 Messages are automatically received from the connected device in the background, simplifying
 the asynchronous receive process. Received messages or data is delivered through delegate methods, 
 and can be redirected to the appropriate thread or operation queue as needed by an application.
 
 Messages are received by implementing at least one of the BTSerialConnectionDelegate messages.
*/
@interface BTSerialConnection : NSObject
{
    NSFileHandle *_fdHandle;
    NSMutableData *_collectedData;
    
    id delegate;
    NSInteger baud;
    NSString *messageTerminator;
    NSString *port;
}

/**
 Opens a connection to the configured serial device
 */
- (BOOL)openConnection;

/**
 Closes an existing connection
 */
- (BOOL)closeConnection;

/** Write a block of data to the serial device. 
 @param data rawr
 @returns YES is returned if the data is successfully written to the device, NO if an error occurs
 */
- (BOOL)writeData:(NSData *)data;

/** Write a string to the serial device.
 @param message NSString to be sent to the device. Message will be converted to NSData with NSASCIIStringEncoding.
 */
- (BOOL)writeMessage:(NSString *)message;

@property (nonatomic, retain) id<BTSerialConnectionDelegate> delegate;
@property (nonatomic, retain) NSString *port;
@property (nonatomic, assign) NSInteger baud;
@property (nonatomic, copy) NSString *messageTerminator;

@end


