//
//  njectionsystemfunction.m
//  wzss
//
//  Created by Ng on 2022/6/2.
//

#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import "fishhook.h"
@interface njectionsystemfunction : NSObject
@end
@implementation njectionsystemfunction : NSObject
int (*old_get_Get)(void);

static int Hook_get_Get()
{
    return 0;
}
static void __attribute__((constructor)) hook() {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               unsigned long Get =_dyld_get_image_vmaddr_slide(0) + 0x106840450;
               DobbyHook((void *)Get, (void*)&Hook_get_Get,(void*)&old_get_Get);
        unsigned long Get1 =_dyld_get_image_vmaddr_slide(0) + 0x106772A9C;
        DobbyHook((void *)Get1, (void*)&Hook_get_Get,(void*)&old_get_Get);
        unsigned long Get2 =_dyld_get_image_vmaddr_slide(0) + 0x1067729EC;
        DobbyHook((void *)Get2, (void*)&Hook_get_Get,(void*)&old_get_Get);
        unsigned long Get3 =_dyld_get_image_vmaddr_slide(0) + 0x1068A3ED8;
        DobbyHook((void *)Get3, (void*)&Hook_get_Get,(void*)&old_get_Get);
    });
}

@end
