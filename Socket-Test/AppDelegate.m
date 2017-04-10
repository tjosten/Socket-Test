//
//  AppDelegate.m
//  Socket-Test
//
//  Created by Timo Josten on 10.04.17.
//  Copyright © 2017 Timo Josten. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreFoundation/CoreFoundation.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // hostname resolution
    NSString *hostname = @"mkswap.net";
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
    CFStreamError error;
    NSArray *addresses = nil;
    
    CFHostStartInfoResolution(host, kCFHostAddresses, &error);
    addresses = (__bridge NSArray *)(CFHostGetAddressing(host, NULL));
    CFRelease(host);
    
    // ip address assignment
    SInt32 addressFamily = AF_INET;
    struct sockaddr_in address4;
    
    [addresses[0] getBytes:&address4 length:sizeof(address4)];
    address4.sin_port = htons(22);
    
    struct sockaddr_storage *address = (struct sockaddr_storage *)(&address4);
    
    // creating socket
    CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, addressFamily, SOCK_STREAM, IPPROTO_IP, kCFSocketNoCallBack, NULL, NULL);
    int set = 1;
    setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(set));
    
    // connecting socket
    CFSocketError socketError = 1;
    socketError = CFSocketConnectToAddress(socket, (__bridge CFDataRef)[NSData dataWithBytes:address length:address->ss_len], 10.0);

    if (socketError) {
        NSLog(@"Error: %li", socketError);
    } else {
        NSLog(@"Successfully connected to address");
    }
    
    CFSocketInvalidate(socket);
    CFRelease(socket);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
