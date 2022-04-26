server {
    server_name    mywebsite.com www.mywebsite.com;
    root           /var/www/mywebsite/public;
    index          index.php index.html;

    if ($host = mywebsite.com) {
        return 301 https://www.mywebsite.com$request_uri;
    }
    location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ =404;
                try_files $uri $uri/ /index.php?$query_string;
        }
        location /blog {
                try_files $uri $uri/ /blog/index.php?$args;
        }
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        }
    gzip             on;
    gzip_comp_level  3;
    gzip_types       text/plain text/css application/javascript image/*;

    client_max_body_size 10m;

}
server {
    if ($host = www.mywebsite.com) {
        return 301 https://www.mywebsite.com$request_uri;
    } # managed by Certbot


    if ($host = mywebsite.com) {
        return 301 https://www.mywebsite.com$request_uri;
    } # managed by Certbot


    listen         80;
    listen         [::]:80;
    server_name    mywebsite.com www.mywebsite.com;
    return 404; # managed by Certbot
}
