<VirtualHost _default_>
    DocumentRoot /opt/xhprof/xhprof_html

    {% if HTTP_AUTH_USER is defined %}
    <Directory "/opt/xhprof/xhprof_html">
        AuthName Restricted
        AuthType Basic
        AuthUserFile /etc/apache2/htpasswd
        Require valid-user
    </Directory>
    {% endif %}
</VirtualHost>
