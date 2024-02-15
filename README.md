## How to use
bash <(curl -fsSL https://raw.githubusercontent.com/AlainLam/termux-toy/main/start.sh)

## Scripts about some toys for Termux

1. Modify max_phantom_processes to max value or rollback to default

2. Install X11 environment
   - Download and install Termux:X11
   - Donwload and install Termux:API
   - Download and install Termux:Widget

3. Connect to localhost using ADB or disconnect

4. Debian Helper
   - Create a new Debian with desktop environment
   - Install Code Server to your Debian
   - Install Android Studio to your Debian
   - Create a shortcuts for your Debian

## Project Structure

```
Termux-Toy
    │
    ├─.cache
    │      termux-toy.conf
    ├─.tmp
    │      termux-toy.log
    ├─${distro_name}
    │      inlet.sh
    ├─debian
    │      inlet.sh
    │      xxx.sh
    ├─host
    │      xxx.sh
    ├─share
    │      xxx.sh
    └─util
            title.sh
            util.sh
```

1. If the scripts in the `host` and `share` directories have a `title()` function and call `source title.sh`, they will generate a title. 

2. If a directory (except `host`,`share`,`util`) has an `inlet.sh` script with a `title()` function and calls `source title.sh`, it will generate a title.

3. In any case, it is recommended to include this code: `source "$SCRIPT_PATH/../util/util.sh"`.

4. The `termux-toy.conf` file in the `.cache` directory is used to store some record information. You can access it using `$CONFIGURATION_FILE`.

5. The `termux-toy.log` file in the `.tmp` directory stores operation records for debugging purposes. You can access it using `$LOG_FILE`.