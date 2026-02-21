//
//  CodePatch.h
//  DobbyTest111
//
//  Created by macgu on 2020/11/15.
//  Copyright © 2020年 macgu. All rights reserved.
//

#ifndef CodePatch_h
#define CodePatch_h
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <sys/mman.h>
extern "C" kern_return_t
mach_vm_read(
             vm_map_t               map,
             mach_vm_address_t      addr,
             mach_vm_size_t         size,
             pointer_t              *data,
             mach_msg_type_number_t *data_size);

extern "C" kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);

extern "C" kern_return_t
mach_vm_write(
              vm_map_t                          map,
              mach_vm_address_t                 address,
              pointer_t                         data,
              __unused mach_msg_type_number_t   size);

extern "C" kern_return_t
mach_vm_region(
               vm_map_t                 map,
               mach_vm_offset_t         *address,       /* IN/OUT */
               mach_vm_size_t           *size,          /* OUT */
               vm_region_flavor_t       flavor,         /* IN */
               vm_region_info_t         info,           /* OUT */
               mach_msg_type_number_t   *count,         /* IN/OUT */
               mach_port_t              *object_name);  /* OUT */

extern "C" kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern "C" kern_return_t
mach_vm_protect(
                vm_map_t            map,
                mach_vm_offset_t    start,
                mach_vm_size_t      size,
                boolean_t           set_maximum,
                vm_prot_t           new_protection);

extern "C" kern_return_t
mach_vm_remap(vm_map_t target_task, mach_vm_address_t *target_address, mach_vm_size_t size, mach_vm_offset_t mask,
              int flags, vm_map_t src_task, mach_vm_address_t src_address, boolean_t copy,
              vm_prot_t *curr_protection, vm_prot_t *max_protection, vm_inherit_t inheritance);
class HookInstance
{
public:
    void *address;
    void *bytes;
    size_t len;
    HookInstance(void *address1,size_t len1){
        this->address = address1;
        this->bytes = malloc(len1);
        memcpy(this->bytes,address1,len1);
        this->len = len1;
    }
    ~HookInstance(){
        free(this->bytes);
    }
};

#endif /* CodePatch_h */
