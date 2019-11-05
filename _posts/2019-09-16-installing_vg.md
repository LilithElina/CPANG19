---
layout: post
title: "Installing vg"
categories: installation
author: LilithElina
---

According to [their GitHub](https://github.com/vgteam/vg), vg is best installed by downloading the static release build for Ubuntu/Mac OS, but I'm not sure how that works. We usually install software packages on our system with conda, which does not yet support vg (although there [have been tries](https://github.com/bioconda/bioconda-recipes/pull/5086) to include it in [BioConda](https://github.com/bioconda)). I will try other alternatives to install the software on our server. 

* Do not remove this line (it will not be displayed)
{:toc}

## Buidling from GitHub with pip

I will first try to do it with pip, as described on [StackOverflow](https://stackoverflow.com/a/50141879).

Change to root account:
```bash
sudo -i
```

Make sure pip and git are installed:
```bash
conda install git pip
```
(pip was already installed, git wasn't)

Try building from GitHub with pip:
```bash
pip install git+https://github.com/vgteam/vg.git
```

Error message:
```
DEPRECATION: Python 2.7 will reach the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 won't be maintained after that date. A future version of pip will drop support for Python 2.7. More details about Python 2 support in pip, can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
Collecting git+https://github.com/vgteam/vg.git
  Cloning https://github.com/vgteam/vg.git to /tmp/pip-req-build-R08wb1
  Running command git clone -q https://github.com/vgteam/vg.git /tmp/pip-req-build-R08wb1
  Running command git submodule update --init --recursive -q
  fatal: unable to connect to sourceware.org:
  sourceware.org[0: 209.132.180.131]: errno=Connection timed out

  fatal: clone of 'git://sourceware.org/git/elfutils.git' into submodule path '/tmp/pip-req-build-R08wb1/deps/elfutils' failed
  Failed to clone 'deps/elfutils'. Retry scheduled

  fatal: unable to connect to sourceware.org:
  sourceware.org[0: 209.132.180.131]: errno=Connection timed out

  fatal: clone of 'git://sourceware.org/git/elfutils.git' into submodule path '/tmp/pip-req-build-R08wb1/deps/elfutils' failed
  Failed to clone 'deps/elfutils' a second time, aborting
ERROR: Command errored out with exit status 1: git submodule update --init --recursive -q Check the logs for full command output.
```

Try building from GitHub with pip3 instead:
```bash
pip3 install git+https://github.com/vgteam/vg.git
```

Result:
```
Collecting git+https://github.com/vgteam/vg.git
  Cloning https://github.com/vgteam/vg.git to /tmp/pip-guao0b6q-build
fatal: unable to connect to sourceware.org:
sourceware.org[0: 209.132.180.131]: errno=Connection timed out

fatal: clone of 'git://sourceware.org/git/elfutils.git' into submodule path 'deps/elfutils' failed
Command "git submodule update --init --recursive -q" failed with error code 128 in /tmp/pip-guao0b6q-build
You are using pip version 8.1.1, however version 19.2.3 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
```

Log out of root account:
```bash
exit
```

## Using Singularity and Docker

vg offers a [Docker image](https://github.com/vgteam/vg/releases/tag/v1.18.0) of the latest version as well. We don't have Docker installed and I might not even need to do that...  
Another tool I would like to try for genome graphs is [Pandora](https://github.com/rmcolq/pandora), and that is best installed using [Singularity](https://sylabs.io/docs/). Singularity, on the other hand, can be installed with conda and can also work with Docker images.  
Yes, it sounds complicated, but I'm trying it anyway, hoping that this solution will keep our server as clean as possible.

```bash
conda install -c conda-forge singularity 
singularity selftest
```

```
 + sh -c test -f /usr/bin/miniconda3/singularity/singularity.conf                      (retval=0) OK
 + test -u /usr/bin/miniconda3/libexec/singularity/bin/action-suid                     (retval=1) ERROR
```

Hmm, I hope that works... I'll [try first with Pandora]({% post_url 2019-09-23-installing_pandora %}), since that comes in a Singularity container and I don't have to check how using a Docker container within Singularity will work.

I had some problems with this conda installation of Singularity, so I removed it and instead used the official installation instructions (see [Pandora protocol]({% post_url 2019-09-23-installing_pandora %})). Now everything should be working fine.


```bash
singularity pull docker://quay.io/vgteam/vg:v1.19.0
```

This created a `vg_v1.19.0.sif` file similar to the `pandora_pandora.sif` file I pulled earlier. Let's see if this works!

```bash
singularity shell vg_v1.19.0.sif
```

Yes, I am now inside the vg container, but I can't use vg:

```bash
vg construct
```

```
Illegal instruction (core dumped)
```

Leaving the image results in a lot of output as well:

```bash
exit
```

```
exit
SIGILL: illegal instruction
PC=0x47381b m=0 sigcode=0

goroutine 1 [running, locked to thread]:
syscall.RawSyscall(0x3e, 0x6467, 0x4, 0x0, 0x0, 0xc00008e300, 0xc00008e300)
        /usr/local/go/src/syscall/asm_linux_amd64.s:78 +0x2b fp=0xc0001dfea8 sp=0xc0001dfea0 pc=0x47381b
syscall.Kill(0x6467, 0x4, 0x0, 0x0)
        /usr/local/go/src/syscall/zsyscall_linux_amd64.go:597 +0x4b fp=0xc0001dfef0 sp=0xc0001dfea8 pc=0x47059b
github.com/sylabs/singularity/internal/app/starter.Master.func2()
        internal/app/starter/master_linux.go:152 +0x62 fp=0xc0001dff38 sp=0xc0001dfef0 pc=0x776132
github.com/sylabs/singularity/internal/pkg/util/mainthread.Execute.func1()
        internal/pkg/util/mainthread/mainthread.go:21 +0x2f fp=0xc0001dff60 sp=0xc0001dff38 pc=0x77444f
main.main()
        cmd/starter/main_linux.go:102 +0x5f fp=0xc0001dff98 sp=0xc0001dff60 pc=0x96b42f
runtime.main()
        /usr/local/go/src/runtime/proc.go:200 +0x20c fp=0xc0001dffe0 sp=0xc0001dff98 pc=0x431cbc
runtime.goexit()
        /usr/local/go/src/runtime/asm_amd64.s:1337 +0x1 fp=0xc0001dffe8 sp=0xc0001dffe0 pc=0x45cd81

goroutine 5 [syscall]:
os/signal.signal_recv(0xb8a6a0)
        /usr/local/go/src/runtime/sigqueue.go:139 +0x9c
os/signal.loop()
        /usr/local/go/src/os/signal/signal_unix.go:23 +0x22
created by os/signal.init.0
        /usr/local/go/src/os/signal/signal_unix.go:29 +0x41

goroutine 7 [chan receive]:
github.com/sylabs/singularity/internal/pkg/util/mainthread.Execute(0xc00027fc30)
        internal/pkg/util/mainthread/mainthread.go:24 +0xb4
github.com/sylabs/singularity/internal/app/starter.Master(0x7, 0x4, 0x6478, 0xc00000eb20)
        internal/app/starter/master_linux.go:151 +0x44f
main.startup()
        cmd/starter/main_linux.go:75 +0x53f
created by main.main
        cmd/starter/main_linux.go:98 +0x35

rax    0x0
rbx    0x0
rcx    0x47381b
rdx    0x0
rdi    0x6467
rsi    0x4
rbp    0xc0001dfee0
rsp    0xc0001dfea0
r8     0x0
r9     0x0
r10    0x0
r11    0x202
r12    0x0
r13    0xff
r14    0xb712fc
r15    0x0
rip    0x47381b
rflags 0x202
cs     0x33
fs     0x0
gs     0x0
```

None of this appears when exiting the Pandora image, so I assume that Singularity did not manage to convert the Docker container properly. If I want the latest vg version, I think I'll just have to build from source and check out vg from time to time as mentioned in the CPANG19 [toy examples](/pages/toy_examples.html) (`git clone https://github.com/vgteam/vg.git`).

```bash
rm vg_v1.19.0.sif
```

## Building from source

### Cloning the repo from GitHub

I'll clone the vg repository into the /data3/genome_graph/ directory and work from there.

```bash
cd /data3/genome_graphs/
git clone --recursive https://github.com/vgteam/vg.git
cd vg
```

The cloning did not complete, unfortunately. It ended here:

```
Cloning into 'deps/elfutils'...
fatal: unable to connect to sourceware.org:
sourceware.org[0: 209.132.180.131]: errno=Connection timed out

fatal: clone of 'git://sourceware.org/git/elfutils.git' into submodule path 'deps/elfutils' failed
```

Looking at the repo online, this is not a complete surprise, since this link is the only one that doens't work. I wonder if I can still get vg to work...

### Installing dependencies

Since we have Ubuntu 16.04, I should be able to use `make` to install required dependencies, except for [Protobuf](https://github.com/protocolbuffers/protobuf) 3, which I will have to install manually.

```bash
make get-deps
```

This starts with a new error:

```
Package jansson was not found in the pkg-config search path.
Perhaps you should add the directory containing `jansson.pc'
to the PKG_CONFIG_PATH environment variable
No package 'jansson' found
Package jansson was not found in the pkg-config search path.
Perhaps you should add the directory containing `jansson.pc'
to the PKG_CONFIG_PATH environment variable
No package 'jansson' found
sudo apt-get install -qq -y build-essential git protobuf-compiler libprotoc-dev libjansson-dev libbz2-dev libncurses5-dev automake libtool jq samtools curl unzip redland-utils librdf-dev cmake pkg-config wget bc gtk-doc-tools raptor2-utils rasqal-utils bison flex gawk libgoogle-perftools-dev liblz4-dev liblzma-dev libcairo2-dev libpixman-1-dev libffi-dev libcairo-dev libprotobuf-dev
```

#### Jansson

Apparently I should have installed some things before attempting this?
Let's check out [Jansson](https://jansson.readthedocs.io/en/2.12/gettingstarted.html), then.

```bash
cd ~
tar -zxvf jansson-2.12.tar.gz
./configure
make
make check
make install
```

This gives a lot of output, I'm just pasting the - for me - most important here (from `make check`):

```
============================================================================
Testsuite summary for jansson 2.12
============================================================================
# TOTAL: 1
# PASS:  1
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
============================================================================
```

`make install`, on the other hand, returned this:

```
Making install in doc
make[1]: Entering directory '/home/spo12/jansson-2.12/doc'
make[2]: Entering directory '/home/spo12/jansson-2.12/doc'
make[2]: Nothing to be done for 'install-exec-am'.
make[2]: Nothing to be done for 'install-data-am'.
make[2]: Leaving directory '/home/spo12/jansson-2.12/doc'
make[1]: Leaving directory '/home/spo12/jansson-2.12/doc'
Making install in src
make[1]: Entering directory '/home/spo12/jansson-2.12/src'
make[2]: Entering directory '/home/spo12/jansson-2.12/src'
 /bin/mkdir -p '/usr/local/lib'
 /bin/bash ../libtool   --mode=install /usr/bin/install -c   libjansson.la '/usr/local/lib'
libtool: install: /usr/bin/install -c .libs/libjansson.so.4.11.1 /usr/local/lib/libjansson.so.4.11.1
/usr/bin/install: cannot create regular file '/usr/local/lib/libjansson.so.4.11.1': Permission denied
Makefile:402: recipe for target 'install-libLTLIBRARIES' failed
make[2]: *** [install-libLTLIBRARIES] Error 1
make[2]: Leaving directory '/home/spo12/jansson-2.12/src'
Makefile:630: recipe for target 'install-am' failed
make[1]: *** [install-am] Error 2
make[1]: Leaving directory '/home/spo12/jansson-2.12/src'
Makefile:453: recipe for target 'install-recursive' failed
make: *** [install-recursive] Error 1
```

That was easy to solve, though:

```bash
sudo make install
```

Great, now we have Jansson installed, I guess I better [install Protobuf3](https://gist.github.com/rvegas/e312cb81bbb0b22285bc6238216b709b) as well before I try building vg again.

#### Protobuf3
{: #protoc }

```bash
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.9.2/protoc-3.9.2-linux-x86_64.zip
mkdir protoc3
unzip protoc-3.9.2-linux-x86_64.zip -d protoc3
sudo mv protoc3/bin/* /usr/local/bin/
sudo mv protoc3/include/* /usr/local/include/
```

Now let's try getting the other required dependencies for vg!

```bash
cd /data3/genome_graphs/vg/
make get-deps
```

No errors this time.

```bash
. ./source_me.sh && make
```

```
make: *** No rule to make target 'deps/sdsl-lite/lib/*.cpp', needed by 'lib/libsdsl.a'.  Stop.
```

#### SDSL lite

The source shell script runs fine it seems, but make won't complete and the bin/ directory is empty.
I'll try to clone [SDSL lite](https://github.com/simongog/sdsl-lite/tree/ddb0fbbc33bb183baa616f17eb48e261ac2a3672) from github and see if that helps.

```bash
cd deps/
git clone https://github.com/simongog/sdsl-lite.git
cd ../
make
```

The cloning worked, and this time make resulted in a lot of output, I think generated by building SDSL. It ended like this:

```
make: *** No rule to make target 'deps/ssw/src/*.c', needed by 'lib/libssw.a'.  Stop.
```

#### ssw

So it looks like I'm doing the very manual approach here.

```bash
cd deps/
git clone https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library
rm -r ssw/
mv Complete-Striped-Smith-Waterman-Library/ssw/
cd ..
make
```

```
. ./source_me.sh && cd deps/ssw/src && make  && ar rs /data3/genome_graphs/vg/lib/libssw.a ssw.o ssw_cpp.o && cp ssw_cpp.h ssw.h /data3/genome_graphs/vg/lib
make[1]: Entering directory '/data3/genome_graphs/vg/deps/ssw/src'
gcc -c -o ssw.o ssw.c -Wall -pipe -O2
gcc -o ssw_test ssw.o main.c -Wall -pipe -O2 -lm -lz
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/ssw/src'
ar: creating /data3/genome_graphs/vg/lib/libssw.a
ar: ssw_cpp.o: No such file or directory
Makefile:388: recipe for target 'lib/libssw.a' failed
make: *** [lib/libssw.a] Error 1
```

Since the executable is there and working, I assume that this missing file is not, in fact, needed (at least not with content).

```bash
cd deps/ssw/src/
touch ssw_cpp.o
cd ../../../
make
```

```
. ./source_me.sh && cd deps/ssw/src && make  && ar rs /data3/genome_graphs/vg/lib/libssw.a ssw.o ssw_cpp.o && cp ssw_cpp.h ssw.h /data3/genome_graphs/vg/lib
make[1]: Entering directory '/data3/genome_graphs/vg/deps/ssw/src'
make[1]: Nothing to be done for 'core'.
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/ssw/src'
ar: creating /data3/genome_graphs/vg/lib/libssw.a
make: *** No rule to make target 'deps/snappy/*.cc', needed by 'lib/libsnappy.a'.  Stop.
```

#### snappy

```bash
cd deps/
git clone https://github.com/google/snappy
cd ../
make
```

```
. ./source_me.sh && cd deps/snappy && ./autogen.sh && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -msse4.2" ./configure --prefix=/data3/genome_graphs/vg  && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -msse4.2" make libsnappy.la  && cp .libs/libsnappy.a /data3/genome_graphs/vg/lib/ && cp snappy-c.h snappy-sinksource.h snappy-stubs-public.h snappy.h /data3/genome_graphs/vg/include/
/bin/sh: 1: ./autogen.sh: not found
Makefile:393: recipe for target 'lib/libsnappy.a' failed
make: *** [lib/libsnappy.a] Error 127
```

```bash
cd deps/snappy/
mkdir build
cd build && cmake ../ && make
```

This (commands copied from the [snappy repo](https://github.com/google/snappy)) resulted in a lot of output ending with:

```
collect2: error: ld returned 1 exit status
CMakeFiles/snappy_unittest.dir/build.make:121: recipe for target 'snappy_unittest' failed
make[2]: *** [snappy_unittest] Error 1
CMakeFiles/Makefile2:104: recipe for target 'CMakeFiles/snappy_unittest.dir/all' failed
make[1]: *** [CMakeFiles/snappy_unittest.dir/all] Error 2
Makefile:138: recipe for target 'all' failed
make: *** [all] Error 2
```

Since we have a high enough CMake version and the error is pretty cryptic, I'll instead try to install it via `apt`:

```
sudo apt install snappy
```

I'm not sure this is the right `snappy`, though...

```bash
cmake ../
make
```

the `cmake ../` command from above is working, it's the `make`, again, that doesn't work. It results in a lot of text apparently related to a non-functioning unit test:

```
[ 62%] Built target snappy
[ 75%] Linking CXX executable snappy_unittest
CMakeFiles/snappy_unittest.dir/snappy_unittest.cc.o: In function `snappy::Snappy_ZeroOffsetCopy_Test::TestBody()':
snappy_unittest.cc:(.text+0x6fb2): undefined reference to `testing::Message::Message()'
...
CMakeFiles/snappy_unittest.dir/snappy_unittest.cc.o:(.rodata._ZTIN6snappy26Snappy_ZeroOffsetCopy_TestE[_ZTIN6snappy26Snappy_ZeroOffsetCopy_TestE]+0x10): undefined reference to `typeinfo for testing::Test'
CMakeFiles/snappy_unittest.dir/snappy_unittest.cc.o:(.rodata._ZTIN6snappy31Snappy_ReadPastEndOfBuffer_TestE[_ZTIN6snappy31Snappy_ReadPastEndOfBuffer_TestE]+0x10): more undefined references to `typeinfo for testing::Test' follow
collect2: error: ld returned 1 exit status
CMakeFiles/snappy_unittest.dir/build.make:121: recipe for target 'snappy_unittest' failed
make[2]: *** [snappy_unittest] Error 1
CMakeFiles/Makefile2:104: recipe for target 'CMakeFiles/snappy_unittest.dir/all' failed
make[1]: *** [CMakeFiles/snappy_unittest.dir/all] Error 2
Makefile:138: recipe for target 'all' failed
make: *** [all] Error 2
```

Maybe I'll try working with the last vg make error. That one mentions that autogen.sh wasn't found. Will installing this help?

```bash
cd /data3/genome_graphs/vg/
sudo apt-get install autogen
make
```

```
. ./source_me.sh && cd deps/snappy && ./autogen.sh && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -msse4.2" ./configure --prefix=/data3/genome_graphs/vg  && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -msse4.2" make libsnappy.la  && cp .libs/libsnappy.a /data3/genome_graphs/vg/lib/ && cp snappy-c.h snappy-sinksource.h snappy-stubs-public.h snappy.h /data3/genome_graphs/vg/include/
/bin/sh: 1: ./autogen.sh: not found
Makefile:393: recipe for target 'lib/libsnappy.a' failed
make: *** [lib/libsnappy.a] Error 127
```

No, it does not.

[It looks like](https://stackoverflow.com/questions/36408943/how-do-i-compress-a-text-file-in-ubuntu-using-snappy) the right snappy installation using apt would be this:

```
sudo apt-get install libsnappy-dev
make
```

But I still get the same error when trying to build vg.

Thoughts: `make` calls the source_me.sh shell script, which works, then goes into the deps/snappy directory, which exists and contains files, but it then tries to run autogen.sh from that directory and that script does not exist. I assume that it has to be generated somehow, but since building snappy isn't working, I don't know how.

I think I'll just start with snappy all over again, removing the remnants of my first try, and maybe do it as root this time.


```bash
cd deps/
rm -r snappy
sudo -i
cd /data3/genome_graphs/vg/deps/
git clone https://github.com/google/snappy
cd snappy/
mkdir build
cd build && cmake ../ && make
```

It looks like it actually worked this time! Some tests failed, but there is the libsnappy.a file now that was missing in the beginning. Let's see...

```bash
exit
cd ../
make
```

```
. ./source_me.sh && cd deps/snappy && ./autogen.sh && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -msse4.2" ./configure --prefix=/data3/genome_graphs/vg  && CXXFLAGS="-O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -msse4.2" make libsnappy.la  && cp .libs/libsnappy.a /data3/genome_graphs/vg/lib/ && cp snappy-c.h snappy-sinksource.h snappy-stubs-public.h snappy.h /data3/genome_graphs/vg/include/
/bin/sh: 1: ./autogen.sh: not found
Makefile:393: recipe for target 'lib/libsnappy.a' failed
make: *** [lib/libsnappy.a] Error 127
```

Well, fine, I can copy that file.

```bash
cp deps/snappy/build/libsnappy.a lib/
make
```

```
make: *** No rule to make target 'deps/rocksdb/db/*.cc', needed by 'lib/librocksdb.a'.  Stop.
```

And on we go...

#### RocksDB

```bash
cd deps/
git clone https://github.com/facebook/rocksdb.git
cd ../
make
```

```
. ./source_me.sh && cd deps/rocksdb && PORTABLE=1  DISABLE_JEMALLOC=1 make static_lib  && mv librocksdb.a /data3/genome_graphs/vg/lib/ && cp -r include/* /data3/genome_graphs/vg/include/
make[1]: Entering directory '/data3/genome_graphs/vg/deps/rocksdb'
$DEBUG_LEVEL is 0
```

The `make` command is now building [RocksDB](https://github.com/facebook/rocksdb.git) for me, which generates a lot of output and takes some time.

The whole thing ended with:

```
ar: creating librocksdb.a
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/rocksdb'
. ./source_me.sh && cp -r deps/gcsa2/include/gcsa /data3/genome_graphs/vg/include/ && cd deps/gcsa2 && make libgcsa2.a  && mv libgcsa2.a /data3/genome_graphs/vg/lib
cp: cannot stat 'deps/gcsa2/include/gcsa': No such file or directory
Makefile:404: recipe for target 'lib/libgcsa2.a' failed
make: *** [lib/libgcsa2.a] Error 1
```

#### gcsa2

```bash
cd deps/
git clone https://github.com/jltsiren/gcsa2.git
cd ../
make
```

Again skipping the output of building [GCSA2](https://github.com/jltsiren/gcsa2.git), we continue here:

```
ar rcs libgcsa2.a algorithms.o dbg.o files.o gcsa.o internal.o lcp.o path_graph.o support.o utils.o
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/gcsa2'
. ./source_me.sh && cp -r deps/gbwt/include/gbwt /data3/genome_graphs/vg/include/ && cd deps/gbwt && make  && mv libgbwt.a /data3/genome_graphs/vg/lib
cp: cannot stat 'deps/gbwt/include/gbwt': No such file or directory
Makefile:413: recipe for target 'lib/libgbwt.a' failed
make: *** [lib/libgbwt.a] Error 1
```

#### GBWT

```bash
cd deps/
git clone https://github.com/jltsiren/gbwt.git
cd ../
make
```

```
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/gbwt'
make: *** No rule to make target 'deps/libhandlegraph/src/include/handlegraph/*.hpp', needed by 'lib/libhandlegraph.a'.  Stop.
```

#### `libhandlegraph`

```bash
cd deps/
git clone https://github.com/vgteam/libhandlegraph.git
cd ../
make
```

```
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/libhandlegraph'
. ./source_me.sh && cp -r deps/gbwtgraph/include/gbwtgraph /data3/genome_graphs/vg/include/ && cd deps/gbwtgraph && make  && mv libgbwtgraph.a /data3/genome_graphs/vg/lib
cp: cannot stat 'deps/gbwtgraph/include/gbwtgraph': No such file or directory
Makefile:422: recipe for target 'lib/libgbwtgraph.a' failed
make: *** [lib/libgbwtgraph.a] Error 1
```

#### GBWTGraph

```bash
cd deps/
git clone https://github.com/jltsiren/gbwtgraph.git
cd ../
make
```

```
. ./source_me.sh && cp -r deps/gbwtgraph/include/gbwtgraph /data3/genome_graphs/vg/include/ && cd deps/gbwtgraph && make  && mv libgbwtgraph.a /data3/genome_graphs/vg/lib
make[1]: Entering directory '/data3/genome_graphs/vg/deps/gbwtgraph'

...

make[1]: *** [gfa.o] Error 1
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/gbwtgraph'
Makefile:422: recipe for target 'lib/libgbwtgraph.a' failed
make: *** [lib/libgbwtgraph.a] Error 2
```

The gbwtgraph directory is supposed to contain libgbwtgraph.a, but it's not there, so something in the make process must have gone wrong. I'll try again as root.

```bash
sudo -i
cd /data3/genome_graphs/vg/deps/gbwtgraph
make
```

```
/usr/bin/g++ -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic  -fopenmp -msse4.2  -std=c++11 -Wall -Wextra -DNDEBUG  -fopenmp -pthread -O3 -ffast-math -funroll-loops -DHAVE_CXA_DEMANGLE -Iinclude -I/data3/genome_graphs/vg/include -c gfa.cpp
gfa.cpp: In function ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> > gbwtgraph::gfa_to_gbwt(const string&, gbwt::size_type, gbwt::size_type, gbwt::size_type)’:
gfa.cpp:243:119: error: no matching function for call to ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> >::pair(gbwt::GBWT*, gbwtgraph::SequenceSource*&)’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
...
```

No, it's not working like that. The [GBWTGraph](https://github.com/jltsiren/gbwtgraph) repo says that you have to specify the SDSL directory in the makefile before compiling, but the standard directory is already the right one.

Maybe using `install.sh` works better?

```bash
install.sh
```

Lots of output, with similar errors. Some chosen examples:

```
...
gfa.cpp: In function ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> > gbwtgraph::gfa_to_gbwt(const string&, gbwt::size_type, gbwt::size_type, gbwt::size_type)’:
gfa.cpp:243:119: error: no matching function for call to ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> >::pair(gbwt::GBWT*, gbwtgraph::SequenceSource*&)’
   return std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
...
/usr/include/c++/5/bits/stl_pair.h:108:26: note:   candidate expects 0 arguments, 2 provided
Makefile:45: recipe for target 'gfa.o' failed
make: *** [gfa.o] Error 1
make: *** Waiting for unfinished jobs....
Error: Could not compile GBWTGraph.
```

Trying with a fresh version as root...

```bash
cd ../
rm -r gbwtgraph/
git clone https://github.com/jltsiren/gbwtgraph.git
cd ../
make
```

Still the same problem I can't understand. What if I try to update my version of vg here?

```bash
cd ../../
git pull
```

```
remote: Enumerating objects: 139, done.
remote: Counting objects: 100% (139/139), done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 161 (delta 137), reused 138 (delta 137), pack-reused 22
Receiving objects: 100% (161/161), 44.26 KiB | 492.00 KiB/s, done.
Resolving deltas: 100% (137/137), completed with 65 local objects.
From https://github.com/vgteam/vg
   4ab95f1e7..1ac878e5d  master           -> origin/master
 * [new branch]          bed-vg-find      -> origin/bed-vg-find
   e390bb7f6..75f455c7d  gh-pages         -> origin/gh-pages
 + 21f01f6fe...865bb0b19 packed-call      -> origin/packed-call  (forced update)
 * [new branch]          rna-memory-optim -> origin/rna-memory-optim
Updating 4ab95f1e7..1ac878e5d
Fast-forward
 README.md                           |   4 +-
 deps/libbdsg                        |   2 +-
 src/subcommand/annotate_main.cpp    |  24 +--
 src/subcommand/call_main.cpp        |  50 ++----
 src/subcommand/chunk_main.cpp       |  13 +-
 src/subcommand/cluster_main.cpp     |   9 +-
 src/subcommand/deconstruct_main.cpp |  12 +-
 src/subcommand/dotplot_main.cpp     |  10 +-
 src/subcommand/filter_main.cpp      |  12 +-
 src/subcommand/find_main.cpp        | 135 ++++++++++-------
 src/subcommand/gaffe_main.cpp       |  13 +-
 src/subcommand/gbwt_main.cpp        |  10 +-
 src/subcommand/inject_main.cpp      |  11 +-
 src/subcommand/locify_main.cpp      |   7 +-
 src/subcommand/map_main.cpp         |  19 ++-
 src/subcommand/mpmap_main.cpp       |  10 +-
 src/subcommand/pack_main.cpp        |  16 +-
 src/subcommand/rna_main.cpp         |  52 ++++---
 src/subcommand/sim_main.cpp         |  13 +-
 src/subcommand/surject_main.cpp     |  12 +-
 src/subcommand/trace_main.cpp       |   7 +-
 src/subcommand/validate_main.cpp    |   7 +-
 src/subcommand/vectorize_main.cpp   |  14 +-
 src/subcommand/viz_main.cpp         |  10 +-
 src/transcriptome.cpp               | 553 +++++++++++++++++++++++++++++++++++++++++++------------------------
 src/transcriptome.hpp               |  46 +++---
 src/traversal_finder.cpp            |   5 +-
 test/t/05_vg_find.t                 |  19 ++-
 test/t/07_vg_map.t                  |   9 +-
 test/t/18_vg_call.t                 |   4 +-
 test/t/26_deconstruct.t             |   7 +-
 31 files changed, 683 insertions(+), 432 deletions(-)
```

```bash
make
exit
```

No, still the same error.

**I think I'll *just* try again from the beginning.**


### Cloning the repo from GitHub

I'll remove the repo and start again, this time as root.

```bash
sudo -i
cd /data3/genome_graphs/
rm -rf vg/
git clone --recursive https://github.com/vgteam/vg.git
```

This time, the `elfutils` error didn't stop the cloning, dependencies like ssw and libhandlegraph were still cloned as expected. Maybe this time it will be easier!

```
Cloning into '/data3/genome_graphs/vg/deps/elfutils'...
fatal: unable to connect to sourceware.org:
sourceware.org[0: 209.132.180.131]: errno=Connection timed out

fatal: clone of 'git://sourceware.org/git/elfutils.git' into submodule path '/data3/genome_graphs/vg/deps/elfutils' failed
Failed to clone 'deps/elfutils' a second time, aborting
```

#### Installing dependencies

I already have Jansson and Protobuf3 installed, so I'll try `make get-deps` again.

```bash
cd vg/
make get-deps
```

```
sudo apt-get install -qq -y build-essential git protobuf-compiler libprotoc-dev libjansson-dev libbz2-dev libncurses5-dev automake libtool jq samtools curl unzip redland-utils librdf-dev cmake pkg-config wget bc gtk-doc-tools raptor2-utils rasqal-utils bison flex gawk libgoogle-perftools-dev liblz4-dev liblzma-dev libcairo2-dev libpixman-1-dev libffi-dev libcairo-dev libprotobuf-dev
```

Yes, it looks like I've got the dependencies set up and running as required.

#### Build vg

```bash
. ./source_me.sh && make
```

```
make: *** No rule to make target 'deps/sdsl-lite/lib/*.cpp', needed by 'lib/libsdsl.a'.  Stop.
```

No, I'm at the beginning of the above cycle again. In the end, it's all about this stupid elfutils link that's non-functional for me. For others it seems to have worked a few days ago, which I think is weird.

```bash
cd deps/
sudo git clone git://sourceware.org/git/elfutils.git
```

### Cloning the repo from GitHub (again)

OK, here's an idea: There is an [issue](https://github.com/angular/angular-phonecat/issues/141) on GitHub for a very different repo, where cloning the repo with "git://" in the beginning did not work from a company machine. Let's try the solution proposed there, this time not as root, as that just makes everything downstream more difficult.

```bash
git config --global url."https://".insteadOf git://

cd ../../
sudo rm -rf vg/
git clone --recursive https://github.com/vgteam/vg.git
cd vg/
. ./source_me.sh && make
```

Well, this ran for a lot longer than it did previously. It stopped at:

```
. ./source_me.sh && cp -r deps/gbwtgraph/include/gbwtgraph /data3/genome_graphs/vg/include/ && cd deps/gbwtgraph && make  && mv libgbwtgraph.a /data3/genome_graphs/vg/lib
make[1]: Entering directory '/data3/genome_graphs/vg/deps/gbwtgraph'
/usr/bin/g++ -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic  -fopenmp -msse4.2  -std=c++11 -Wall -Wextra -DNDEBUG  -fopenmp -pthread -O3 -ffast-math -funroll-loops -DHAVE_CXA_DEMANGLE -Iinclude -I/data3/genome_graphs/vg/include -c gbwtgraph.cpp
/usr/bin/g++ -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic -O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP -I /data3/genome_graphs/vg/include -I/data3/genome_graphs/vg/include/dynamic  -fopenmp -msse4.2  -std=c++11 -Wall -Wextra -DNDEBUG  -fopenmp -pthread -O3 -ffast-math -funroll-loops -DHAVE_CXA_DEMANGLE -Iinclude -I/data3/genome_graphs/vg/include -c gfa.cpp
gfa.cpp: In function ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> > gbwtgraph::gfa_to_gbwt(const string&, gbwt::size_type, gbwt::size_type, gbwt::size_type)’:
gfa.cpp:243:119: error: no matching function for call to ‘std::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<gbwtgraph::SequenceSource> >::pair(gbwt::GBWT*, gbwtgraph::SequenceSource*&)’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:206:9: note: candidate: template<class ... _Args1, long unsigned int ..._Indexes1, class ... _Args2, long unsigned int ..._Indexes2> std::pair<_T1, _T2>::pair(std::tuple<_Args1 ...>&, std::tuple<_Args2 ...>&, std::_Index_tuple<_Indexes1 ...>, std::_Index_tuple<_Indexes2 ...>)
         pair(tuple<_Args1...>&, tuple<_Args2...>&,
         ^
/usr/include/c++/5/bits/stl_pair.h:206:9: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   mismatched types ‘std::tuple<_Elements ...>’ and ‘gbwt::GBWT*’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:155:9: note: candidate: template<class ... _Args1, class ... _Args2> std::pair<_T1, _T2>::pair(std::piecewise_construct_t, std::tuple<_Args1 ...>, std::tuple<_Args2 ...>)
         pair(piecewise_construct_t, tuple<_Args1...>, tuple<_Args2...>);
         ^
/usr/include/c++/5/bits/stl_pair.h:155:9: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   cannot convert ‘(operator new(1464ul), (<statement>, ((gbwt::GBWT*)<anonymous>)))’ (type ‘gbwt::GBWT*’) to type ‘std::piecewise_construct_t’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:150:12: note: candidate: template<class _U1, class _U2, class> constexpr std::pair<_T1, _T2>::pair(std::pair<_U1, _U2>&&)
  constexpr pair(pair<_U1, _U2>&& __p)
            ^
/usr/include/c++/5/bits/stl_pair.h:150:12: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   mismatched types ‘std::pair<_T1, _T2>’ and ‘gbwt::GBWT*’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:144:12: note: candidate: template<class _U1, class _U2, class> constexpr std::pair<_T1, _T2>::pair(_U1&&, _U2&&)
  constexpr pair(_U1&& __x, _U2&& __y)
            ^
/usr/include/c++/5/bits/stl_pair.h:144:12: note:   template argument deduction/substitution failed:
/usr/include/c++/5/bits/stl_pair.h:141:38: error: no type named ‘type’ in ‘struct std::enable_if<false, void>’
       template<class _U1, class _U2, class = typename
                                      ^
/usr/include/c++/5/bits/stl_pair.h:138:12: note: candidate: template<class _U2, class> constexpr std::pair<_T1, _T2>::pair(const _T1&, _U2&&)
  constexpr pair(const _T1& __x, _U2&& __y)
            ^
/usr/include/c++/5/bits/stl_pair.h:138:12: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   cannot convert ‘(operator new(1464ul), (<statement>, ((gbwt::GBWT*)<anonymous>)))’ (type ‘gbwt::GBWT*’) to type ‘const std::unique_ptr<gbwt::GBWT>&’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:133:12: note: candidate: template<class _U1, class> constexpr std::pair<_T1, _T2>::pair(_U1&&, const _T2&)
  constexpr pair(_U1&& __x, const _T2& __y)
            ^
/usr/include/c++/5/bits/stl_pair.h:133:12: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   cannot convert ‘source’ (type ‘gbwtgraph::SequenceSource*’) to type ‘const std::unique_ptr<gbwtgraph::SequenceSource>&’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:128:17: note: candidate: constexpr std::pair<_T1, _T2>::pair(std::pair<_T1, _T2>&&) [with _T1 = std::unique_ptr<gbwt::GBWT>; _T2 = std::unique_ptr<gbwtgraph::SequenceSource>]
       constexpr pair(pair&&) = default;
                 ^
/usr/include/c++/5/bits/stl_pair.h:128:17: note:   candidate expects 1 argument, 2 provided
/usr/include/c++/5/bits/stl_pair.h:124:12: note: candidate: template<class _U1, class _U2, class> constexpr std::pair<_T1, _T2>::pair(const std::pair<_U1, _U2>&)
  constexpr pair(const pair<_U1, _U2>& __p)
            ^
/usr/include/c++/5/bits/stl_pair.h:124:12: note:   template argument deduction/substitution failed:
gfa.cpp:243:119: note:   mismatched types ‘const std::pair<_T1, _T2>’ and ‘gbwt::GBWT*’
 td::pair<std::unique_ptr<gbwt::GBWT>, std::unique_ptr<SequenceSource>>(new gbwt::GBWT(builder.index), source);
                                                                                                             ^
In file included from /usr/include/c++/5/bits/stl_algobase.h:64:0,
                 from /usr/include/c++/5/memory:62,
                 from /data3/genome_graphs/vg/include/gbwtgraph/gfa.h:4,
                 from gfa.cpp:1:
/usr/include/c++/5/bits/stl_pair.h:112:26: note: candidate: constexpr std::pair<_T1, _T2>::pair(const _T1&, const _T2&) [with _T1 = std::unique_ptr<gbwt::GBWT>; _T2 = std::unique_ptr<gbwtgraph::SequenceSource>]
       _GLIBCXX_CONSTEXPR pair(const _T1& __a, const _T2& __b)
                          ^
/usr/include/c++/5/bits/stl_pair.h:112:26: note:   no known conversion for argument 1 from ‘gbwt::GBWT*’ to ‘const std::unique_ptr<gbwt::GBWT>&’
/usr/include/c++/5/bits/stl_pair.h:108:26: note: candidate: constexpr std::pair<_T1, _T2>::pair() [with _T1 = std::unique_ptr<gbwt::GBWT>; _T2 = std::unique_ptr<gbwtgraph::SequenceSource>]
       _GLIBCXX_CONSTEXPR pair()
                          ^
/usr/include/c++/5/bits/stl_pair.h:108:26: note:   candidate expects 0 arguments, 2 provided
Makefile:45: recipe for target 'gfa.o' failed
make[1]: *** [gfa.o] Error 1
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/gbwtgraph'
Makefile:422: recipe for target 'lib/libgbwtgraph.a' failed
make: *** [lib/libgbwtgraph.a] Error 2
```

Again, I'm stuck at GBWTGraph. Time to figure out what the problem is here.

#### GBWTGraph

The error message is very long, but thanks to [this StackOverflow post](https://stackoverflow.com/questions/19912682/c-error-no-matching-function-for-call-to) I think I get the idea. It's looking to find a function that works the way it is intended to in gfa.cpp in multiple other files, and it finds a number of candidates, but can get none of them to work.

So far so good. If I had written that script, I would check what I did wrong. I haven't, though, and I know people have build vg successfully, so an error in the code can't really be the cause of the problem, can it?

Hmm, there was a [different problem](https://github.com/vgteam/vg/issues/2434) with GBWTGraph about a month ago, so maybe it is something in the code. The proposed solution is this:

```bash
cd deps/gbwtgraph/
git pull origin master
```

```
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (1/1), done.
remote: Total 3 (delta 2), reused 3 (delta 2), pack-reused 0
Unpacking objects: 100% (3/3), done.
From https://github.com/jltsiren/gbwtgraph
 * branch            master     -> FETCH_HEAD
   0eaaebc..acf690d  master     -> origin/master
Updating 52a46c8..acf690d
Fast-forward
 .gitignore                    |  15 ++++-
 CMakeLists.txt                | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 gfa.cpp                       |   5 +-
 include/gbwtgraph/minimizer.h |  25 ++++++---
 4 files changed, 255 insertions(+), 11 deletions(-)
 create mode 100644 CMakeLists.txt
```

It definitely updated something...

```bash
cd ../../
make
```

```
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
  CMake 3.9 or higher is required.  You are running version 3.5.1


-- Configuring incomplete, errors occurred!
Makefile:447: recipe for target 'lib/libvgio.a' failed
make: *** [lib/libvgio.a] Error 1

```

This ran for quite some time, but now I'm stuck with the wrong CMake version. That should be easy to fix.

#### CMake

```bash
sudo apt-get install cmake
```

```
Reading package lists... Done
Building dependency tree
Reading state information... Done
cmake is already the newest version (3.5.1-1ubuntu3).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

OK, [here's](https://stackoverflow.com/questions/49859457/how-to-reinstall-the-latest-cmake-version) an approach to make apt-get work with the latest CMake version:

```bash
pip3 uninstall cmake
exit
sudo apt-get update
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
sudo apt-get update
sudo apt-get install cmake
```

Let's see what happens now with CMake version 3.15.3.

```bash
make
```

This ends in:

```
/usr/bin/g++   -I/data3/genome_graphs/vg/deps/libvgio/include -I/data3/genome_graphs/vg/deps/libvgio -I/data3/genome_graphs/vg/include/. -I/usr/include/. -I/data3/genome_graphs/vg/deps/libvgio/src  -O3 -g   -std=gnu++14 -o CMakeFiles/vgio_static.dir/vg.pb.cc.o -c /data3/genome_graphs/vg/deps/libvgio/vg.pb.cc
In file included from /data3/genome_graphs/vg/deps/libvgio/vg.pb.cc:4:0:
/data3/genome_graphs/vg/deps/libvgio/vg.pb.h:10:40: fatal error: google/protobuf/port_def.inc: No such file or directory
compilation terminated.
CMakeFiles/vgio_static.dir/build.make:70: recipe for target 'CMakeFiles/vgio_static.dir/vg.pb.cc.o' failed
make[3]: *** [CMakeFiles/vgio_static.dir/vg.pb.cc.o] Error 1
make[3]: Leaving directory '/data3/genome_graphs/vg/deps/libvgio'
CMakeFiles/Makefile2:106: recipe for target 'CMakeFiles/vgio_static.dir/all' failed
make[2]: *** [CMakeFiles/vgio_static.dir/all] Error 2
make[2]: Leaving directory '/data3/genome_graphs/vg/deps/libvgio'
Makefile:129: recipe for target 'all' failed
make[1]: *** [all] Error 2
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/libvgio'
Makefile:447: recipe for target 'lib/libvgio.a' failed
make: *** [lib/libvgio.a] Error 2
```

#### Protobuf3 (again)

Well, I know I have Protobuf3 "installed", but maybe [the approach](#protoc) I used wasn't enough? It certainly did not generate the file that is missing here ("google/protobuf/port_def.inc"). I'll try again, this time [builing it](https://askubuntu.com/questions/532701/how-can-i-install-protobuf-in-ubuntu-12-04) from a different file.

```bash
cd ~
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.9.2/protobuf-all-3.9.2.zip
unzip protobuf-all-3.9.2.zip
cd protobuf-3.9.2
./configure
make
make check
sudo make install
```

Final results of `make check`:

```
PASS: protobuf-test
PASS: protobuf-lazy-descriptor-test
PASS: protobuf-lite-test
PASS: google/protobuf/compiler/zip_output_unittest.sh
PASS: google/protobuf/io/gzip_stream_unittest.sh
PASS: protobuf-lite-arena-test
PASS: no-warning-test
============================================================================
Testsuite summary for Protocol Buffers 3.9.2
============================================================================
# TOTAL: 7
# PASS:  7
# SKIP:  0
# XFAIL: 0
# FAIL:  0
# XPASS: 0
# ERROR: 0
============================================================================
make[3]: Leaving directory '/home/spo12/protobuf-3.9.2/src'
make[2]: Leaving directory '/home/spo12/protobuf-3.9.2/src'
make[1]: Leaving directory '/home/spo12/protobuf-3.9.2/src'
```

Result of `protoc --version`:

```
protoc: error while loading shared libraries: libprotoc.so.20: cannot open shared object file: No such file or directory
```

Luckily, this is also included in the StackOverflow answer:

```bash
sudo updatedb
locate libprotoc.so.20
```

```
/home/spo12/protobuf-3.9.2/src/.libs/libprotoc.so.20
/home/spo12/protobuf-3.9.2/src/.libs/libprotoc.so.20.0.2
/home/spo12/protobuf-3.9.2/src/.libs/libprotoc.so.20.0.2T
/usr/local/lib/libprotoc.so.20
/usr/local/lib/libprotoc.so.20.0.2
```

```bash
vi ~/.bashrc
```

Add "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" here and source.

```bash
source ~/.bashrc
protoc --version
```

```
libprotoc 3.9.2
```

And on we go...

```bash
make
```

And this time it ends here:

```
Makefile:63: recipe for target 'obj/packed_path_position_overlays.o' failed
make[1]: *** [obj/packed_path_position_overlays.o] Error 1
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/libbdsg'
Makefile:618: recipe for target 'lib/libbdsg.a' failed
make: *** [lib/libbdsg.a] Error 2
```

#### libbdsg

I'll update this repo from GitHub and try again.

```bash
cd deps/libbdsg/
git pull origin master
cd ../../
make
```

Still the same error.  
Let's try compiling libbdsg directly.

```bash
cd deps/libbdsg/
make -j8
```

```
g++ -O3 -Werror=return-type -std=c++14 -ggdb -g -msse4.2 -Iinclude  -fopenmp -c src/packed_path_position_overlays.cpp -o obj/packed_path_position_overlays.o
g++ -O3 -Werror=return-type -std=c++14 -ggdb -g -msse4.2 -Iinclude  -fopenmp -c src/vectorizable_overlays.cpp -o obj/vectorizable_overlays.o
g++ -O3 -Werror=return-type -std=c++14 -ggdb -g -msse4.2 -Iinclude  -fopenmp -c src/split_strand_graph.cpp -o obj/split_strand_graph.o
g++ -O3 -Werror=return-type -std=c++14 -ggdb -g -msse4.2 -Iinclude  -fopenmp -c src/utility.cpp -o obj/utility.o
In file included from src/packed_path_position_overlays.cpp:1:0:
include/bdsg/packed_path_position_overlays.hpp:12:63: fatal error: handlegraph/mutable_path_deletable_handle_graph.hpp: No such file or directory
compilation terminated.
In file included from src/split_strand_graph.cpp:6:0:
include/bdsg/split_strand_graph.hpp:10:51: fatal error: handlegraph/expanding_overlay_graph.hpp: No such file or directory
compilation terminated.
Makefile:63: recipe for target 'obj/packed_path_position_overlays.o' failed
make: *** [obj/packed_path_position_overlays.o] Error 1
make: *** Waiting for unfinished jobs....
Makefile:69: recipe for target 'obj/split_strand_graph.o' failed
make: *** [obj/split_strand_graph.o] Error 1
In file included from src/vectorizable_overlays.cpp:1:0:
include/bdsg/vectorizable_overlays.hpp:15:32: fatal error: sdsl/bit_vectors.hpp: No such file or directory
compilation terminated.
Makefile:66: recipe for target 'obj/vectorizable_overlays.o' failed
make: *** [obj/vectorizable_overlays.o] Error 1
```

OK, the files that are "missing" are, in fact present in "vg/include/", so what can I do about that?

On the other hand, that was mentioned in the [issue](https://github.com/vgteam/vg/issues/2491) I already know, which was resolved like this:

```bash
cp deps/BBHash/BooPHF.h include/
make
```

This ends here (showing the short version of the error):

```
In file included from /usr/include/c++/5/mutex:35:0,
                 from src/jemalloc_cpp.cpp:1:
/usr/include/c++/5/bits/c++0x_warning.h:32:2: error: #error This file requires compiler and library support for the ISO C++ 2011 standard. This support must be enabled with the -std=c++11 or -std=gnu++11 compiler options.
 #error This file requires compiler and library support \
  ^
Makefile:412: recipe for target 'src/jemalloc_cpp.pic.o' failed
make[1]: *** [src/jemalloc_cpp.pic.o] Error 1
make[1]: Leaving directory '/data3/genome_graphs/vg/deps/jemalloc'
Makefile:377: recipe for target 'lib/libjemalloc.a' failed
make: *** [lib/libjemalloc.a] Error 2
```

#### jemalloc

There are a lot of warnings before that, but I think the important bit is the error about the compiler library.

```bash
cd deps/jemalloc/
make
```

I'll try updating the whole directory from the GitHub repo again.

```bash
git pull origin master
cd ../../
make
```

I... I think it's done. This didn't end in an error:

```
. ./source_me.sh && g++ -I/data3/genome_graphs/vg/include -I. -I/data3/genome_graphs/vg/src -I/data3/genome_graphs/vg/src/unittest -I/data3/genome_graphs/vg/src/subcommand -I/data3/genome_graphs/vg/include/dynamic -I/data3/genome_graphs/vg/include/sonLib -I/usr/local/include -I/usr/include/cairo -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng12 -O3 -Werror=return-type -std=c++14 -ggdb -g -MMD -MP  -fopenmp -msse4.2 -o bin/vg obj/main.o obj/unittest/packed_structs.o obj/unittest/constructor.o obj/unittest/gapless_extender.o obj/unittest/haplotypes.o obj/unittest/snarls.o obj/unittest/mapper.o obj/unittest/tree_subgraph.o obj/unittest/dijkstra.o obj/unittest/cluster.o obj/unittest/overlays.o obj/unittest/vcf_buffer.o obj/unittest/handle.o obj/unittest/mcmc_genotyper.o obj/unittest/mapping.o obj/unittest/banded_global_aligner.o obj/unittest/cactus.o obj/unittest/random_graph.o obj/unittest/convert_handle.o obj/unittest/min_distance.o obj/unittest/distributions.o obj/unittest/dagify.o obj/unittest/flow_sort_test.o obj/unittest/driver.o obj/unittest/pinned_alignment.o obj/unittest/phased_genome.o obj/unittest/xdrop_aligner.o obj/unittest/gfa.o obj/unittest/stream.o obj/unittest/minimizer_mapper.o obj/unittest/position.o obj/unittest/blocked_gzip_output_stream.o obj/unittest/mem.o obj/unittest/xg.o obj/unittest/packed_graph.o obj/unittest/multipath_mapper.o obj/unittest/multipath_alignment.o obj/unittest/vpkg.o obj/unittest/chunker.o obj/unittest/seed_clusterer.o obj/unittest/vg_algorithms.o obj/unittest/indexed_vg.o obj/unittest/readfilter.o obj/unittest/phase_unfolder.o obj/unittest/stream_index.o obj/unittest/hfile_cppstream.o obj/unittest/annotation.o obj/unittest/sampler.o obj/unittest/vg.o obj/unittest/source_sink_overlay.o obj/unittest/variant_adder.o obj/unittest/genotyper.o obj/unittest/alignment.o obj/unittest/genotypekit.o obj/unittest/multipath_alignment_graph.o obj/unittest/hash_graph.o obj/unittest/feature_set.o obj/unittest/path_component_index.o obj/unittest/aligner.o obj/unittest/genome_state.o obj/unittest/srpe_filter.o obj/unittest/blocked_gzip_input_stream.o obj/unittest/path_index.o obj/unittest/msa_converter.o obj/subcommand/mod_main.o obj/subcommand/mcmc_main.o obj/subcommand/circularize_main.o obj/subcommand/help_main.o obj/subcommand/annotate_main.o obj/subcommand/version_main.o obj/subcommand/translate_main.o obj/subcommand/index_main.o obj/subcommand/bugs_main.o obj/subcommand/sort_main.o obj/subcommand/test_main.o obj/subcommand/pack_main.o obj/subcommand/filter_main.o obj/subcommand/add_main.o obj/subcommand/augment_main.o obj/subcommand/gaffe_main.o obj/subcommand/surject_main.o obj/subcommand/call_main.o obj/subcommand/genotype_main.o obj/subcommand/stats_main.o obj/subcommand/gamcompare_main.o obj/subcommand/concat_main.o obj/subcommand/kmers_main.o obj/subcommand/paths_main.o obj/subcommand/snarls_main.o obj/subcommand/srpe_main.o obj/subcommand/map_main.o obj/subcommand/locify_main.o obj/subcommand/msga_main.o obj/subcommand/ids_main.o obj/subcommand/prune_main.o obj/subcommand/align_main.o obj/subcommand/simplify_main.o obj/subcommand/minimizer_main.o obj/subcommand/mpmap_main.o obj/subcommand/rna_main.o obj/subcommand/explode_main.o obj/subcommand/subcommand.o obj/subcommand/view_main.o obj/subcommand/trace_main.o obj/subcommand/inject_main.o obj/subcommand/dotplot_main.o obj/subcommand/find_main.o obj/subcommand/sift_main.o obj/subcommand/vectorize_main.o obj/subcommand/gamsort_main.o obj/subcommand/compare_main.o obj/subcommand/deconstruct_main.o obj/subcommand/benchmark_main.o obj/subcommand/join_main.o obj/subcommand/gbwt_main.o obj/subcommand/construct_main.o obj/subcommand/chunk_main.o obj/subcommand/sim_main.o obj/subcommand/validate_main.o obj/subcommand/viz_main.o obj/subcommand/crash_main.o obj/subcommand/cluster_main.o obj/subcommand/convert_main.o obj/subcommand/recalibrate_main.o  -lvg -L/data3/genome_graphs/vg/lib /data3/genome_graphs/vg/lib/libvgio.a -lvcflib -lgssw -lssw -lprotobuf -lsublinearLS /data3/genome_graphs/vg/lib/libhts.a /data3/genome_graphs/vg/lib/libdeflate.a -lpthread -ljansson -lncurses -lgcsa2 -lgbwtgraph -lgbwt -ldivsufsort -ldivsufsort64 -lvcfh -lraptor2 -lpinchesandcacti -l3edgeconnected -lsonlib -lfml -llz4 -lstructures -lvw -lboost_program_options -lallreduce -lbdsg -lxg -lsdsl -lhandlegraph -L/usr/local/lib -lcairo -lz -lgobject-2.0 -lffi -lglib-2.0 -pthread -lpcre -pthread -lpixman-1 -lfontconfig -lexpat -lfreetype -lexpat -lfreetype -lz -lpng12 -lz -lm -lpng12 -lz -lm -lxcb-shm -lxcb-render -lXrender -lXext -lX11 -lpthread -lxcb -lXau -lXdmcp -ljansson -latomic -Wl,-rpath,/data3/genome_graphs/vg/lib -rdynamic -ldwfl -ldw -ldwelf -lelf -lebl -ldl -llzma -lrocksdb -ljemalloc  -lpthread -lrt -lsnappy -lz -lbz2 -llz4 -lnuma
```

```bash
./bin/vg
```

```
vg: variation graph tool, version v1.19.0-30-g1ac878e "Tramutola"

usage: ./bin/vg <command> [options]

main mapping and calling pipeline:
  -- construct     graph construction
  -- index         index graphs or alignments for random access or mapping
  -- map           MEM-based read alignment
  -- augment       augment a graph from an alignment
  -- pack          convert alignments to a compact coverage index
  -- call          call or genotype VCF variants
  -- help          show all subcommands

For more commands, type `vg help`.
```

It *is* done!

<br/>

-----

<br/>

Back to [main page](/index.html).