//
//  huizhi.m
//  libCHETOCOD
//
//  Created by mac on 2022/6/4.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/AdSupport.h>
#import <AVKit/AVKit.h>
#include <JRMemory/MemScan.h>
#import "huizhi.h"
@implementation huizhi
static huizhi *extraInfo;
static void __attribute__((constructor)) entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo =  [huizhi new];
        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
        AddrRange range = (AddrRange){0x100000000,0x160000000};
        uint32_t search = 135682;
        engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
        vector<void*>results = engine.getAllResults();
        uint32_t modify = 67109633;
        for(int i =0; i < results.size();i++){
            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_UInt);
        }
    });
    
    dispatch_async(queue, ^{
        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
        AddrRange range = (AddrRange){0x100000000,0x160000000};
        uint32_t search = 131331;
        engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
        vector<void*>results = engine.getAllResults();
        uint32_t modify = 67109633;
        for(int i =0; i < results.size();i++){
            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_UInt);
        }
    });
    
    dispatch_async(queue, ^{
        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
        AddrRange range = (AddrRange){0x100000000,0x160000000};
        uint32_t search = 70658;
        engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
        vector<void*>results = engine.getAllResults();
        uint32_t modify = 67109633;
        for(int i =0; i < results.size();i++){
            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_UInt);
        }
    });
    
    dispatch_async(queue, ^{
        JRMemoryEngine engine = JRMemoryEngine(mach_task_self());
        AddrRange range = (AddrRange){0x100000000,0x160000000};
        uint32_t search = 262403;
        engine.JRScanMemory(range, &search, JR_Search_Type_SInt);
        vector<void*>results = engine.getAllResults();
        uint32_t modify = 67109633;
        for(int i =0; i < results.size();i++){
            engine.JRWriteMemory((unsigned long long)(results[i]),&modify,JR_Search_Type_UInt);
        }
    });
    });
}
@end
