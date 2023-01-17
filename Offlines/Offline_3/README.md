# Offline-3 (Lottery ticket scheduler)

## Instructions

Clone a fresh copy of [xv6-riscv](https://github.com/mit-pdos/xv6-riscv.git) repository. Make sure that the commit version you are in is ` 581bc4cbd1f6f5c207e729b78fac4328aef01228`. Then add the `1805087.patch` file from this repository to the root of the cloned repository. Then run the following commands:

```sh
  git checkout 581bc4cbd1f6f5c207e729b78fac4328aef01228
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