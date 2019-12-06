# airQ
A near real time Air Quality Indication Data Collection Service _( for India )_, made with :heart:

**Consider putting :star: to show love & support**

_Companion repo located at : [airQ-insight](https://github.com/itzmeanjan/airQ-insight), to power visualization_

## what does it do ?
- Air quality data collector, collected from **180+** ground monitoring stations _( spread across India )_
- Unreliable _JSON_ dataset is fetched from [here](https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69?api_key=your-api-key&format=json&offset=0&limit=10), which gives current hour's pollutant statistics, from all monitoring station(s), spread across _India_, which are then objectified, cleaned, processed & restructured into proper format and pushed into _*.json_ file
- Air quality data, given by _minimum_, _maximum_ & _average_ presence of pollutants such as `PM2.5`, `PM10`, `CO`, `NH3`, `SO2`, `OZONE` & `NO2`, along with _timeStamp_, grouped under stations _( from where these were collected )_
- Automated data collection done using systemd _( hourly )_

## installation
**airQ** can easily be installed from PyPI using pip.
```shell script
$ pip install airQ --user # or may be use pip3
```
## usage
After installing **airQ**, run it using following command
```shell script
$ cd # currently at $HOME
$ airQ # improper invokation
airQ - Air Quality Data Collector

	$ airQ `sink-file-path_( *.json )_`

 For making modifications on airQ-collected data
 ( collected prior to this run ),
 pass that JSON path, while invoking airQ ;)

Bad Input
$ airQ ./data/data.json # proper invokation
```

## automation
- Well my plan was to automate this data collection service, so that it'll keep running in hourly fashion, and keep refreshing dataset
- And for that, I've used `systemd`, which will use a `systemd.timer` to trigger execution of **airQ** every hour i.e. after a delay of _1h_, counted from last execution of **airQ**, periodically
- For that we'll require to add two files, `*.service` & `*.timer` _( placed in `./systemd/` )_

### airQ.service
Well our service isn't supposed to run always, only when timer trigger asks it to run, it'll run. So in `[Unit]` section, it's declared it _Wants_, `airQ.timer`
```
[Unit]
Description=Air Quality Data collection service
Wants=airQ.timer
```
You need to set absolute path of current working directory in `WorkingDirectory` field of `[Service]` unit declaration

`ExecStart` is the command, to be executed when this service unit is invoked by `airQ.timer`, so absolute installation path of **airQ** and absolute sink path _( *.json )_ is required

Make sure you update `User` field, to reflect changes properly, as per your system.

If you just add a `Restart` field under `[Service]` unit & give it a value `always`, we can make this script running always, which is helpful for running Servers, but we'll trigger execution of script using `systemd.timer`, pretty much like `cron`, but much more used & supported in almost all linux based distros
```
[Service]
User=anjan
WorkingDirectory=/absolute-path-to-current-working-directory/
ExecStart=/absolute-path-to-airQ /home/user/data/data.json
```
This declaration, makes this service a required dependency for `multi-user.target`
```
[Install]
WantedBy=multi-user.target
```
### airQ.timer
Pretty much same as `airQ.service`, only _Requires_, `airQ.service` as one strong dependency, because that's the service which is to be run when this timer expires
```
[Unit]
Description=Air Quality Data collection service
Requires=airQ.service
```
_Unit_ field specifies which service file to execute when timer expires.
You can simply skip this field, if you have created a `./systemd/*.service` file of same name as `./systemd/*.timer`

As we're interested in running this service every **1h** _( relative to last execution of airQ.service )_, we've specified `OnUnitActiveSec` field to be `1h`
```
[Timer]
Unit=airQ.service
OnUnitActiveSec=1h
```
Makes it an dependency of `timers.target`, so that this timer can be installed
```
[Install]
WantedBy=timers.target
```
### automation in ACTION
Need to place files present `./systemd/*` into `/etc/systemd/system/`, so that `systemd` can find these service & timer easily.
```bash
$ sudo cp ./systemd/* /etc/systemd/system/
```
We need to reload `systemd` _daemon_, to let it explore newly added service & timer unit(s).
```bash
$ sudo systemctl daemon-reload
```
Lets enable our timer, which will ensure our timer will keep running even after system reboot
```bash
$ sudo systemctl enable airQ.timer
```
Time to start this timer
```bash
$ sudo systemctl start airQ.timer
```
So an immediate execution of our script to be done, and after completion of so, it'll again be executed _1h_ later, so that we get refreshed dataset.

Check status of this timer
```bash
$ sudo systemctl status airQ.timer
```
Check status of this service
```bash
$ sudo systemctl status airQ.service
```
Consider running your instance of `airQ` on Cloud, mine running on `AWS LightSail`
## visualization
This service is supposed to only collect data & properly structure it, but visualization part is done at _[airQ-insight](https://github.com/itzmeanjan/airQ-insight)_

**Hoping it helps** :wink:
