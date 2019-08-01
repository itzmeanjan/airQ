# airQ
A near real time Air Quality Indicator Data Collection Service, written in _Julia_ with :heart: - _Powered by systemd_

**Consider putting :star: to show love & support**

**Construction of Data API _( for you usage )_ is undergoing, coming soon ...** :wink:

_Companion repo located at : [airQ-insight](https://github.com/itzmeanjan/airQ-insight), to power visualization_

## what does it do ?
- One Air Quality Data collector, where data is collected from **180+** ground monitoring stations _( spread across India )_
- Air quality indication is given by `minimum`, `maximum` & `average` presence of pollutants such as `PM2.5`, `PM10`, `CO`, `NH3`, `SO2`, `OZONE` etc., along with _timeStamp_
- Data Set is refreshed in _hourly_ fashion
- And of course data collection is automated, using nothing but `systemd`
- Unreliable _JSON_ dataset is fetched from `https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69?api_key=your-api-key&format=json&offset=0&limit=10`, which gives current hour's pollutantStat, from all monitoring station(s), spread over _India_, which is eventually objectified, cleaned, processed & restructured into `Objectify.FetchedData` data
- And finally exported to _JSON_ & stored in `./data/*.json`, which is to be used by `airQ-insight`, to get visual insight of _Air Quality_ at different places, all over India, for a timespan of past _24h_
- `airQ-insight`, will classify dataset by _monitoring station(s)_ & _pollutantId_ ( while storing airQ-data of last _24h_ timeperiod ), plots Graph to give nice visual representation of `airQ` at almost **180+** places & for each of them **7** different pollutantStat(s) are plotted, for last _24h_ timespan

## how does it work ?
Codebase is well documented, so you can simply go through it.

I've tried using functional constructs much more _( Julia is a function-first language )_, if you face any problem in understanding, try contacting me
### Finally Generated Dataset _( for a certain hour )_
```json
{
    "indexName": "3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69",
    "created": 1543320551,
    "updated": 1564635793,
    "title": "Real time Air Quality Index from various location",
    "description": "Real time Air Quality Index from various location",
    "count": 2,
    "limit": 10,
    "total": 1152,
    "offset": 1150,
    "records": {
        "all": [
            {
                "station": "Secretariat, Amaravati - APPCB",
                "city": "Amaravati",
                "state": "Andhra_Pradesh",
                "country": "India",
                "pollutants": [
                    {
                        "pollutantId": "PM2.5",
                        "pollutantUnit": "NA",
                        "pollutantMin": 7.0,
                        "pollutantMax": 39.0,
                        "pollutantAvg": 17.0
                    },
                    {
                        "pollutantId": "PM10",
                        "pollutantUnit": "NA",
                        "pollutantMin": 11.0,
                        "pollutantMax": 41.0,
                        "pollutantAvg": 25.0
                    },
                    {
                        "pollutantId": "NO2",
                        "pollutantUnit": "NA",
                        "pollutantMin": 2.0,
                        "pollutantMax": 14.0,
                        "pollutantAvg": 6.0
                    },
                    {
                        "pollutantId": "NH3",
                        "pollutantUnit": "NA",
                        "pollutantMin": 1.0,
                        "pollutantMax": 2.0,
                        "pollutantAvg": 1.0
                    },
                    {
                        "pollutantId": "SO2",
                        "pollutantUnit": "NA",
                        "pollutantMin": 3.0,
                        "pollutantMax": 33.0,
                        "pollutantAvg": 16.0
                    },
                    {
                        "pollutantId": "CO",
                        "pollutantUnit": "NA",
                        "pollutantMin": 4.0,
                        "pollutantMax": 38.0,
                        "pollutantAvg": 11.0
                    },
                    {
                        "pollutantId": "OZONE",
                        "pollutantUnit": "NA",
                        "pollutantMin": 10.0,
                        "pollutantMax": 34.0,
                        "pollutantAvg": 16.0
                    }
                ]
            },
            ...
        ]
    }
}
```
You may find some fields are having `0.0` _( were inconsistent dataset when received )_, to give them same form, I reduced them to `0.0`. If you want, you may ignore them while plotting.

## how did I automate it ?
- Well my plan was to automate this data collection service, so that it'll keep running in hourly fashion, and keep refreshing dataset
- And for that, I've used `systemd`, which will use a `systemd.timer` to trigger execution of main script `app.jl` every hour i.e. after a delay of _1h_, counted from last execution of `app.jl`, periodically
- For that we'll require to add two files, `*.service` & `*.timer` _( placed in `./systemd/` )_

### airQ.service
Well our service isn't supposed to run always, only when timer trigger asks it to run, it'll run. So in `[Unit]` section, it's declared it _Wants_, `airQ.timer`
```
[Unit]
Description=A near real-time Air Quality Data collection service
Wants=airQ.timer
```
Make sure you put absolute path of current working directory _( i.e. where this README is present in your FS )_, in `WorkingDirectory` field of `[Service]` unit declaration

Well `ExecStart` is the command, to be executed when this serice unit is invoked by `airQ.timer`, so putting absolute path of both _Julia_ interpreter & _./app.jl_ is required

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
