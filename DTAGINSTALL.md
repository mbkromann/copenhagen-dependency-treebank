# Installation of DTAG #

# Requirements #

The annotation program DTAG only runs on UNIX machines, and requires Perl, subversion, and the PostScript viewer GV.

# Download #

To download DTAG, you have to check out the source code with anonymous subversion as described in the [checkout](http://code.google.com/p/copenhagen-dependency-treebank/source/checkout) page.

# Installation #

## Ubuntu users ##

The easiest way to install DTAG is to install Ubuntu on your machine, and open a terminal window where you can execute the following commands, which will change to root user and download and install DTAG as well as all packages on which it depends:

> `sudo su`<br>
<blockquote><code>wget http://www.buch-kromann.dk/cdt/install-root.sh</code><br>
<code>sh install-root.sh</code></blockquote>

Follow the instructions on the screen. Enter a blank Google code name if you are not in the CDT project. Logout as root when finished, and execute:<br>
<br>
<blockquote><code>wget http://www.buch-kromann.dk/cdt/install.sh</code><br>
<code>sh install.sh</code></blockquote>

This will also download the entire CDT treebank. You can then run DTAG with the command:<br>
<br>
<blockquote><code>perl ~/cdt/dtag/dtag.pl</code></blockquote>

<h2>Other UNIX users (including Mac OS X users)</h2>

You will have to install Subversion (svn), Perl, and GV manually first, and then execute the commands in the scripts install-root.sh and install.sh manually, adapting the commands to your specific system. If you find out how to install DTAG on your system, I will include your installation instructions and scripts here if you send me a <a href='mailto:matthias@buch-kromann.dk'>mail</a>.<br>
<br>
<h2>Windows users</h2>

DTAG does not work on Windows, but you can run Ubuntu as a Windows application via VMWare and install DTAG under Ubuntu.