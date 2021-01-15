// selection_sort.s
//   
// Gustavo Segovia 
// Section: 16685
// HW #3
// The spec said descending order, but the given string says ascending order. If you wanted it the other way, all I have to do is switch X13 and X14 on line 137.
.data
    you_entered:     .asciz "You entered this list:  "
    ascending_sort:  .asciz "The ascending sorted list:  "
    newline:         .asciz "\n"
    request_number:  .asciz "Enter Integer #%d:  "
    print_int:       .asciz "%d "
    int_specifier:   .asciz "%d"
    int_buffer:      .space 4

.global main
.text

main:
    // scan 10 values from user
    MOV X19, #10         // length
    MOV X20, #0          // counter

    // Update SP to store 10 new values
    ADD X21, SP, #0      // save base address of 10 values
    SUB SP, SP, #80      // open up space

init_loop:

  
    SUBS X15, X20, X19
    B.GE init_complete

    // Request number
    // Load request string into X0
    LDR X0, =request_number
    ADD X1, X20, #1
    BL printf

    // Load requested type into X0
    // Load destination buffer into X1 
    LDR X0, =int_specifier
    LDR X1, =int_buffer
    BL scanf

    LDR X10, =int_buffer
    LDR X11, [X10, #0]

    // take the value the user entered and put it into the next 
    // position for the stored values (stack moves down, so SUB)
    // base - offset (counter) -> X21 - X13
    LSL X13, X20, 3
    SUB X12, X21, X13
    STR X11, [X12, #0]

    ADD X20, X20, #1

    B init_loop
init_complete:
    LDR X0, = you_entered
    BL printf
    LDR X0, =newline
    BL printf
    
    // setup parameters to pass
    // call print_array
    MOV X0, X21         // pass base address
    MOV X1, X19         // pass length
    MOV X25, X1 
    MOV X24, XZR        //i
    BL print_array

    done:
        CBNZ X27, reallydone

    // setup parameters to pass
    // call selection_sort
    MOV X0, X21 //array
    MOV X25, X19 //length
    MOV X24, XZR //i
    MOV X28, XZR //j
    BL selection_sort

    exitOuter:
    MOV X27, #1

    LDR X0, =ascending_sort
    BL printf
    LDR X0, =newline
    BL printf

    // setup parameters to pass
    // call print_array
    MOV X0, X21         // pass base address
    MOV X1, X19         // pass length
    MOV X25, X1 
    MOV X24, XZR        //i
    BL print_array

    reallydone:

    B exit
        
selection_sort:
    MOV X22, X25                //X22 is now length
    SUB X25, X22, #1//n=n-1     //X25 is now length -1
    forOuter:
        SUB X10, X25, X24//n-1-i
        CBZ X10, exitOuter //n-1-i>=0
        
        LSL X11, X24, 3 //shifting array 
        SUB X18, X21, X11// moving to correct poisition
        //LDUR X23, [X18, #0]
    
        MOV X26, X18 // min index = i shifted

        ADD X28, X24, #1 

        BL find_minimum
        found://return flag
        BL swap
        finishedswapping:
        ADD X24, X24, #1//i++

        B forOuter

find_minimum:
    SUB X3, X22, X28 // n-j
    CBZ X3, found // once its done get out

    LSL X12, X28, #3    //shift j by 3
    SUB X17, X21, X12// moving to correct poisition j

    LDUR X13, [X26, #0]//array[min_index]
    LDUR X14, [X17, #0]//array[j]

    SUBS X15, X14, X13 // array[j] - array[min_index] 
    B.LT updateMinCase

    updated:

    ADD X28, X28, #1 // j++
    //LSL X26, X26, #3
    B find_minimum

print_array:
    //X25 is length 
    //X24 is i 
    //X9 =length-i
    //X11 is current array position 
    //X21 is array head
    SUB X9, X25, X24 // checking condition
    CBZ X9, done //
    LSL X12, X24, 3 //shifting array 
    SUB X18, X21, X12// moving to correct poisition
    LDUR X11,[X18, #0]//load array index value
    MOV X1, X11
    LDR X0, = int_specifier//printing array[i]
    BL printf
    LDR X0, = newline
    BL printf
    ADD X24,X24, #1 //i++
    B print_array//go to next iterator 

updateMinCase:
    MOV X26, X17
    //MOV X13, X14
    B updated

swap:
    LSL X11, X24, 3 //shifting array 
    SUB X18, X21, X11// moving to correct poisition
    LDUR X23, [X18, #0]
    LDUR X16, [X26, #0]
    STUR X23, [X26, #0]
    STUR X16, [X18, #0]
    B finishedswapping

return:
    BR X30
    
exit:
    MOV X0, #0
    MOV X8, #93
    SVC #0
