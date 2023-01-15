# Running the `.patch` file

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
