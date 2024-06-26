#include "vm_macro.h"

.global switch_to
switch_to: 
    stp x19, x20, [x0, 16 * 0]  // save the callee-saved registers(x19-x28) and the stack pointer of the 
    stp x21, x22, [x0, 16 * 1]  // current thread into the memory pointed to by x0.
    stp x23, x24, [x0, 16 * 2]  
    stp x25, x26, [x0, 16 * 3]
    stp x27, x28, [x0, 16 * 4]
    stp fp, lr, [x0, 16 * 5]
    mov x9, sp
    str x9, [x0, 16 * 6]
                                
    ldp x19, x20, [x1, 16 * 0]  // load the saved values of these registers and the stack pointer from the memory pointed to by x1
    ldp x21, x22, [x1, 16 * 1]
    ldp x23, x24, [x1, 16 * 2]
    ldp x25, x26, [x1, 16 * 3]
    ldp x27, x28, [x1, 16 * 4]
    ldp fp, lr,   [x1, 16 * 5]
    ldp x9, x10,  [x1, 16 * 6]
    mov sp,  x9
    msr tpidr_el1, x1           // TPIDR_EL1: thread pointer/ID register for EL1, which provides a location where software executing at
                                // EL1 can store thread identifying information for OS management purposes.
    dsb ish                     // ensure write has completed
    msr ttbr0_el1, x10          // set pgd
    tlbi vmalle1is              // invalidate all TLB entries
    dsb ish                     // ensure completion of TLB invalidatation
    isb                         // clear pipeline (synchronize context and ensure that no instructions are fetched using the old translation)
  
    ldr x1, =KERNEL_VIRT_BASE
    orr lr, lr, x1
    ret  

.global store_cpu_context
store_cpu_context:
    stp x19, x20, [x0, 16 * 0]  // save the callee-saved registers(x19-x28) and the stack pointer of the 
    stp x21, x22, [x0, 16 * 1]  // current thread into the memory pointed to by x0.
    stp x23, x24, [x0, 16 * 2]  
    stp x25, x26, [x0, 16 * 3]
    stp x27, x28, [x0, 16 * 4]
    stp fp, lr, [x0, 16 * 5]
    mov x9, sp
    str x9, [x0, 16 * 6]
    ret

.global load_cpu_context
load_cpu_context:
    ldp x19, x20, [x0, 16 * 0]  
    ldp x21, x22, [x0, 16 * 1]
    ldp x23, x24, [x0, 16 * 2]
    ldp x25, x26, [x0, 16 * 3]
    ldp x27, x28, [x0, 16 * 4]
    ldp fp, lr, [x0, 16 * 5]
    ldr x9, [x0, 16 * 6]
    mov sp,  x9                        
    ret  

.global get_current_thread
get_current_thread:
    mrs x0, tpidr_el1           
    ret

.global set_current_thread
set_current_thread:
    msr tpidr_el1, x0      
    ret

.global set_current_pgd
set_current_pgd:
    dsb ish             // (Data Synchronization Barrier, Inner Shareable domain) ensure write has completed
    msr ttbr0_el1, x0   // set translation base address
    tlbi vmalle1is      // invalidate all TLB entries
    dsb ish             // ensure completion of TLB invalidatation
    isb                 // clear pipeline
    ret