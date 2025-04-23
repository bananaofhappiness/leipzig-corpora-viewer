#!/bin/bash

# Config
MYSQL_USER=root
MYSQL_PASSWORD=1111
MYSQL_HOST=mysql
CONTAINER_NAME=leipzig-corpora-mysql

# Tables
file_types=(words sentences co_s co_n inv_w inv_so sources)

# Function to run MySQL without using password warning
run_mysql() {
    mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -p1111 --local-infile=1 "$@" 2>&1 \
    | grep -v "Using a password on the command line interface can be insecure"
}

# Check if MySQL container is running
echo "⏳ Waiting for MySQL to become available..."
until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  sleep 1
done

echo "✅ MySQL is available!"

# Init database with SQL file
for corpus_dir in ./corpora/*/; do
  db_name=$(basename "$corpus_dir")
  sql_file="${corpus_dir}${db_name}-import.sql"

  echo "📦 Working on: $db_name"

  # If not present, create one
  if [ ! -f "$sql_file" ]; then
    echo "🧪 SQL file not found, creating from reference..."
    cat > "$sql_file" <<EOF
CREATE DATABASE IF NOT EXISTS \`$db_name\`;
USE \`$db_name\`;

CREATE TABLE \`words\` (
  \`w_id\` int(10) unsigned NOT NULL AUTO_INCREMENT,
  \`word\` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  \`word_ci\` varchar(255) DEFAULT NULL,
  \`freq\` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (\`w_id\`),
  KEY \`word\` (\`word\`),
  KEY \`w_id\` (\`w_id\`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE \`sentences\` (
  \`s_id\` int(10) unsigned NOT NULL AUTO_INCREMENT,
  \`sentence\` text,
  KEY \`s_id\` (\`s_id\`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE \`co_s\` (
  \`w1_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`w2_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`freq\` int(8) unsigned DEFAULT NULL,
  \`sig\` float DEFAULT NULL,
  PRIMARY KEY (\`w1_id\`,\`w2_id\`),
  KEY \`w1_sig\` (\`w1_id\`,\`sig\`),
  KEY \`w2_sig\` (\`w2_id\`,\`sig\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE \`co_n\` (
  \`w1_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`w2_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`freq\` int(8) unsigned DEFAULT NULL,
  \`sig\` float DEFAULT NULL,
  PRIMARY KEY (\`w1_id\`,\`w2_id\`),
  KEY \`w1_sig\` (\`w1_id\`,\`sig\`),
  KEY \`w2_sig\` (\`w2_id\`,\`sig\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE \`inv_w\` (
  \`w_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`s_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`pos\` mediumint(2) unsigned NOT NULL DEFAULT '0',
  KEY \`w_id\` (\`w_id\`),
  KEY \`s_id\` (\`s_id\`),
  KEY \`w_s\` (\`w_id\`,\`s_id\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE \`inv_so\` (
  \`so_id\` int(10) unsigned NOT NULL DEFAULT '0',
  \`s_id\` int(10) unsigned NOT NULL DEFAULT '0',
  KEY \`s_id\` (\`s_id\`),
  KEY \`so_id\` (\`so_id\`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE \`sources\` (
  \`so_id\` int(10) unsigned NOT NULL AUTO_INCREMENT,
  \`source\` varchar(255) DEFAULT NULL,
  \`date\` date DEFAULT NULL,
  KEY \`so_id\` (\`so_id\`),
  KEY \`date\` (\`date\`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

ALTER TABLE \`words\` DISABLE KEYS;
ALTER TABLE \`sentences\` DISABLE KEYS;
ALTER TABLE \`co_s\` DISABLE KEYS;
ALTER TABLE \`co_n\` DISABLE KEYS;
ALTER TABLE \`inv_w\` DISABLE KEYS;
ALTER TABLE \`inv_so\` DISABLE KEYS;
ALTER TABLE \`sources\` DISABLE KEYS;

ALTER TABLE \`words\` ENABLE KEYS;
ALTER TABLE \`sentences\` ENABLE KEYS;
ALTER TABLE \`co_s\` ENABLE KEYS;
ALTER TABLE \`co_n\` ENABLE KEYS;
ALTER TABLE \`inv_w\` ENABLE KEYS;
ALTER TABLE \`inv_so\` ENABLE KEYS;
ALTER TABLE \`sources\` ENABLE KEYS;
EOF
  fi

  # Init database
  echo "🧱 Init $db_name from $sql_file"
  run_mysql < "$sql_file"

  # Load .txt to database
  for type in "${file_types[@]}"; do
    file_path="${corpus_dir}${db_name}-${type}.txt"
    if [ -f "$file_path" ]; then
      echo "📊 Loading $file_path in ${db_name}.${type}..."
      run_mysql -e "LOAD DATA LOCAL INFILE '/corpora/${db_name}/${db_name}-${type}.txt'
              INTO TABLE \`${db_name}\`.\`${type}\`
              FIELDS TERMINATED BY '\t'
              LINES TERMINATED BY '\n';"
    else
      echo "⚠️ $file_path not found"
    fi
  done

  # Delete directory
  echo "🗑️ Deleting $corpus_dir"
  rm -rf "$corpus_dir"

  echo "✅ $db_name is ready."
done

echo "🎉 All corpora are ready to use!"
