#lamp

lamp-install:
  pkg.installed:
    - pkgs:
      - mysql-server
      - apache2
      - libapache2-mod-php5
      - php5
      - php5-gd
      - php5-json
      - php5-mysql
      - php5-curl
      - php5-intl
      - php5-mcrypt
      - php5-imagick
      - php-config
      - php-pear
      - php5-apcu
      - php5-cli
      - php5-common
      - php5-dev
      - php5-memcached
      - php5-readline 