# wordpress
Scripts and files to manage wordpress

So, this collections of notes is for my benefit. It is scattered as I have been working on scripts for a while, and mostly when I do this, I just need 
a few quick notes on how I manually did this when the automation I am using is not available.

At some point, I would like to clean it up because I always miss a step.

On my last iteration, I missed the php-curl packages which caused the connection to wordpress.org to fail. I thought it was a proxy setting, but, 
even after setting the proxy, it still failed, and it never told me that it did not know how to curl, just that it could not reach wordpress.org and I might 
have a config issue. 

apt install php-curl 
 
 Then I realized that I had all these in a separate file... and I just forgot to run them. So I need to add more comments about which pages 
 I need to pull from for which platform, and which items need to be run first, second third.
 
 The basic flow is:
 
 Install the OS (Ubuntu 18.04)
 Install nginx
 Verify nginx works
 Install mysql-server
 Configure mysql-server
 Configure the virtual host for the docs directory where WP will be installed.
 Install WP
 Configure wp-config.php
 Go to the website
 Finish the WP setup of the site.
 
 
Add any additional values to wp-config.php such as:
```
define('WP_PROXY_HOST', 'xx.xx.xx.xx');
define('WP_PROXY_PORT', '7070');
define('WP_PROXY_BYPASS_HOSTS', 'localhost', '*.mydomain.com');

/* uncomment when you need to troubleshoot. file is located in wp-content/debug.log 

define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );

Turn off Debugging when you don't have errors to resolve.

*/
```

