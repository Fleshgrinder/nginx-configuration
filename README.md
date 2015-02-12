# nginx configuration
Collection of nginx configuration templates for various use cases, mainly 
intended to run PHP web applications.

## Usage
Create a copy of `nginx.conf.dist` and customize it to your needs. You can keep 
the repository and pull as you need, your actual `nginx.conf` is always ignored, 
so are all files in the certificates and sites directories.

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
passphrase.

#### StartSSL Certificates
All StartSSL certificates you need are already included in this repository, if 
you need more or want to update them, go to: [startssl.com/certs](https://www.startssl.com/certs/)

## Weblinks
Other repositories of interest:

* [nginx-compile](https://github.com/Fleshgrinder/nginx-compile)
* [nginx-session-ticket-key-rotation](https://github.com/Fleshgrinder/nginx-session-ticket-key-rotation)
* [nginx-sysvinit-script](https://github.com/Fleshgrinder/nginx-sysvinit-script)
* [hpkp](https://github.com/Fleshgrinder/hpkp) (HTTP Public Key Pinning)

## TODO
* Create script to fetch StartSSL certificates.
* Create script to concatenate intermediate certificates with server certificates.

## License
> This is free and unencumbered software released into the public domain.
>
> For more information, please refer to <http://unlicense.org>
