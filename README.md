# bacula-server cookbook


## Description
The cookbook for installation bacula-director and bacula-storage. It uses chef searches, so you must have the chef server for use this cookbook. You should use cookbook bacula-client for adding client.

## Requirements
### Cookbooks
- [postgresql](https://supermarket.chef.io/cookbooks/postgresql)

### Platforms
The following platforms are supported and tested under test kitchen:

- CentOS 6

This cookbook tested with bacula version 5.0 and 5.2.

## Attributes
The attributes used in the recipes and in the templates.

|Attribute | Description | Type | Default|
|----------|-------------|------|--------|
|node['bacula']['director']['user']|The user under which the bacula-dir service is started|String|'bacula'|
|node['bacula']['director']['group']|The group under which the bacula-dir service is started|String|'bacula'|
|node['bacula']['director']['name']|The director's name, which used to identify between services.|String|'bacula-dir'|
|node['bacula']['director']['port']|The port on wich the director listens.|Integer|9101|
|node['bacula']['director']['maximum_concurrent_jobs']|Attribute show how many concurrent jobs may be run at the same time.|Integer|20|
|node['bacula']['director']['clients_role']|The role's name, which used to search clients.|String|'bacula-client'|
|node['bacula']['director']['storage_role']|The role's name, which used to search storage.|String|'bacula-storage'|
|node['bacula']['director']['working_directory']|Location for bacula working directory.|String|'/var/spool/bacula'|
|node['bacula']['director']['pid_directory']|Location for bacula pid directory.|String|'/var/run'|
|node['bacula']['storage']['volumes_dir']|Location where bacula keeps backups.|String|'/srv/bacula'|
|node['bacula']['storage']['user']|The user under which the bacula-sd service is started|String|'bacula'|
|node['bacula']['storage']['group']|The group under which the bacula-dir service is started|Stirng|'tape'|
|node['bacula']['databag_name']|Name of data bag where keeps bacula sensitive information. See below for format of data bag.|String |'bacula'|
|node['bacula']['databag_item']|Name of item of data bag.|String|'bacula'|
|node['bacula']['director_package']|Name of bacula director package.|String|'bacula-director-postgresql'|
|node['bacula']['storage_package']|Name of bacula storage package.|String|'bacula-storage-postgresql'|
|node['bacula']['full_backup_retention']|The time to store the full backup|String|'12 month'|
|node['bacula']['incremental_backup_retention']|The time to store the incremental backup.|String|'30 days'|
|node['bacula']['differential_backup_retention']|The time to store the differential backup.|String|'30 days'|
|node['bacula']['version']|Version of bacula packages. **It is important to know that Bacula does not work if packets from different branches. For example: bacula-dir version 5.0 does not work with bacula-sd version 5.2.**|String|will be installed the version that exists in your repository.|

## Recipes
- director.rb - install bacula-dir daemon. This daemon manages all processes of backup.
- storage.rb - install bacula-sd. This daemon manages the storage of backups.

## Usage

### How it works.
Bacula consists from three parts: director, storage and client. Director this is a server. It keeps all information about backups jobs, runs jobs and connects other parts. Storage server keeps volume files. Volume file is a binary file with a backup. And client makes a backup and transfers it to a storage.

Bacula director can't be started if the bacula storage and at least one client didn't configured. So you must provision at least one client and bacula storage before you will provision bacula director.

**To install client you must use bacula-client cookbook.**

## Data bags
Cookbook uses data bag name from attribute `node['bacula']['databag']` and item name from `node['bacula']['databag_item']`

Data bag example:

```
{
  "id": "bacula",
  "fd_password": "fd_password",
  "db_password": "bacula",
  "db_user": "bacula",
  "postgres_root_password": "postgres",
  "console_password": "console_password",
  "sd_password": "sd_password"
}
```

Authors
---
- Author:: Pavel Yudin (pyudin@parallels.com) 
