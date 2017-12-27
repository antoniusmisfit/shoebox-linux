# Shoebox Linux Tips And Tricks

## Customizing your shell environment
By default, the shell environment is extremely basic. However, you may customize your environment by creating and editing a special file in your home directory called ".profile". To get you started, you can copy over the sample .profile provided in the /etc/skel directory:
```
cp /etc/skel/.profile ~/.profile
```
In it, you will find commands that set the primary command prompt and a few command aliases for convenience. You can then add commands for stuff like setting the console font, displaying the message of the day, and so on.
## Create Your Own Servers
Busybox includes several applet commands to run several types of servers. Two of the most commonly used server applets are httpd and ftpd. They are used to set up a very basic web server and file transfer protocol server, respectively. You can run them manually, or you can use rocketbox-service to run them as managed services. A popular setup would be to set up a web server and an FTP server targeting your web server's root directory, so you can use an FTP client to remotely manage your web server's content. Busybox includes the wget and ping applets for basic web server testing, and ftpget and ftpput for downloading and uploading files to an FTP server. Shoebox Linux also includes the links web browser for general text-based web browsing and can be used to locally test your own web server.
* Tip: Your local web server address will be "http://127.0.0.1/", not "localhost".

## Add Software To Shoebox Linux

There are currently two ways to add software to Shoebox Linux. The first way is to compile the software directly into the Shoebox Linux ISO image. This is how the links web browser was installed. However, the instructions required to compile certain software may vary, so please make sure to read all relevant documentation for the software to be added.

The second way is to use Busybox's dpkg or rpm applets to install software packages. However, since dpkg and RPM packages are really built for Debian and Red Hat/Fedora Linux and their derivatives, they may not work as intended.

A third way, which is being developed, is to create a package management system for Shoebox Linux. This will be possible when a C compiler has been built into Shoebox Linux.
