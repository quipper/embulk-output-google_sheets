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
|  credentials_file_path  | string | required | nil |
|  range  | string | optional | 'Sheet1:A1' |
|  mode  | string | optional | 'REPLACE' | 'APPEND' or 'REPLACE' |
|  header_line | bool | optional | true | true or false |

## Example

```
out:
  type: google_sheets
  spreadsheet_id: {{ env.SPREADSHEET_ID }}
  credentials_file_path: /path/to/credential_file
  mode: REPLACE
  header_line: true
```

## Build

```
$ rake
```
