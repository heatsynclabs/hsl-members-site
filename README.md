# New Heatsync Memeber website (draft)

## Overview

This work-in-progress will allow replacing some of the aging apps:

- [member site](https://github.com/heatsynclabs/Open-Source-Access-Control-Web-Interface) (Rails 3, Ruby 1.9)

## Structure

- `clients/`: Frontend
- `servers/`: Backend Go Code
  - `cmd`: Server entry points
  - `internal`: Internal Go libraries
    - `database/migrations`: Schema migration files
