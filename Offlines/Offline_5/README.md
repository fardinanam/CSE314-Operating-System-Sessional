# Offline 5 (Memory Management)
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