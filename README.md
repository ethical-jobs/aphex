# Alpine Linux, PHP, Nginx

A super fast, super slim, production hardened PHP 7.3/7.4 and Nginx docker image built on Alpine Linux. 

Perfect for horizontally distributed PHP and `Laravel` applications run within a container cluster.

## Stack
* Alpine Linux
* **PHP 7.3/7.4 & PHP-FPM**
  * mysqli
  * pdo, pdo_mysql + pdo_sqlite
  * opcache
  * pcntl
  * bcmath
  * exif
  * mbstring
  * gd
  * xdebug-2.9 (_Not loaded_)
* **NGINX 1.16** (FastCGI web-server)
* **Composer 2** (PHP package manager)
  * `hirak/prestissimo` was previously globally installed, but is no longer required nor supported under Composer 2
* **Supervisor Daemon** (Process manager)
* **Tooling**
  * git
  * wget
  * bash

## Usage

This image should **not** be directly built, it a starting point for your own Dockerfile.

Your Dockerfile should `ADD ` an Nginx configuration file at the very least.

[Lightweight example Dockerfile](https://github.com/ethical-jobs/aphex/blob/main/example/Dockerfile) of running a brand new Laravel application

```bash
docker build -f example/Dockerfile .
```
 
### XDebug
XDebug is included with the image, but not enabled for the PHP runtime.
Lazily loading the xdebug module through command-line can be done via
 
```bash
php -d zend_extension=xdebug ...
```
 
## Logging Output
A docker container should have the command it runs output to stdout and stderr, so the container runner (e.g. docker-compose / Kubernetes) can see this output and forward it to a logging system.

### PHP
PHP-FPM has workers that can emit to php://stdout and php://stderr. These are captured by PHP-FPM's master process and can be logged to a single error log file. However, there is no way to send these to two separate files.

Additionally, a further file symlink would be needed to forward this output to /dev/stdout. But, PHP-FPM does not run as a user with the privilege to create this symlink or write to the file. Only root can write to /dev/stdout.

### Possible Solutions

1. Have php workers write to a file in a known location, /var/www/storage/logs/stdout.log.
2. A process running as root tails this file and forwards it to /dev/stdout
3. Another process truncates this file occasionally to prevent it from filling up the file system
