# Drupal Container mit und ohne Tex

Als erstes müssen die Conatiner für solr, memcached ud mariadb gestartet werden.

```sh
$ docker run --name memcached --restart=always -d -m 64M memcached
```

```sh
$ docker run --name solr --restart=always -d -m 1024M elcom/solr
```

```sh
$ docker run --name shop --restart=always -d -m 1024M 
$ -p 14005:80 --volumes-from=shop_datastore 
$ --link solr:solr --link mariadb --link memcached:memcached elcom/drupal:drupal-7
```

```sh
$ docker run --name portal --restart=always -d -m 1024M 
$ -p 14007:80 --volumes-from=portal_datastore 
$ --link solr:solr --link mariadb --link memcached:memcached elcom/drupal:drupal-7-tex
```