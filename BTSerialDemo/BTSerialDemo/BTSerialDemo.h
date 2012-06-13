//
//  BTSerialDemo.h
//  BTSerialDemo
//
//  Created by Thaddeus Ternes on 6/12/12.
//  Copyright (c) 2012 Bluetoo Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSerialConnection.h"

@interface BTSerialDemo : NSObject<BTSerialConnectionDelegate>
{
    BTSerialConnection *serial;
}


- (void)startDemo;
- (void)stopDemo;

@end
