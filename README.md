<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Digital Systems course git repository, year 2018

* [Important](#important)
* [Assignments](#assignments)
* [Documentation](#documentation)
* [Tools](#tools)

## Important

### Lab reports

Do not forget to write your lab reports in the `REPORT.md` files: simply explain what you do, why and with what results. Use the Markdown syntax. If needed you can add pictures, code snippets... To explain your source code you can add text to the `REPORT.md` file or add comments directly in the source file, as you wish.

### Avoid polluting the git repository

Remember that we all share the same git repository, reason why it is important to keep it reasonably clean. To avoid a too fast growing of the size of the repository, please:

* avoid adding full directories; it is sometimes convenient but also the best way to add a large number of large generated files that we do not want in the repository; try to `git add` only individual files, and only files that make sense (source files, reports, images...),
* try to run simulations and syntheses out of your local copy of the git repository; the large generated files will be kept out of the source tree and this will reduce the risk of accidental commits of unwanted files,
* try to use the right resolution for the images that you add to your reports,
* if you create local branches other than your personal branch, do not push them to the remote.

### Carefully check the synthesis results

The semantics of the VHDL language for simulation and synthesis are not the same. As a consequence, it can perfectly be that your design simulates apparently as expected but that the synthesis result does not behave as expected on the target hardware. When synthesizing with Xilinx Vivado it is thus strongly advised to carefully check the synthesis results:

* Look at errors and warnings in the main log file (`vivado.log`). Most warnings can be ignored because they correspond to unused elements that are discarded by the synthesis but some must sometimes be considered seriously.
* Look at errors and warnings in the synthesis log file of your module(s). Its(their) path(s) is(are) mentioned in the main log file, search for the string `"log"` in `vivado.log`.
* Look at the resources usage report (`XXX_utilization_placed.rpt`) and check that it makes sense. If it reports register used as latches, for instance, it is probably not what you want.
* Look at the timing report (`XXX_timing_summary_routed.rpt`) and check that timing constraints are correctly specified and met. If you have latches not clocked by a declared clock pin, for instance, and/or pins not constrained for maximum delay, there is probably a serious problem.

## Assignments

### For 2018-06-19 (day before written exam)

* Continue working on your SHA256 project
* Complete all other labs
* Finalize your lab reports
* Return the Zybo kit (see [here](http://soc.eurecom.fr/DS/zybo.html) for a description of the content)

### For 2018-05-28

* Search Internet about Linux device drivers, read the documentation of the Linux kernel, try to understand as much as you can the example DHT11 Linux device driver.
* Imagine a hardware architecture for a SHA256 accelerator. Find and read papers about SHA256 hardware implementations.

### For 2018-05-14

* Finish reading the [Free Range Factory] VHDL book (appendices plus chapter 8, just to know a bit more about component-based structural modelling).
* Finish all challenges and labs, complete the lab reports.
* Search Internet about Linux device drivers.

### For 2018-04-23

* Read chapters 11 and 12 of the [Free Range Factory] VHDL book.
* Finish all challenges and labs, complete the lab reports.
* Search Internet about Linux device drivers.

### For 2018-04-16

* Read chapters 9 and 10 of the [Free Range Factory] VHDL book.
* Read the specifications of the AXI4 lite communication protocol. First read part B of the [AXI protocol specification], then read chapters A1 to A4 but only the parts that are relevant for AXI4 lite.
* Start imagining a AXI4 lite compliant wrapper for the `dht11_ctrl` controller.

### For 2018-04-09

* Read chapters 6 and 7 of the [Free Range Factory] VHDL book.
* Read these chapters of the [documentation](#documentation):
  * [Resolution functions, unresolved and resolved types]
  * [Protected types]
  * [Recursivity]
  * [Aggregate notations]
  * [Random numbers generation]
* Complete the block diagram of your DHT11 controller

### For 2018-03-26

* Search on Internet about the differences between custom integrated circuits and FPGAs.
* Read chapter 5 of the [Free Range Factory] VHDL book.
* Read these chapters of the [documentation](#documentation):
  * [Comments]
  * [Identifiers]
  * [Wait]
  * [D-flip-flops (DFF) and latches]
* Read the [DHT11 sensor datasheet]

### For 2018-03-19

* Continue learning git and Markdown.
* Read chapter 4 of the [Free Range Factory] VHDL book.
* Read the [Getting started with VHDL] chapter of the [documentation](#documentation).
* Read the [Digital hardware design using VHDL in a nutshell] chapter of the [documentation](#documentation).

### For 2018-03-12

* Learn a bit of `git` ([ProGit book]). Whatch the videos. Try to imagine a workflow with a protected master branch and one branch per student.
* Learn a bit of Markdown ([Daring Fireball], [Markdown tutorial]).
* Visit the [Free Range Factory] web site and get your own PDF copy of their VHDL book. Read the first three chapters.
* Imagine a digital hardware machine that would behave as the `g1` signal generator. Draw it.

## Documentation

### The Zybo board

* [Zybo reference manual]
* [Zybo schematics]

### The VHDL language

* [Getting started with VHDL]
* [Digital hardware design using VHDL in a nutshell]
* [Comments]
* [Identifiers]
* [Wait]
* [D-flip-flops (DFF) and latches]
* [Resolution functions, unresolved and resolved types]
* [Protected types]
* [Recursivity]
* [Aggregate notations]
* [Arithmetic: which types to use?]
* [Entity instantiations]
* [Generics]
* [Random numbers generation]

### Miscellaneous

* [Standard cells library datasheet]
* [DHT11 sensor datasheet]
* [AXI protocol specification]

## Tools

### VHDL simulation

[GHDL] is probably the most mature free and open source VHDL simulator. It comes in three different flavours depending on the backend used: `gcc`, `llvm` or `mcode`. It runs under Windows, GNU/Linux and Mac OS X. It has no graphical user interface but waveforms can be displayed using [GTKWave].

Mentor Graphics offers a free of charge, **Windows only** version version of Modelsim: the [ModelSim PE Student Edition]. It is for use by students in their academic coursework. It has several limitations compared to the regular version but they should not be a problem for this course.

Intel also offers a free of charge version, the [ModelSim-Intel FPGA Starter Edition Software] with similar limitations but that runs under Windows or GNU/Linux. Note that it is a 32 bits version, so if your GNU/Linux OS is 64 bits you will need to install the 32 bits version of several software libraries. Note also that, under GNU/Linux, the shell scripts used to launch the tools check the OS and abort with an error message if it is not one of the officially supported. Last but not least, this version of Modelsim uses an outdated version of the `freetype` software library. If only more recent versions are found, the tool crashes with obscure error messages. If you want to install this Modelsim version on a 64-bits computer running a recent GNU/linux distribution (Debian Stretch or Ubuntu Xenial Xerus) the following instructions may help. They have been tested on Debian Stretch. The install directory of the tool is `/opt/Modelsim`. Adapt to your own configuration.

```bash
$ sudo dpkg --add-architecture i386
$ sudo apt-get update
$ sudo apt-get install libx11-6:i386 libxext6:i386 libxft2:i386 libncurses5:i386
$ sudo apt-get build-dep -a i386 libfreetype6
$ cd tmp
$ wget https://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.gz
$ tar xf freetype-2.4.12.tar.gz 
$ cd freetype-2.4.12/
$ ./autogen.sh 
$ ./configure --prefix=/opt/freetype-2.4.12 --build=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
$ make -j
$ make install
$ cd /opt/Modelsim/modelsim_ase/
$ ln -s linuxaloem linux_rh60
```

Then, in order to launch the simmulator:

```bash
$ LD_LIBRARY_PATH=/opt/freetype-2.4.12/lib vsim myDesign
```

Alternately you can define an alias in your `~/.bashrc`:

```bash
alias vsim='LD_LIBRARY_PATH=/opt/freetype-2.4.12/lib vsim $*'
```

and simply launch the simulator with:

```bash
$ vsim myDesign
```

### VHDL synthesis

There are free and open source synthesizers ([Yosys], [Icarus]) but, up to now, their native front-ends are only for the Verilog hardware description language, not VHDL. However, there is a VHDL plug-in for Yosys, based on a Verilog to VHDL translator.

[Xilinx] offers a free of charge version of the [Vivado] synthesis tool, named the WebPack edition. It has some limitations but they are not a problem for this course.

[ProGit book]: https://git-scm.com/book/en/v2
[Daring Fireball]: https://daringfireball.net/projects/markdown/syntax
[Markdown tutorial]: http://www.markdowntutorial.com/
[Free Range Factory]: http://freerangefactory.org/
[Zybo reference manual]: doc/zybo_rm.pdf
[Zybo schematics]: doc/zybo_sch.pdf
[Getting started with VHDL]: doc/getting-started-with-vhdl.md
[Digital hardware design using VHDL in a nutshell]: doc/digital-hardware-design-using-vhdl-in-a-nutshell.md
[GHDL]: https://github.com/tgingold/ghdl.git
[GTKWave]: http://gtkwave.sourceforge.net/
[ModelSim PE Student Edition]: https://www.mentor.com/company/higher_ed/modelsim-student-edition
[ModelSim-Intel FPGA Starter Edition Software]: https://www.altera.com/products/design-software/model---simulation/modelsim-altera-software.html
[Yosys]: http://www.clifford.at/yosys/
[Icarus]: http://iverilog.icarus.com/
[Xilinx]: ²https://www.xilinx.com/
[Vivado]: https://www.xilinx.com/support/download.html
[Comments]: doc/comments.md
[Identifiers]: doc/identifiers.md
[Wait]: doc/wait.md
[D-flip-flops (DFF) and latches]: doc/d-flip-flops-dff-and-latches.md
[Protected types]: doc/protected-types.md
[Recursivity]: doc/recursivity.md
[Resolution functions, unresolved and resolved types]: doc/resolution-functions-unresolved-and-resolved-types.md
[Aggregate notations]: doc/aggregate-notations.md
[Arithmetic: which types to use?]: doc/arithmetic-which-types-to-use.md
[Entity instantiations]: doc/entity-instantiations.md
[Generics]: doc/generics.md
[Random numbers generation]: doc/random-numbers-generation.md
[DHT11 sensor datasheet]: doc/DHT11.pdf
[Standard cells library datasheet]: doc/std_cell_lib_datasheet.pdf
[AXI protocol specification]: doc/axi.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
