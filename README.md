
# HostARM

![Badge](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/hostarm.json)

HostARM is a local hosting of
- Ada Reference Manual 2012
- Ada Reference Manual 2022
- Annotated Ada Reference Manual 202Y (Draft 5)

HostARM focuses on user friendliness and more modern look of the manuals.

Benefits
- Search not dependant on external hosts
- Keypress navigation
- Shorter URL: Remove two levels of the URL and no html ending
- Optional stripping of navigation bars
- Alphabet navigation bar in index

## Installation

HostARM is distributed as an [Alire](https://alire.ada.dev) crate.

```sh
alr install hostarm
```

## Apache configuration

On Debian/Ubuntu put something like this into `/etc/apache2/sites-available/hostarm.conf`:

```text
<VirtualHost *:2778>
    ServerName localhost
    <Directory /var/www/html/>
        Options +ExecCGI +FollowSymLinks -SymLinksIfOwnerMatch
        AllowOverride None
        Require all granted
    </Directory>

    <Files "hostarm">
        SetHandler cgi-script
    </Files>

    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/hostarm
    RewriteRule ^/(.*)$ /hostarm/$1 [L]

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Put the HostARM configuration on the list of enabled sites:
`ln -s /etc/apache2/sites-available/hostarm.conf /etc/apache2/sites-enabled`

Make Apache listen to port 2778:
Add `Listen 2778` to `/etc/apache2/ports.conf`.

Make HostARM availabe as CGI program:
`ln -s /home/USER/.alire/bin/hostarm /var/www/html/`, with `USER` replaced.

Reload the new Apache configuration:
`systemclt reload apache2`
 
HostARM should now be accessible at
[/localhost:2778/](http://localhost:2778/home).


## FAQ: Why 2778?
2778 is decimal `16#Ada#`.


## Links

Alire [crate](https://alire.ada.dev/crates/hostarm).

[Project website](https://github.com/jquorning/hostarm).

## Screenshot

![Screenshot](https://repository-images.githubusercontent.com/963019187/b0e8a4ad-44b1-4a60-9282-ee6e2b1a91e4)
