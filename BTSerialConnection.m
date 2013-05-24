//
//  BTSerialConnection.m
//  BTSerialConnection
//
//  Created by Thaddeus Ternes on 6/11/12.
//  Copyright (c) 2012 Bluetoo Ventures. All rights reserved.
//

#import "BTSerialConnection.h"
#include <sys/ioctl.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/serial/ioss.h>

#define kSerialConfigError (-1)

@implementation BTSerialConnection

@synthesize delegate;
@synthesize port;
@synthesize baud;
@synthesize messageTerminator;

- (id)init
{
    self = [super init];
    if(self)
    {
        _collectedData = [[NSMutableData alloc] init];

    }
    
    return self;
}

- (BOOL)openConnection
{
    int fd = open([port UTF8String], O_RDWR | O_NOCTTY | O_NONBLOCK);
    if(fd == -1)
    {
        NSLog(@"Failed to open port %@", port);
        return NO;
    }

    // prevent multiple open() calls
    if (ioctl(fd, TIOCEXCL) == kSerialConfigError)
    {
        NSLog(@"Error setting TIOCEXCL on %@ - %s(%d).\n", port, strerror(errno), errno);
        goto error;
    }
    
    // Clear the O_NONBLOCK flag
    if (fcntl(fd, F_SETFL, 0) == kSerialConfigError)
    {
        NSLog(@"Error clearing O_NONBLOCK %@ - %s(%d).\n", port, strerror(errno), errno);
        goto error;
    }
    
    struct termios options;
    tcgetattr(fd, &options);
    
    // Set the specified baud rate
    speed_t rate = B9600;
    switch(self.baud)
    {
        case 115200:
            rate = B115200;
            break;
            
        case 57600:
            rate = B57600;
            break;
            
        case 38400:
            rate = B38400;
            break;
            
        case 19200:
            rate = B19200;
            break;
            
        case 9600:
        default:
            rate = B9600;
            break;
    }
    
    cfsetspeed(&options, rate);
    options.c_cflag |= (CLOCAL | CREAD);
    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8;
    
    // Cause the new options to take effect immediately.
    if (tcsetattr(fd, TCSANOW, &options) == kSerialConfigError)
    {
        NSLog(@"Error setting tty attributes %@ - %s(%d).\n", port, strerror(errno), errno);
        goto error;
    }
    
    if([delegate respondsToSelector:@selector(connectionOpened:)])
        [delegate performSelector:@selector(connectionOpened:) withObject:self];

    _fdHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    
    [_fdHandle synchronizeFile];
    [_fdHandle seekToEndOfFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:NSFileHandleReadCompletionNotification object:_fdHandle];

    [_fdHandle readInBackgroundAndNotify];
    
    return YES;
    
error:
    close(fd);
    return NO;
}

- (BOOL)closeConnection
{
    if(_fdHandle)
    {
        tcdrain([_fdHandle fileDescriptor]);
        [_fdHandle closeFile];
        [_fdHandle release];
        _fdHandle = nil;
        
        if([delegate respondsToSelector:@selector(connectionClosed:)])
            [delegate performSelector:@selector(connectionClosed:) withObject:self];

        return YES;
    }
    
    return NO;
}

- (BOOL)writeData:(NSData *)data
{
    if([_fdHandle fileDescriptor])
    {
        @try
        {
            [_fdHandle writeData:data];
            return YES;
        }
        @catch (NSException *ex)
        {
            NSLog(@"Exception, closing connection; caught while writing data: %@", ex);
            [self closeConnection];
            return NO;
        }
    }

    return NO;
}

- (BOOL)writeMessage:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSASCIIStringEncoding];
    return [self writeData:data];
}

#pragma mark -
#pragma mark Data Notification

- (void)didReceiveData:(NSNotification *)notification
{
    if(![_fdHandle fileDescriptor])
    {
        return;
    }
    
    NSData* messageData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (messageData == nil || [messageData length] == 0 ) 
    {
        // TODO: happens when the connection is removed (usb unplugged).
        // Need to determine if this is legitimate action, instead of reattempting
        // [_fdHandle performSelector:@selector(readInBackgroundAndNotify) withObject:nil afterDelay:0.1];
        [self closeConnection];
        return;
    }

    if([delegate respondsToSelector:@selector(connection:didReceiveData:)])
        [delegate performSelector:@selector(connection:didReceiveData:) withObject:self withObject:messageData];
    
    if([delegate respondsToSelector:@selector(connection:didReceiveMessage:)])
    {
        NSString* receivedMessage = [[[NSString alloc] initWithData:messageData encoding:NSASCIIStringEncoding] autorelease];
        [delegate performSelector:@selector(connection:didReceiveMessage:) withObject:self withObject:receivedMessage];
    }
    
    if(self.messageTerminator && [delegate respondsToSelector:@selector(connection:didReceiveTerminatedMessage:)])
    {
        [_collectedData appendData:messageData];

        NSString *message = [[[NSString alloc] initWithData:_collectedData encoding:NSASCIIStringEncoding] autorelease];
        if(message && [message rangeOfString:self.messageTerminator].location != NSNotFound)
        {
            [delegate performSelector:@selector(connection:didReceiveTerminatedMessage:) withObject:self withObject:message];
            [_collectedData setData:nil];
        }
    }

    [_fdHandle readInBackgroundAndNotify];
}

@end
