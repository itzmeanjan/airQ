# airQ
A near real time Air Quality Indication Data Collection Service _( for India )_, made with :heart:

**Consider putting :star: to show love & support**

_Companion repo located at : [airQ-insight](https://github.com/itzmeanjan/airQ-insight), to power visualization_

## what does it do ?
- Air quality data collector, collected from **180+** ground monitoring stations _( spread across India )_
- Air quality indication is given by `minimum`, `maximum` & `average` presence of pollutants such as `PM2.5`, `PM10`, `CO`, `NH3`, `SO2`, `OZONE` etc., along with _timeStamp_
- Data refreshed _hourly_
- Unreliable _JSON_ dataset is fetched from `https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69?api_key=your-api-key&format=json&offset=0&limit=10`, which gives current hour's pollutantStat, from all monitoring station(s), spread over _India_, which is eventually objectified, cleaned, processed & restructured into proper format and pushed into _*.json_

## how did I automate it ?
- Well my plan was to automate this data collection service, so that it'll keep running in hourly fashion, and keep refreshing dataset
- And for that, I've used `systemd`, which will use a `systemd.timer` to trigger execution of main script `app.py` every hour i.e. after a delay of _1h_, counted from last execution of `app.py`, periodically
- For that we'll require to add two files, `*.service` & `*.timer` _( placed in `./systemd/` )_

### airQ.service
Well our service isn't supposed to run always, only when timer trigger asks it to run, it'll run. So in `[Unit]` section, it's declared it _Wants_, `airQ.timer`
```
[Unit]
Description=A near real-time Air Quality Data collection service
Wants=airQ.timer
```
Make sure you put absolute path of current working directory _( i.e. where this README is present in your FS )_, in `WorkingDirectory` field of `[Service]` unit declaration

~Well `ExecStart` is the command, to be executed when this serice unit is invoked by `airQ.timer`, so putting absolute path of both _Julia_ interpreter & _./app.jl_ is required~

Make sure you update `User` field, to reflect changes properly

If you just add a `Restart` field under `[Service]` unit & give it a value `always`, we can make this script running always, which is helpful for running Servers, but we'll trigger execution of script using `systemd.timer`, pretty much like `cron`, but much more used & supported in almost all linux distros
```
[Service]
User=anjan
WorkingDirectory=/absolute-path-to-current-working-directory/
ExecStart=/usr/bin/julia /absolute-path-to/airQ/app.jl
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
Description=A near real-time Air Quality Data collection service
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
### time to automate
So need to place files present `./systemd/*` into `/etc/systemd/system/`, so that `systemd` can find these service & timer easily.
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
Consider running your instance of `airQ` on Cloud, mine runs on `AWS LightSail`
## visualization
This service is supposed to only collect data & properly structure it, but visualization part is done at _[airQ-insight](https://github.com/itzmeanjan/airQ-insight)_

**Hoping it helps, :wink:**
