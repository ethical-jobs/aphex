# Alpine linux, PHP, Nginx

A super fast, super slim, production hardened PHP-7 and Nginx docker image built on Alpine linux. Perfect for horizontally distributed PHP and `Laravel` applications run within a container cluster.

**Note** Installs [hirak/prestissimo](https://github.com/hirak/prestissimo) composer parallel install plugin. If you have issues with composer installs remove this plugin.

## Stack

* **PHP-7** (Latest PHP runtime)
	* mcrypt
	* mysqli
	* pdo_mysql
	* opcache
	* gd
	* pcntl
* **Nginx** (FastCGI web-server)
* **Composer** (PHP package manager)
* **supervisor** (process manager)
* **Tooling**
	* git
	* wget
	* bash

## Building 

To build this image from the Dockerfile use something like `docker build .`

## Logging PHP output

### Background: 

A docker container should have the command it runs ouput to stdout and stderr, so the container
runner (e.g. docker-compose / Kubernetes) can see this output and forward it to a logging system.

php-fpm has workers that cam emit to php://stdout and php://stderr. These are captured by 
php-fpm's master process and can be logged to a single error log file. However, there is no way
to send these to two separate files.

Additionally, a further file symlink would be needed to forward this output to /dev/stdout. But,
php-fpm does not run as a user with the privilege to create this symlink or write to the
file. Only root can write to /dev/stdout.

### Solution:

1. Have php workers write to a file in a known location, /var/www/storage/logs/stdout.log.
1. A process running as root tails this file and forwards it to /dev/stdout
1. Another process truncates this file occasionally to prevent it from filling up the file system