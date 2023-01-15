# Operating Systems Sessional

This repository contains all the practice problems and assignments that I have worked on for the course CSE314 - Operating Systems - Sessional offered in CSE-BUET. 

The main codebase for the changes we have done in xv6-riscv throughout the semester can be found [here](https://github.com/fardinanam/xv6-riscv).

Here are some guidelines to make changes to the xv6-riscv repository.

---

## Working with xv6

## Installing xv6 on linux machine

1. Install `make`
    ```bash
        sudo apt install make
    ```
2. 

### Creating a new system call program

1. Create a new file <new_system_call_name> in `user/` directory.
    
    The new file should contain the following:
    ```c
        #include "kernel/param.h"
        #include "kernel/types.h"
        #include "kernel/stat.h"
        #include "user/user.h"
        
        int main(int argc, char *argv[]) {
            // code
            exit(exit_status);
        }
    ```
    **For example, see the `user/trace.c` file**

    `Note:` The file name should be as same as the command name that you want to use to execute the system call.

4. Add the new system call command name to `user/Makefile` as follows:
    ```makefile
        UPROGS = \
            ...
            $U/_<new_command_name>\
            ...
    ``` 
    **eg: `$U/_trace \`**
    
    This will allow the `make qemu` to enable the system call.

    `Note:` The <new_command_name> part should be the same as the file name created in step 1.

3. Add an entry to `user/usys.pl`.

    ```c
        entry("<new_system_call_name>");
    ```

    **eg: `entry("trace");`**
    
    This will route the system call into the kernel.

    `Note:` The <new_system_call_name> part does not have to be the same as the file name created in step 1. But all the names stated in the following steps should be the same as this one.

4. Add the prototype of the new system call in `user/user.h`.

    **eg: `int trace(int);`**

5. Define a system call number in `kernel/syscall.h` as follows:
    ```c
        #define SYS_<new_system_call_name> <new_system_call_number>
    ```
    **eg: `#define SYS_trace 22`**

6. Define the system call function in `kernel/proc.c`
    ```c
        <return type>
        <new_system_call_name>(<args>) {
            // code
        }
    ```
    **eg: see the `trace()` function in `kernel/proc.c`** 

7. Open `kernel/sysproc.c` and add the handler function that will execute the system call which has just been defined in step 6.
    ```c
        <return type>
        sys_<new_system_call_name>(void) {
            // code
        }
    ```
    **eg: see the `sys_trace()` function in `kernel/sysproc.c`**
8. In `kernel/syscall.c`,
    - extern the new system call handler function.

        ```c
            extern int sys_<new_system_call_name>(void);
        ```

        **eg: `extern int sys_trace(void);`**

    - Add the new system call name to the `syscalls` array.
    
        ```c
            [SYS_<new_system_call_name>] sys_<new_system_call_name>,
        ```

        **eg: `[SYS_trace] sys_trace,`**

9. Make required changes in other functions and files as required.