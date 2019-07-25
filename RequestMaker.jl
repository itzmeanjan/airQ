#!/usr/bin/julia

__precompile__(false)
module RequestMaker
    import HTTP
    import StringEncodings
    import JSON
    if !(pwd() in LOAD_PATH)
        push!(LOAD_PATH, pwd())
    end
    import Config
    if !(joinpath(pwd(), "model") in LOAD_PATH)
        push!(LOAD_PATH, joinpath(pwd(), "model"))
    end
    import Objectify

    """
        getURL()::String

    reads config file & progress holder file,
    gets data in form of `Dict{String, String}` & `Dict{String, Int16}`,
    which is finally encoded into a `String`, to be used as Query URL

    # Example
    ```julia-repl
    julia> getURL()
    "https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69?api_key=your-api-key&format=json&offset=0&limit=10"
    
    ```
    """
    function getURL()::String
        data::Dict{String,String} = Config.getConfig()
        progress::Dict{String,Int16} = Config.getProgress()
        if isempty(data) || isempty(progress)
            ""
        else
            "$(data["url"])?api-key=$(data["api_key"])&format=$(data["format"])&offset=$(progress["offset"])&limit=$(progress["limit"])"
        end
    end

    """
        fetchIt()

    fetches near real time Air Quality Data from provided URL,
    which is them decoded and parsed properly so that it can be given
    proper custom datatype, which will help us in handling dataset easily

    In case of unexpected error(s), returns an empty Dict{String, Any}

    # Example
    ```julia-repl
    julia> fetchIt()
    Dict{String,Any} with 24 entries:
        "active"        => "1"
        "created_date"  => "2018-11-27T17:39:11Z"
        "catalog_uuid"  => "a3e7afc6-b799-4ede-b143-8e074b27e0621"
        "index_name"    => "3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69"
        "target_bucket" => Dict{String,Any}("field"=>"3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69","type"=>"a3e7afc6-b799-4ede-b143-8e074b27e0621","index"=>"air_quality")
        "visualizable"  => "1"
        "status"        => "ok"
        "org_type"      => "Central"
        "created"       => 1543320551
        "field"         => Any[Dict{String,Any}("name"=>"id","id"=>"id","type"=>"double"), Dict{String,Any}("name"=>"country","id"=>"country","type"=>"keyword"), Dict{String,An…
        "count"         => 10
        "version"       => "2.1.0"
        "updated"       => 1563978787
        "records"       => Any[Dict{String,Any}("last_update"=>"24-07-2019 07:00:00","state"=>"Andhra_Pradesh","pollutant_unit"=>"NA","id"=>"1","pollutant_max"=>"NA","country"=…
        "total"         => 1135
        "offset"        => "0"
        "source"        => "data.gov.in"
        "message"       => "Resource detail"
        "sector"        => Any["Industrial Air Pollution"]
        "updated_date"  => "2019-07-24T20:03:07Z"
        "title"         => "Real time Air Quality Index from various location"
        "org"           => Any["Ministry of Environment and Forests", "Central Pollution Control Board"]
        "desc"          => "Real time Air Quality Index from various location"
        "limit"         => "10"

    ```
    """
    function fetchIt(url::String = getURL())::Dict{String,Any}
        try
            response::HTTP.Response = HTTP.get(url)
            if response.status != 200
                throw("bad status")
            else
                JSON.Parser.parse(StringEncodings.decode(response.body, "UTF-8"))
            end
        catch
            Dict()
        end
    end

    """
        fetchAll()

    iterates over all data, which can be fetched,
    which is detected using `total`, `offset` & `count` fields,
    present in dataset, and fetches all of those,
    then merges dataset with existing one,
    and objectified form is returned

    so that we can manipulate it easily

    returns an instance of `Objectify.FetchedData`, which holds all data,
    ( applicable for this hour )

    # Example
    ```julia-repl
    julia> fetchAll()
    Objectify.FetchedData("3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69", 1543320551, 1564040885, "Real time Air Quality Index from various location", "Real time Air Quality Index from various location", 4, 10, 1124, 1120, Objectify.Records(Objectify.Record[Record("Secretariat, Amaravati - APPCB", "Amaravati", "Andhra_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 14.0, 14.0, 14.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 21.0, 26.0, 24.0, "25-07-2019 12:00:00")]), Record("Anand Kala Kshetram, Rajamahendravaram - APPCB", "Rajamahendravaram", "Andhra_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 2.0, 47.0, 23.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 16.0, 48.0, 33.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 1.0, 43.0, 13.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 2.0, 7.0, 4.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 1.0, 7.0, 5.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 30.0, 72.0, 34.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 34.0, 63.0, 47.0, "25-07-2019 12:00:00")]), Record("Tirumala, Tirupati - APPCB", "Tirupati", "Andhra_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 2.0, 69.0, 23.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 9.0, 67.0, 29.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 13.0, 74.0, 36.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 4.0, 6.0, 5.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 1.0, 5.0, 2.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 10.0, 46.0, 19.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 6.0, 35.0, 22.0, "25-07-2019 12:00:00")]), Record("PWD Grounds, Vijayawada - APPCB", "Vijayawada", "Andhra_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 7.0, 42.0, 20.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 26.0, 65.0, 37.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 1.0, 2.0, 2.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 11.0, 12.0, 12.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 5.0, 30.0, 25.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 6.0, 7.0, 6.0, "25-07-2019 12:00:00")]), Record("GVM Corporation, Visakhapatnam - APPCB", "Visakhapatnam", "Andhra_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 5.0, 89.0, 43.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 40.0, 163.0, 92.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 11.0, 83.0, 40.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 2.0, 1.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 10.0, 95.0, 26.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 2.0, 29.0, 13.0, "25-07-2019 12:00:00")]), Record("Railway Colony, Guwahati - APCB", "Guwahati", "Assam", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 20.0, 80.0, 49.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 19.0, 96.0, 55.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 8.0, 39.0, 19.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 2.0, 2.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 13.0, 14.0, 13.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 14.0, 51.0, 31.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 11.0, 29.0, 19.0, "25-07-2019 12:00:00")]), Record("Collectorate, Gaya - BSPCB", "Gaya", "Bihar", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 2.0, 341.0, 138.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 43.0, 80.0, 63.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 8.0, 11.0, 10.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 1.0, 58.0, 8.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 8.0, 56.0, 32.0, "25-07-2019 12:00:00")]), Record("IGSC Planetarium Complex, Patna - BSPCB", "Patna", "Bihar", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 6.0, 120.0, 53.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 24.0, 65.0, 43.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 53.0, 75.0, 60.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 25.0, 51.0, 28.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 31.0, 95.0, 49.0, "25-07-2019 12:00:00")]), Record("Alipur, Delhi - DPCC", "Delhi", "Delhi", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 8.0, 177.0, 68.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 34.0, 167.0, 91.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 12.0, 38.0, 22.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 2.0, 74.0, 21.0, "25-07-2019 12:00:00")]), Record("Anand Vihar, Delhi - DPCC", "Delhi", "Delhi", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 10.0, 197.0, 66.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 27.0, 187.0, 109.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 23.0, 306.0, 103.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 3.0, 22.0, 12.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 1.0, 19.0, 8.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 22.0, 102.0, 44.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00")])  …  Record("Ardhali Bazar, Varanasi - UPPCB", "Varanasi", "Uttar_Pradesh", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 0.0, 0.0, 0.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 13.0, 98.0, 43.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 5.0, 47.0, 22.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 10.0, 87.0, 27.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 13.0, 100.0, 62.0, "25-07-2019 12:00:00")]), Record("Asansol Court Area, Asansol - WBPCB", "Asanol", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 23.0, 83.0, 37.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 22.0, 61.0, 32.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 25.0, 54.0, 37.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 2.0, 1.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 3.0, 10.0, 7.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 8.0, 93.0, 13.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 3.0, 13.0, 4.0, "25-07-2019 12:00:00")]), Record("Belur Math, Howrah - WBPCB", "Howrah", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 28.0, 88.0, 51.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 46.0, 85.0, 68.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 26.0, 83.0, 50.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 3.0, 8.0, 4.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 12.0, 68.0, 27.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 12.0, 34.0, 23.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 2.0, 98.0, 30.0, "25-07-2019 12:00:00")]), Record("Ghusuri, Howrah - WBPCB", "Howrah", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 35.0, 180.0, 71.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 73.0, 155.0, 102.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 16.0, 89.0, 49.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 3.0, 5.0, 4.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 1.0, 6.0, 4.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 14.0, 50.0, 30.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 13.0, 41.0, 21.0, "25-07-2019 12:00:00")]), Record("Padmapukur, Howrah - WBPCB", "Howrah", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 15.0, 51.0, 24.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 29.0, 47.0, 38.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 20.0, 43.0, 29.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 1.0, 1.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 5.0, 59.0, 17.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 8.0, 27.0, 10.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 20.0, 56.0, 40.0, "25-07-2019 12:00:00")]), Record("Fort William, Kolkata - WBPCB", "Kolkata", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 13.0, 65.0, 39.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 27.0, 83.0, 53.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 9.0, 72.0, 33.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 1.0, 1.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 3.0, 58.0, 15.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 7.0, 24.0, 14.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 3.0, 63.0, 27.0, "25-07-2019 12:00:00")]), Record("Jadavpur, Kolkata - WBPCB", "Kolkata", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 10.0, 44.0, 28.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 21.0, 43.0, 29.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 6.0, 33.0, 16.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 3.0, 5.0, 4.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 4.0, 23.0, 8.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 10.0, 26.0, 21.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 7.0, 35.0, 17.0, "25-07-2019 12:00:00")]), Record("Rabindra Bharati University, Kolkata - WBPCB", "Kolkata", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 40.0, 105.0, 56.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 47.0, 105.0, 72.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 27.0, 74.0, 46.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 2.0, 4.0, 2.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 4.0, 53.0, 10.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 6.0, 18.0, 15.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 11.0, 78.0, 32.0, "25-07-2019 12:00:00")]), Record("Victoria, Kolkata - WBPCB", "Kolkata", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 15.0, 53.0, 37.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 21.0, 54.0, 36.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 18.0, 63.0, 33.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 1.0, 1.0, 1.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 4.0, 36.0, 10.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 34.0, 57.0, 46.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 20.0, 87.0, 43.0, "25-07-2019 12:00:00")]), Record("Ward-32 Bapupara, Siliguri - WBPCB", "Siliguri", "West_Bengal", "India", Objectify.Pollutant[Pollutant("PM2.5", "NA", 14.0, 34.0, 22.0, "25-07-2019 12:00:00"), Pollutant("PM10", "NA", 12.0, 33.0, 22.0, "25-07-2019 12:00:00"), Pollutant("NO2", "NA", 12.0, 37.0, 20.0, "25-07-2019 12:00:00"), Pollutant("NH3", "NA", 2.0, 4.0, 3.0, "25-07-2019 12:00:00"), Pollutant("SO2", "NA", 3.0, 5.0, 4.0, "25-07-2019 12:00:00"), Pollutant("CO", "NA", 19.0, 70.0, 26.0, "25-07-2019 12:00:00"), Pollutant("OZONE", "NA", 12.0, 29.0, 19.0, "25-07-2019 12:00:00")])]))
    
    ```
    """
    function fetchAll()::Objectify.FetchedData
        progress::Dict{String, Int16} = Config.getProgress()
        if isempty(progress)
            throw("progress holder missing")
        else
            offset::Int16 = 0
            if !Config.updateProgress(offset)
                throw("failed to update progress")
            end
            mainObject::Objectify.FetchedData = Objectify.buildObject(fetchIt())
            offset = mainObject.offset + mainObject.count
            if !Config.updateProgress(offset)
                throw("failed to update progress")
            end
            while offset<mainObject.total
                mainObject = Objectify.mergeObject(mainObject, Objectify.buildObject(fetchIt()))
                offset = mainObject.offset + mainObject.count
                if !Config.updateProgress(offset)
                    throw("failed to update progress")
                end
            end
        end
        mainObject
    end
end
