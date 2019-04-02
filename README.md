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