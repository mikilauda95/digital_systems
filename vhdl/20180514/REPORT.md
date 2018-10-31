# Digital Systems 14/05/2018 - Report Lab 8

1. [Introduction](## Introduction)
2. [Overview](## overview)
3. [Synthesis of the dht11_controller](### Synthesis of the dht11_controller)
4. [Device Tree Source](### Device Tree Source)
5. [The status register](### The status register)
6. [First Stage Boot Loader (FSBL)](## First Stage Boot Loader (FSBL))
7. [Zynq boot image](## Zynq boot image)
8. [Linux Kernel](## Linux Kernel)
9. [Root File System](## Root File System)
10. [DHT11 Linux driver](## DHT11 Linux driver)
11. [DHT11 Linux driver](## DHT11 Linux driver)
12. [Test in the Linux kernel](## Test in the Linux kernel)


## Introduction

  This laboratory is dedicated to the implementation of the dht11 controller as a Linux device driver. The objective is to make this device usable from the Linux kernel as a file in the /dev/ dedicated repository. The main advantage from this is that the device is accessible from the user level in an easier way than reading from the memory, operation which is clearly reserved only to the super user.

  As the laboratory was very guided, I did not have to perform many additional operations. In this report, I am going to discuss about the most important steps integrating some details where necessary.

## Overview

  For reaching the objective it is necessary to generate the following 4 files to be loaded on the SDCARD that goes in the Zybo board:

  - Linux Kernel Image
  - Device tree binary
  - Boot Image
  - The initramfs

Next sessions will be dedicated to these files explanation and generation.


## Synthesis of the dht11_controller

  The first step is the synthesis of the dht11_controller previously designed in last lab.  Actually this step is needed to generate two files
  1. `top_wrapper.bit` : a bitstream file needed to program the FPGA.
  2. `top_wrapper.sysdef` : A description of our design, used by `hsi` tool from Xilinx to generate hardware-dependent software,

  While the first file has been already seen and used in previous laboratory sessions, the second one will be important for the aim of this lab. In fact, as it will be discussed later, it will be used to generate the device tree source, which contains a description of the hardware platform.


## Device tree source

  As stated earlier, Xilinx provide a useful tool for generating the Device tree source (`dts`). This is written in a particular language and so must be compiled with a specific compiler (`dtc`). The output of the compilation is a Device Tree Blob (`dtb`) that can be used directly by the kernel.
  During the generation of the sources, multiple files are generated. In particular we have the `system.dts` which is the top level entity that includes more specific descriptions like for example `pl.dtsi`.
  This last describes the Programmable Logic platform that in our case is the FPGA. Here is a small extract:

```c
    amba_pl: amba_pl {
    #address-cells = <1>;
    #size-cells = <1>;
      compatible = "simple-bus";
      ranges ;
    dht11_ctrl_axi: dht11_ctrl_axi@40000000 {
                      compatible = "xlnx,dht11-ctrl-axi-1.0";
                      reg = <0x40000000 0x1000>;
                    };
    };
```
Here, it is possible to appreciate two important information about the device:

- `reg = <0x40000000 0x1000>;` : This tells where the device will be mapped in memory (0x40000000) and for how many addresses (0x1000).
- `compatible = "xlnx,dht11-ctrl-axi-1.0";` : indicates the compatible string of the device which is used by the Linux kernel to search for a compatible software driver.

It can be noticed that the dht11_ctrl_axi inherits from the ampa_pl class with compatible string `simple bus`. This is something that usually happens with Linux drivers. In fact, a hierarchy of devices is created in order to improve the portability and the easy of use. For example, in the case of  a USB device the device could inherits from the USB-bus class.
These two attributes just seen will be used later when designing the Linux driver to make it compatible.

## First Stage Boot Loader (FSBL)

When the boards is switched on, instructions on a ROM are executed. These will load a boot image from the selected boot medium (indicated with the blue jumper).
The boot image will contain packed multiple binary files:

- The executable of the FSBL
- The configuration bitstream for programmming the FPGA
- The executable binary of what is executed after the FSBL

So, actually the First Stage Boot Loader will extract the bitstream and program the FPGA and load in memory the next software, which will be the ultimate loader for the Linux Kernel.

The `top_wrapper.sysdef` (the same used for the dts) is needed to generate the FSBL . Then, thanks to `hsi` Xilinx tool it is possible to generate the source code that needs to be cross-compiled. Here is the command that accomplishes this task:

```
hsi% generate_app -hw $design -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -sw fsbl -dir fsbl
```
From the manual, the command generates a template of the application for a processor on an Operating system
* `-hw` is the name of the hardware design
* `-os` is the name of the Operating System
* `-proc` is the typology of processor mounted on the Zybo board for which the app must be generated
* `-app` is the name of the application FSBL stands for (First Stage Boot Loader)
* `-dir` is the directory in which the App will be generated

## Second Stage Boot Loader (Das U-boot)

As said previously, the FSBL will load another loader whose task it to load the Linux Kernel together with the Device tree Blob and the Root File System.

As done with the FSBL, the U-boot loader needs to be cross-compiled. However in this case we need to specify the CROSS_COMPILE environment variable (`export CROSS_COMPILE=arm-linux-gnueabihf`) to tell the Makefile what compiler to use. Then running make it is possible to compile U-Boot.

## Zynq boot image

Finally the boot image can be generated using the `bootgen` Xilinx tool. However a brief description of the boot image must be provided in the `boot.bif` with the loacation of files that need to be packed.

## Linux Kernel

The Linux Kernel can be seen as the interface between the hardware platform and the user and is the core of an Operating system. It provides the so called hardware abstraction, i.e. the possibility to develop and use programs without caring of the architecture which is behind.

Similarly to what happened with U-boot, the Linux kernel needs to be cross compiled for our target architecture. This can be easily done defining ARCH=arm, as we are going to run the Linux kernel on an ARM core. As this process would generate a compressed executable file (zImage), and as for our purpose we need a uImage file, we need to convert it using `mkimage` tool but because the Linux kernel build systems knows how to use it, it can be invoked simply running `make ARCH=arm LOADADDR=0x8000 uImage`, where `LOADADDR` is the load address of the Linux kernel. Actually this operation simply adds a 64 Bytes header which contains the load address and the entry point.

## Root File System

Now, in order to be able to use the Linux kernel properly, we first need a filesystem to work on.  For the purpose of this laboratory, only the root file system will be installed, on which other file systems are mounted, and it will be of type `initramfs`.
This type of f.s. allows to use a partition of the RAM as storage. Despite the small size that a RAM can provide compared to mass storage, the resulting system will be very fast and also does not require any mass storage device (and so any drivers).  For these reasons, this file system is very popular in embedded systems and less in personal computer. However, the capacity is very limited (only a subset of the Ram can be used as some must be reserved for running use) and the memory is volatile, so data is lost every time the system is shut down.

The iniramfs can be generated with automated tools as Buildroot. This one is a tool useful for people that work with embedded systems that facilitates the cross compilation of a complete Linux system (Kernel image, rootfile system, bootloader).

In this case, it is already provided as a compressed archive, so it is necessary to extract it (with `zcat`) and turn into an archive using `cpio` utility.

However, it is not possible to proceed this way as the FS trees has many files with root privileges which I do not own on the machine I am working on.
To solve this problem, `fakerooot` utility is used to assign to all the files the user permissions and store the original ones in another file.
This way it is possible to work with the file system that will be mounted later. Here we can include modules (such as the driver to be written) as well as any kind of file that we want to have when booting the kernel.

## DHT11 Linux driver

The model that is used to implement the dht11 driver is the platform device driver. This model is best suited for those devices which present the following properties:
- `Inherently not discoverable`, so it cannot be recognized when the device is attached
- `Bounding through matching names`
- `Platform devices registered very early` during kernel booting

So in order to link a certain device to a driver it is needed to:
1. register a platform driver that will manage this device. It should define a unique name
2. register your platform device, defining the same name as the driver.

This means that a platform device cannot be recognized dynamically. The coupling must be done statically (through the compatible in this case) and must be registered at the kernel boot.

### The C driver file

One of the main points of the Linux based operating system, is that communication with devices (and not only) should happen through files. So the main objective of the Linux driver is to make the device resemble a file, so that a program can access to it using File input/output operations.

The driver, as it is implemented as a kernel module, does not use the same libraries that are used in normal C programming, instead it uses special kernel libraries. For example, `printk` is used instead of the classic `printf` (`kmalloc` instead of `malloc`).
There are two main reasons for which kernel programming cannot use standard C libraries:
- `Architectural reason`: user space is implemented on top of kernel services, not the opposite
- `Technical reason`: the kernel is on its own during the boot up phase, before it has accessed a root file system.

Another peculiarity of kernel programming is that it uses many macros and defines. These facilitate both the programming (making it less verbose) phase and improve the portability.

To accomplish that, the C driver has to use particular structures and implements certain operations. Everything will be clearer looking at the code:

### The platform_driver structure
This is the main structure which define the driver. Its attributes are:
- `.driver`: of type `device_driver` where you can define the name, the owner and a match table(see next session)
- `.probe`: indicate the what function is used as probe_function. probe() will be called to make sure that the device exist and the functionality is fine.
- `.remove`: tells what function is used as remove_function. remove() tells what to do when the module is removed.
The structure contains also other attributes, but at a minimum, the probe() and remove() callbacks must be supplied; the other callbacks have to do with power management (shutdown, suspend, resume) and should be provided if they are relevant.


### `of_device_id`
This simple structure that is passed to the platform_driver structure, needs to set the `.compatible` attribute with the same compatible name set in the device tree. This way, the kernel is able to couple a certain device to a certain driver easily. To be more precise, the macro `MODULE_DEVICE_TABLE` exposes this information to the `depmod` program, that is used to check the module dependency.


### `dht11_probe`

This implements the probe() function for the dht11. As said earlier, it needs to check the correct functionality of the device. In order it:
1. Get information of memory resources from the device tree calling the `platform_get_resources
` checking if it is present
2. Allocate the physical address space of the device with the information from the device tree.
3. remap the static allocated address space to a virtual address space
4. request device major number
5. initialize cdev structure: This is a structure used to represent a character device. It must be coupled with a structure containing the three basic file functions (open, close, read, write)
6. register cdev structure to kernel, with device major number. This number, together with the minor number, is assigned to each character and block device. While some major numbers are reserved to particular device drivers, others are dynamically assigned when Linux boots. The minor number is used to distinguish devices.
7. create device class
8. populate device info under class

Finally, once finished, it prints (`printk`) a message with the address where the module has been loaded.

As errors could occur in any of this step, in case, it is necessary to revert all the previous operations during the error management. This has been implemented using the goto statement, which implements an unconditional jump to a certain label. then, it is sufficient to put the error management for each error in reverse order to reach the wanted objective.

### `dht11_remove`

This implements the remove() function for the dht11. Actually, it only destroys all the data structure created during the probe() and print (`printk`) a message once it has finished.

### `dht11_open` and `dht11_close`
Function that is executed every time the file is opened/closed. In this case, no operations are implemented.

### `dht11_read`
This function implements the read operation. It first checks the endianess reading the first byte of a dummy variable (with value 42): if the first byte of this variable is 42, then it means that the least significant byte is found at the lowest address and the architecture is little endian. In the opposite case the architecture is big endian.
The read operation reads 64 bits at a time, in two steps of 32 bits. The first 32 bits read are shifted left of 32 bits and then the second 32 bits chunk is ORed to it. In case of little endian, the bit shifted left are the ones read at the highest address (the lowest address in case of big endian).
As a comment, the operation of testing the endianess could maybe be done in some other ways like for examples using the macros `cpu_to_be32()` or `cpu_to_le32()` provided by the kernel.
Another observation is that the read operation read 4 bytes at a time, the length of a word for the processor used making this code not portable.


## Test in the Linux kernel

Now the kernel driver can be compiled and included in the unpacked iniramfs. After packing it again (using the `fakeroot` utility), the file system is ready to be used.

Including the 4 needed files in the SDCARD, it is possible to boot the board and connect to it using `picocom` through USB.

Before being able to use the driver, it is necessary to import it using `insmod` (or alternatively with `modprobe`) that calls the probe() method discussed previously.
It is possible to check that the module has been imported with `lsmod`.

```console
dht11> lsmod
Module                  Size  Used by    Tainted: G
dht11_driver            2901  0
```


### Facilitate the reading with a simple C program

As the device is seen as a file, this can be manipulated using file operation of the stdio.h library in C.
As the kernel does not provide a compiler, we need to cross compile the program from the host system. Then it is possible to include it in the root file system before being packed.
The source program is available at [C/read_dht11](C/read_dht11) and the output can be appreciated here below:

```console
dht11> ./read_dht11
The temperature read is 26.00 °C
The humidity read is 43%
The status register is 03
```
