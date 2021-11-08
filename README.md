# Google Sheets output plugin for Embulk

Embulk output plugin to insert data into Google Sheets


## Overview
insert data into Google Sheets using [Google Sheets API v4](https://developers.google.com/sheets/api).


* **Plugin type**: output
* **Load all or nothing**: no
* **Resume supported**: no
* **Cleanup supported**: yes

## Configuration

|  name  |  type  | required? | default | description |
| ---- | ---- | ---- | ---- | ----|
|  spreadsheet_id  | string | required | |
|  auth_method  | string | required | json_keyfile | 'application_default' or 'json_keyfile'
|  credentials_file_path  | string | optional | nil | used when auth_method is 'json_keyfile'
|  range  | string | optional | 'Sheet1:A1' |
|  mode  | string | optional | 'REPLACE' | 'APPEND' or 'REPLACE'

## Example

```
out:
  type: google_sheets
  spreadsheet_id: {{ env.SPREADSHEET_ID }}
  credentials_file_path: /path/to/credential_file
  mode: REPLACE
```

## Build

```
$ rake
```
