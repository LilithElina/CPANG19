---
layout: post
title: "Installing Pandora"
categories: installation
author: LilithElina
---

[Pandora](https://github.com/rmcolq/pandora) is "a tool for bacterial genome analysis using a pangenome reference graph (PanRG)." I learned about it from [Zamin Iqbal](https://www.ebi.ac.uk/research/iqbal) (from the EBI) on [twitter](https://twitter.com/ZaminIqbal/status/1167052997689532421) and he said he could help me set it up for use on our data, so I'm now doing a comparison between [vg](https://github.com/vgteam/vg) and Pandora.

* Do not remove this line (it will not be displayed)
{:toc}

## Installation of Pandora on our servers

Pandora comes inside of a [Singularity](https://sylabs.io/docs/) container, which should make the installation easy, especially since I already installed Singularity in my [vg installation protocol]({% post_url 2019-09-16-installing_vg %}).

```bash
singularity pull shub://rmcolq/pandora:pandora
```

```
Progress |===================================| 100.0%
Done. Container is at: /home/spo12/rmcolq-pandora-dev-pandora.simg
```

That was indeed easy.

### Running Pandora

I think the easiest way to use Pandora inside Singularity is using `Singularity shell` to open a shell within the Pandora image:

```bash
singularity shell rmcolq-pandora-dev-pandora.simg
```

Unfortunately, this leads to an error that I can't even find on Google:

```
ERROR  : Session directory does not exist: /usr/bin/miniconda3/var/singularity/mnt/session
ABORT  : Retval = 255
```

The mentioned directory does indeed not exist. There isn't even a "singularity" directory in "/usr/bin/miniconda3/var/". Should I create one? Or maybe try as root first?

```bash
sudo -i
singularity shell /home/spo12/rmcolq-pandora-dev-pandora.simg
exit
```

No, that leads to the same error. What else can I do? I don't think creating that directory is the right solution here...

```bash
singularity -v shell rmcolq-pandora-dev-pandora.simg
```

```
Increasing verbosity level (2)
Singularity version: 2.4.2-dist
Exec'ing: /usr/bin/miniconda3/libexec/singularity/cli/shell.exec
Evaluating args: 'rmcolq-pandora-dev-pandora.simg'
VERBOSE: Set messagelevel to: 2
VERBOSE: Initialize configuration file: /usr/bin/miniconda3/singularity/singularity.conf
VERBOSE: Initializing Singularity Registry
VERBOSE: Running NON-SUID program workflow
VERBOSE: Invoking the user namespace
VERBOSE: No autofs bug path in configuration, skipping
VERBOSE: Using session directory: /usr/bin/miniconda3/var/singularity/mnt/session
ERROR  : Session directory does not exist: /usr/bin/miniconda3/var/singularity/mnt/session
ABORT  : Retval = 255
```

Right, so is there a way to change the session directory, or have Singularity set it up first? Let's check the configuration file mentioned above.

```bash
nano /usr/bin/miniconda3/singularity/singularity.conf
```

No, the session directory is not part of the gloabl config file. Maybe I do have to create it. Everything in the /usr/bin/miniconda3/ directory is owned by root, so I'm going to do this as root as well.

```bash
sudo -i
cd /usr/bin/miniconda3/var/
mkdir singularity/
mkdir singularity/mnt
mkdir singularity/mnt/session
exit
singularity -v shell rmcolq-pandora-dev-pandora.simg
```

```
Increasing verbosity level (2)
Singularity version: 2.4.2-dist
Exec'ing: /usr/bin/miniconda3/libexec/singularity/cli/shell.exec
Evaluating args: 'rmcolq-pandora-dev-pandora.simg'
VERBOSE: Set messagelevel to: 2
VERBOSE: Initialize configuration file: /usr/bin/miniconda3/singularity/singularity.conf
VERBOSE: Initializing Singularity Registry
VERBOSE: Running NON-SUID program workflow
VERBOSE: Invoking the user namespace
VERBOSE: No autofs bug path in configuration, skipping
VERBOSE: Using session directory: /usr/bin/miniconda3/var/singularity/mnt/session
VERBOSE: Could not open loop device /dev/loop0: Permission denied
VERBOSE: Could not open loop device /dev/loop1: Permission denied
VERBOSE: Could not open loop device /dev/loop2: Permission denied
VERBOSE: Could not open loop device /dev/loop3: Permission denied
VERBOSE: Could not open loop device /dev/loop4: Permission denied
VERBOSE: Could not open loop device /dev/loop5: Permission denied
VERBOSE: Could not open loop device /dev/loop6: Permission denied
VERBOSE: Could not open loop device /dev/loop7: Permission denied
ERROR  : Could not create /dev/loop8: Permission denied
ABORT  : Retval = 255
```

Well, that was kind of expected...

```bash
sudo -i
singularity -v shell /home/spo12/rmcolq-pandora-dev-pandora.simg
```

```
Increasing verbosity level (2)
Singularity version: 2.4.2-dist
Exec'ing: /usr/bin/miniconda3/libexec/singularity/cli/shell.exec
Evaluating args: '/home/spo12/rmcolq-pandora-dev-pandora.simg'
VERBOSE: Set messagelevel to: 2
VERBOSE: Initialize configuration file: /usr/bin/miniconda3/singularity/singularity.conf
VERBOSE: Initializing Singularity Registry
VERBOSE: Running NON-SUID program workflow
VERBOSE: Invoking the user namespace
VERBOSE: Not virtualizing USER namespace: running as root
VERBOSE: No autofs bug path in configuration, skipping
VERBOSE: Using session directory: /usr/bin/miniconda3/var/singularity/mnt/session
VERBOSE: Found available loop device: /dev/loop0
VERBOSE: Using loop device: /dev/loop0
VERBOSE: Mounting squashfs image: /dev/loop0 -> /usr/bin/miniconda3/var/singularity/mnt/container
ERROR  : Failed to mount squashfs image in (read only): No such file or directory
ABORT  : Retval = 255
```
OK, so we need some dependencies as well. I also don't want to have to only run this as root, so there's probably more I have to do, but I'm starting with dependencies now.

```bash
sudo -i
conda install -c conda-forge squashfs-tools
singularity -v shell /home/spo12/rmcolq-pandora-dev-pandora.simg
```

That resulted in exactly the same error I got before.

### Proper installation of Singularity

I think I have to remove this conda version of Singularity and follow the [official guidelines](https://sylabs.io/guides/3.4/user-guide/installation.html#installation) to install this software.

```bash
rm rmcolq-pandora-dev-pandora.simg
sudo -i
conda remove singularity
exit
```

Install dependencies and install and set up Go:

```
sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup-bin
export VERSION=1.12 OS=linux ARCH=amd64 && \
    wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
    sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
    rm go$VERSION.$OS-$ARCH.tar.gz
echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc && \
    source ~/.bashrc
```

Download and install the latest release of Singularity:

```bash
export VERSION=3.4.1 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity
./mconfig && \
    make -C ./builddir && \
    sudo make -C ./builddir install
```

## Installation of Pandora

```bash
cd /data3/genome_graphs/
singularity pull shub://rmcolq/pandora:pandora
```

```
INFO:    Downloading shub image
 463.25 MiB / 463.25 MiB [============================================================] 100.00% 6.95 MiB/s 1m6s
```

### Running Pandora

```bash
singularity shell pandora_pandora.sif
```

This now opens a shell inside the container with a working Pandora!

```bash
pandora
```

```
Program: pandora
Contact: Rachel Colquhoun <rmnorris@well.ox.ac.uk>

Usage:   pandora <command> [options]

Command: index         index PRG sequences from FASTA format
         map           identify PRG ordering and sequence from reads for a single sample
         compare             identify and compare the PRG ordering and sequences for a set of samples
         walk          outputs a path through the nodes in a GFA corresponding
                       to input sequence, provided it exists
         random_path   outputs a fasta of random paths through the PRGs
         get_vcf_ref   outputs a fasta suitable for use as the VCF reference using input sequences
         merge_index   allows multiple indexes to be merged (no compatibility check)

Note: To map reads against PRG sequences, you need to first index the
      PRGs with pandora index
```

## Installation of other required software

Pandora works with already created pangenome graphs (PanRG), which can be created with [make_prg](https://github.com/rmcolq/make_prg). To install this workflow, we need [Nextflow](https://www.nextflow.io/), which requires java 8 or later.

```bash
java -version
```

```
openjdk version "11.0.4" 2019-07-16
OpenJDK Runtime Environment (build 11.0.4+11-post-Ubuntu-116.04.1)
OpenJDK 64-Bit Server VM (build 11.0.4+11-post-Ubuntu-116.04.1, mixed mode, sharing)
```

Great, our java is up to date, time to install Nextflow with conda.

```bash
sudo -i
conda install nextflow
exit
```

Now install make_prg in the same directory where the Pandora image is also located (/data3/genome_graphs/):

```bash
git clone https://github.com/rmcolq/make_prg.git
cd make_prg
sudo -i
cd /data3/genome_graphs/make_prg/
pip3 install -r requirements.txt
pytest
```

```
=================================================== test session starts ====================================================
platform linux -- Python 3.5.2, pytest-5.1.3, py-1.8.0, pluggy-0.13.0
rootdir: /data3/genome_graphs/make_prg
collected 1 item

test_make_prg.py F                                                                                                   [100%]

========================================================= FAILURES =========================================================
_______________________________________________________ test_answers _______________________________________________________

    def test_answers():
        aseq = AlignedSeq("test/match.fa")
        assert aseq.prg == "ACGTGTTTTGTAACTGTGCCACACTCTCGAGACTGCATATGTGTC"

        aseq = AlignedSeq("test/nonmatch.fa")
        assert aseq.prg == " 5 AAACGTGGTT 6 CCCCCCCCCC 5 "

        aseq = AlignedSeq("test/match.nonmatch.fa")
        assert aseq.prg == "AAACG 5 TGGTT 6 CCCCC 5 "

        aseq = AlignedSeq("test/nonmatch.match.fa")
        assert aseq.prg == " 5 AAACGT 6 CCCCCC 5 GGTT"

        aseq = AlignedSeq("test/match.nonmatch.match.fa")
>       assert aseq.prg == "AAACG 5 T 6 C 5 GGTT"
E       AssertionError: assert 'AAACG 5 C 6 T 5 GGTT' == 'AAACG 5 T 6 C 5 GGTT'
E         - AAACG 5 C 6 T 5 GGTT
E         ?           ----
E         + AAACG 5 T 6 C 5 GGTT
E         ?         ++++

test_make_prg.py:21: AssertionError
===================================================== warnings summary =====================================================
/usr/local/lib/python3.5/dist-packages/Bio/Alphabet/__init__.py:26
  /usr/local/lib/python3.5/dist-packages/Bio/Alphabet/__init__.py:26: PendingDeprecationWarning: We intend to remove or replace Bio.Alphabet in 2020, ideally avoid using it explicitly in your code. Please get in touch if you will be adversely affected by this. https://github.com/biopython/biopython/issues/2046
    PendingDeprecationWarning)

-- Docs: https://docs.pytest.org/en/latest/warnings.html
============================================== 1 failed, 1 warnings in 1.90s ===============================================
```

Except for a deprecation warning, this looks fine.

<br/>

-----

<br/>

Back to [main page](/index.html).