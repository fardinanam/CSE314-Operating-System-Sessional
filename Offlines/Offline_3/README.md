# Offline-3 (Lottery ticket scheduler)

## Instructions

Clone a fresh copy of [xv6-riscv](https://github.com/mit-pdos/xv6-riscv.git) repository. Make sure that the commit version you are in is ` f5b93ef12f7159f74f80f94729ee4faabe42c360`. Then add the `1805087.patch` file from this repository to the root of the cloned repository. Then run the following commands:

```sh
  git checkout f5b93ef12f7159f74f80f94729ee4faabe42c360
  git apply 1805087.patch
```

Run xv6 using the following command:

```sh
  make qemu
```

You can test the scheduler by running `testticket` and `testprocinfo` in the xv6 shell.

## Problem Statement
The problem statement can be found [here](https://github.com/Tahmid04/xv6-scheduling-july-2022).
## Implementations

### `Lottery Ticket Scheduler`
Selects the a process randomly according to the probability distribution of currently available tickets. If a process is selected, it loses a ticket and its time slice count is increased by 1. If a process has no tickets left, it is not selected again until all tickets are reset.

All tickets are reset only when tickets of all the `RUNNABLE` processes are used up.

```c
  void
  scheduler(void)
  {
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;

    for(;;){
      // Avoid deadlock by ensuring that devices can interrupt.
      intr_on();

      // calculate total tickets
      uint64 tickets_total = ticket_total_count();

      // if all tickets are used, reset all tickets
      if (!tickets_total) 
        tickets_total = reset_tickets();

      // Choose a process to run.
      uint64 draw = rand((uint64)tickets_total);
      // printf("draw: %d\n", draw);
      uint64 ticket_count = 0;
      for(p = proc; p < &proc[NPROC]; p++) {
        acquire(&p->lock);

        if(p->state != RUNNABLE) {
          release(&p->lock);
          continue;
        }

        ticket_count += p->tickets_current;
        if (p->tickets_current == 0 ||
            draw > ticket_count) {
          release(&p->lock);
          continue;
        }


        if(p->state == RUNNABLE) {
          // Decrease ticket count and increase time slice count
          // for the chosen process
          p->tickets_current--;
          p->time_slices++;

          // Switch to chosen process.  It is the process's job
          // to release its lock and then reacquire it
          // before jumping back to us.
          p->state = RUNNING;
          c->proc = p;
          swtch(&c->context, &p->context);

          // Process is done running for now.
          // It should have changed its p->state before coming back.
          c->proc = 0;
          release(&p->lock);
          break;
        }
      }
    }
  }
```

### `settickets`

Following function needs to be added in `kernel/proc.c`:
```c
  // Sets the maximum number of tickets the process can have
  // @param max_tickets the maximum number of tickets the process can have
  // @return 0 on success, -1 on error
  int
  settickets(int tickets_max)
  {
    if(tickets_max < 1)
      return -1;

    struct proc *p = myproc();
  
    acquire(&p->lock);
    p->tickets_max = tickets_max;
    // printf("settickets: pid %d, tickets_max %d\n", p->pid, p->tickets_max);
    release(&p->lock);

    return 0;
  }
```
Following function needs to be added in `kernel/sysproc.c`:
```c
  uint64
  sys_settickets(void)
  {
    int tickets_max;
    argint(0, &tickets_max);
    return settickets(tickets_max);
  }
```

### `getpinfo`
Firstly a new struct named `pstat` is declared. It is better to declare it in a new file `kernel/param.h`: 
```c
  struct pstat {
    int inuse[NPROC]; // whether this slot of the process table is in use (1 or 0)
    int pid[NPROC]; // PID of each process
    int tickets_max[NPROC]; // maximum tickets of each process
    int tickets_current[NPROC]; // current tickets of each process
    int time_slices[NPROC]; // number of time slices each process has run
  };
```
Following function needs to be added in `kernel/proc.c`:
```c
  int
  getpinfo(uint64 addr)
  {
    if (!addr) {
      return -1;
    }

    struct proc *p;
    struct pstat newpst;

    int i = 0;
    for (p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if (p->state == UNUSED) {
        newpst.inuse[i] = 0;
      } else {
        newpst.pid[i] = p->pid;
        newpst.inuse[i] = 1;
        newpst.tickets_max[i] = p->tickets_max;
        newpst.tickets_current[i] = p->tickets_current;
        newpst.time_slices[i] = p->time_slices;
      }

      release(&p->lock);
      i++;
    }

    p = myproc();
    copyout(p->pagetable, addr, (char *)&newpst, sizeof(newpst));

    return 0;
  }
```
Following function needs to be added in `kernel/sysproc.c`:
```c
  uint64
  sys_getpinfo(void) 
  {
    uint64 pst; // user pointer to struct pstat
    argaddr(0, &pst);
    return getpinfo(pst);
  }
```
### `testticket`
Takes one integer argument. Creates a new process with original tickets set to the argument.
```c
  #include "kernel/stat.h"
  #include "kernel/pstat.h"
  #include "user/user.h"

  int main(int argc, char *argv[]) {
    if (argc != 2) {
      fprintf(2, "Usage: %s tickets\n", argv[0]);
      exit(1);
    }

    if (settickets(atoi(argv[1])) < 0) {
      fprintf(2, "%s: failed to set tickets\n", argv[0]);
      exit(1);
    }
    
    int pid = fork();
    if (pid < 0) {
      fprintf(2, "%s: failed to fork\n", argv[0]);
      exit(1);
    } else if (pid == 0) {
      // child process
      printf("Process with pid %d initialized.\n", getpid());
      printf("Original tickets set to %d\n", atoi(argv[1]));
      while (1);
    }

    exit(0);
  }
```
### `testprocinfo`
Prints currently running and runnable process list with their scheduling information.

```c
  #include "kernel/stat.h"
  #include "kernel/pstat.h"
  #include "user/user.h"

  int main(int argc, char *argv[]) {
    struct pstat ps;
    if (argc > 1) {
      fprintf(2, "Usage: getpinfo");
      exit(1);
    }

    if (getpinfo(&ps) < 0) {
      fprintf(2, "getpinfo: failed to get process info");
      exit(1);
    } else {
      printf("pid\t| In Use | Original Tickets | Current Tickets | Time Slices\n");
      for (int i = 0; i < NPROC; i++) {
        if (ps.inuse[i] == 1) {
          printf("%d\t  %d\t   %d\t\t\t%d\t\t%d\n", 
            ps.pid[i], ps.inuse[i], ps.tickets_max[i], ps.tickets_current[i], ps.time_slices[i]);
        }
      }    
    }

    exit(0);
  }
```