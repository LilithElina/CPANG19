---
output: 
  html_document: 
    toc: yes
---

## Installation of vg on our servers

According to [their GitHub](https://github.com/vgteam/vg), vg is best installed by downloading the static release build for Ubuntu/Mac OS, but I'm not sure how that works. We usually install software packages on our system with conda, which does not yet support vg (although there [have been tries](https://github.com/bioconda/bioconda-recipes/pull/5086) to include it in [BioConda](https://github.com/bioconda)). I will try to do it with pip instead, as described on [StackOverflow](https://stackoverflow.com/a/50141879).

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

Hmm, I hope that works... I'll [try first with Pandora](./installing_pandora.md), since that comes in a Singularity container and I don't have to check how using a Docker container within Singularity will work.

I had some problems with this conda installation of Singularity, so I removed it and instead used the official installation instructions (see [Pandora protocol](./installing_pandora.md)). Now everything should be working fine.


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

None of this appears when exiting the Pandora image, so I assume that Singularity did not manage to convert the Docker container properly. If I want the latest vg version, I think I'll just have to build from source and check out vg from time to time as mentioned in the CPANG19 toy examples (`git clone https://github.com/vgteam/vg.git`).

```bash
rm vg_v1.19.0.sif
```

## Building from source

I'll clone the vg repository into the /data3/genome_graph directory and work from there.

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

This gives a lot of output, I'M just pasting the - for me - most important here (from `make check`):

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

``make install`, on the other hand, returned this:

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

The source shell script runs fine it seems, but make won't complete and the bin/ directory is empty.
I'll try to clone [SDSL lite](https://github.com/simongog/sdsl-lite/tree/ddb0fbbc33bb183baa616f17eb48e261ac2a3672) from github and see if that helps.

```bash
cd deps/
git clone https://github.com/simongog/sdsl-lite.git
cd ../
make
```

This resulted in a lot of output, I think generated by building SDSL. It ended like this:

```
make: *** No rule to make target 'deps/ssw/src/*.c', needed by 'lib/libssw.a'.  Stop.
```

So it looks like I'm doing the very manual approach here.

```bash
cd deps/
git clone https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library
rm -r ssw/
mv Complete-Striped-Smith-Waterman-Library/ ssw/
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

[It looks like](https://stackoverflow.com/questions/36408943/how-do-i-compress-a-text-file-in-ubuntu-using-snappy) the right snappy installation using apt would be this:

```
sudo apt-get install libsnappy-dev
make
```

But I still get the same error when trying to build vg.

Thoughts: `make` calls the source_me.sh shell script, which works, then goes into the deps/snappy directory, which exists and contains files, but it then tries to run autogen.sh from that directory and that scripts does not exist. I assume that it has to be generated somehow, but since building snappy isn't working, I don't know how.
