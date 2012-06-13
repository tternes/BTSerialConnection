//
//  main.m
//  BTSerialDemo
//
//  Created by Thaddeus Ternes on 6/12/12.
//  Copyright (c) 2012 Bluetoo Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSerialDemo.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        BTSerialDemo *demo = [[BTSerialDemo alloc] init];
        [demo startDemo];
        
        CFRunLoopRun();
        
        [demo release];
        demo = nil;
        
    }
    return 0;
}

