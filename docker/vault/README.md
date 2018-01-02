# vault database backend example

boot vault and mariadb:
```
docker-compose up
```

vault boots with "vault server -dev" so no init/unseal needed, just grab the root token and:
```
export VAULT_ADDR='http://127.0.0.1:8200'
vault auth VAULT_ROOT_TOKEN
```

mount the database backend:
```bash
vault mount database
```

configure database credentials so vault can create users:
```bash
vault write database/config/mysql \
            plugin_name=mysql-database-plugin \
            connection_url="root:mysql@tcp(db:3306)/" \
            allowed_roles="db01"
```

configure a role:
```bash
vault write database/roles/db01 \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON db01.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
```

generate credentials:
```
vault read database/creds/db01
Key             Value
---             -----
lease_id        database/creds/db01/f6c8c932-de16-67f3-0aec-bd999ce0ceb5
lease_duration  1h0m0s
lease_renewable true
password        A1a-84t3z4tr5r345z33
username        v-root-db01-58v0wy0ys5vx8qy20ux8
```

the just created user is ready on mysql:
```mysql
MariaDB [(none)]> select user,host from mysql.user;
+----------------------------------+-----------+
| user                             | host      |
+----------------------------------+-----------+
| root                             | %         |
| v-root-db01-58v0wy0ys5vx8qy20ux8 | %         |
| root                             | localhost |
+----------------------------------+-----------+
3 rows in set (0.01 sec)
```




