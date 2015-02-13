# nginx configuration
Collection of nginx configuration templates for various use cases, mainly 
intended to run PHP web applications.

## Install
```shell
sudo git clone https://github.com/Fleshgrinder/nginx-configuration /etc/nginx
sudo sh /etc/nginx/bin/nginx-conf sscert
sudo sh /etc/nginx/bin/nginx-conf server example.com
sudo sh /etc/nginx/bin/nginx-conf server example.com blog
sudo nginx -t
sudo service nginx start
```

## Usage
Create a copy of `nginx.conf.dist` and customize it to your needs. You can keep 
the repository and pull as you need, your actual `nginx.conf` is always ignored, 
so are all files in the certificates and sites directories.

### `nginx-conf`
The `nginx-conf` application in the `bin` directory provides you with a few 
handy features:

- `sscert` – Generate self-signed certificate and key for default server.
- `server` – Generate a boilerplate server configuration.
- `ocsp-file` – Generate OCSP DER file for nginx’s `ocsp_stapling_file` directive.
- `ocs-validate` – Validate OCSP stapling status of your server.

_More to come …_

### Sites
I propose the following directory structure for the sites directory:

```
./sites
  └─/example.com
    └─/www.conf
    └─/subdomain.conf
```

The `www` file always refers to the domain with the www and without it. So this
file always contains the `server_name example.com www.example.com` no matter 
what kind of redirection you choose.

A `subdomain.conf` file always contains the configuration for a single subdomain.

I decided to use this structure because it is optimal for shell completion. Want 
to know all available subdomains?

```shell
$ ls /etc/nginx/sites/ex
```

Just hit tab followed by enter at this point and there you go.

On a last note. There are no `sites-available` and `sites-enabled` diretories 
in my configuration because the configuration files are always provided by a 
project and the files within the sites directory are what you might know as the 
files within your `sites-enabled` directory. In essence this means that all 
directories within my `sites` directory are symbolic links to a configuration 
directory somewhere else within a project.

### Certificates
It is assumed that you are using the free certificates from [StartSSL](https://startssl.com/), 
simply because I use them. Since you need a separate certificate for each of your
subdomains, I propose and assume the following directory structure:

```
./certificates
  └─/example.com
    └─/www
      └─/pem
      └─/key
```

Where `pem` is the server’s certificate and `key` the private key without a
passphrase. Note how this structure matches the server configuration structure.

#### StartSSL Certificates
All StartSSL certificates you need are already included in this repository, if 
you need more or want to update them, go to: [startssl.com/certs](https://www.startssl.com/certs/)

## Weblinks
Other repositories of interest:

- [nginx-compile](https://github.com/Fleshgrinder/nginx-compile)
- [nginx-session-ticket-key-rotation](https://github.com/Fleshgrinder/nginx-session-ticket-key-rotation)
- [nginx-sysvinit-script](https://github.com/Fleshgrinder/nginx-sysvinit-script)
- [hpkp](https://github.com/Fleshgrinder/hpkp) (HTTP Public Key Pinning)

## TODO
- Create command to concatenate intermediate certificates with server certificate
  by reading from `STDIN` for easy pasting.

## License
> This is free and unencumbered software released into the public domain.
>
> For more information, please refer to <http://unlicense.org>
