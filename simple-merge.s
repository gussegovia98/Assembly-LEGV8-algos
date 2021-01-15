//Gustavo Segovia 
// Section: 16685
// HW #4
//This is the code stub for merge sort. Refer to the C or Java code for reference.
//Currently it is expected to only merge two sorted half arrays into one full array.

.section .rodata //read only data

    descending_print:      .asciz  "The descending list order is...\n\n"
    enter_size:            .asciz  "Enter the list size [0 to 1000]:  "
    enter_number:          .asciz  "Enter #%4lld:  "
 
    // note:  lld specifies a long long int
    //        a lld always takes up 64 bits
    //        making our data entry/usage a little simpler

    llint_specifier_scan:  .asciz   "%lld"
    llint_specifier_print: .asciz  "%lld "    
    newline:               .asciz     "\n"


.global main

.text

main:
    //2 arrays of max size 1000 and one size variable
    //[sp+8, sp+16) => size
    //[sp+16, sp+8016) => helper
    //[sp+8016, sp+16016) => arr
    mov x0, #8000 // temp because 8000 doesn't fit in immediate field of sub instruction (range is 0 to 4095)
    sub sp, sp, x0
    mov x19, sp //x19 is head of array (using lowest address in the array as base)
    sub sp, sp, x0
    mov x20, sp //x20 is head of helper
    sub sp, sp, #16 //we need 8 bytes for size variable, extra 8 bytes is wasted to 16byte align sp.
    add x21, sp, #8 // x21 is size variable address

    ldr x0, =newline
    bl printf

    ldr x0, =enter_size
    bl printf

    ldr x0, =llint_specifier_scan
    mov x1, x21
    bl scanf

    ldr x0, =newline
    bl printf

    mov x22, 0 //loop i
    ldr x23, [x21]//sp is where size variable is (x23 is value of size now)
.scaninput_for:
    cmp x22, x23
    b.ge .scaninput_for_exit

    ldr x0, =enter_number
    mov x1, x22
    bl printf

    ldr x0, =llint_specifier_scan
    lsl x1, x22, 3 // x22 is i, offset is scaled by 8
    add x1, x19, x1 //current value of offset and add it to base address
    bl scanf

    add x22, x22, 1
    b .scaninput_for
.scaninput_for_exit:

    ldr x0, =newline
    bl printf

    mov x0, x19 //arr
    mov x1, x20 //helper
    mov x2, 0   //begin
    lsr x3, x23, 1 //shifting right the size equivalent of division by 2  (so that x3 is mid)
    mov x4, x23 //end (equal to size which is one after the index of last element)
    bl merge


    ldr x0, =descending_print
    bl printf

    mov x0, x20 //base
    mov x1, x23 //size
    bl print_array

    mov x0, #16016
    
    add sp, sp, x0

    mov x0, #0
    mov x8, #93 //93 is exit syscall
    svc #0

//DONT CHANGE ABOVE THIS POINT
//TODO: IMPLEMENT MERGE FUNCTION
merge:
    //x0 is array 0 
    //x1 helper0
    //x2 i in #
    //x3 is size/2
    //x4 is size(end)

    //TODO: back up x24 x25 on stack!

    mov x9, x2 // i = begin
    mov x10, x3 // j = mid assuming x3 is actually mid
    mov x11, x9 // current = begin

    loop:
        lsl X17, X11, #3 //shifting array 
        add X24, x1, X17 //moving to correct position for array
        //x24 is array[x24] for a[current]

        //sub x12, x4, x11 //end - current 
        cmp x4, x11
        b.eq ret
        //cbz X12, ret //end - current == 0
        if:
            cmp x9, x3
            b.lt elseif        
            
            //lsl X14, X10, #3 //shifting array 
            //add X15, x0, X14 //moving to correct position for array
            //x15 is array[x15] for a[j]

            ldr x25, [x0, x10, lsl 3]

            //mov x17, x30
            //mov x16, x1
            //ldur x1, [x15, #0]
            //ldr x0, = print_num
            //bl printf
            //ldr x0, =newline
            //bl printf
            //mov x30,x17
            //mov x1,x16

            stur x25, [x24, #0] //helper[current] = a[j++]
            
            add x10, x10, #1//j++

            b iterate


        elseif:
            cmp x10 ,x4
            b.lt else1

            lsl X13, X9, #3 //shifting array 
            add X16, x0, X13 //moving to correct position for array 
            //x16 is array[x16] for a[i++]

            ldur x25, [x16, #0]
            stur x25, [x24, #0] //helper[current] = a[i++]
            add x9, x9, #1//i++
            b iterate

        else1:
            lsl X17, X9, #3 //shifting array 
            add X16, x0, X17 //moving to correct position for array //a[i]
            ldur x13, [x16, #0]//getting value for a[i]

            lsl X15, X10, #3 //shifting array 
            add X12, x0, X15 //moving to correct position for array //a[j]
            ldur x14, [x12, #0] //getting value for a[j]

            cmp x13, x14//changed
            b.lt else2
            
            lsl X13, X9, #3 //shifting array 
            add X16, x0, X13 //moving to correct position for array 
            //x16 is array[x16] for a[i++]

            ldur x25, [x16, #0]
            stur x25, [x24, #0] //helper[current] = a[i++]
            add x9, x9, #1//i++

            b iterate

            else2:
                lsl X14, X10, #3 //shifting array 
                add X15, x0, X14 //moving to correct position for array
                //x15 is arra[x15] for a[j]

                ldur x25, [x15, #0]
                stur x25, [x24, #0] //helper[current] = a[j++]
                add x10, x10, #1//j++
                b iterate
        iterate:
            add x11, x11, #1
            b loop

    /* copy:
    # mov x9, x2//x9 is begin /i
    # mov x10, x4 //x10 is end
    # sub x11, x10, x9
    # cbz x11, ret

    # lsl X11, X9, #3 //shifting array 
    # add X17, x0, X11//moving to correct position for array
    # add x16, x1, x11 //moving to correct position for helper

    # ldur x15, [x16, #0] //load the value at helper[i]
    # stur x15, [x17, #0] //store value at a[i]

    # b copy */
    ret:
    br x30  // remove or modify 'ret' as needed


//DONT CHANGE BEYOND THIS POINT
print_array:
    stp x19, x20, [sp, -16]!
    stp x21, x30, [sp, -16]!

    mov x19, x0
    mov x20, x1
    mov x21, #0 // x21 is i
.for1:
    cmp x21, x20
    b.ge .for1_exit

    ldr x1, [x19, x21, lsl #3]
    ldr x0, =llint_specifier_print
    bl printf

    add x21, x21, #1
    b .for1

.for1_exit:
    ldr x0, =newline
    bl printf

    //ldr x30, [sp], #16
    //shorthand (post-indexing) for following two instructions:
    ldp x21, x30, [sp], 16
    ldp x19, x20, [sp], 16

    ret
    //equivalent of br x30, but hints that it is returning from a procedure.
