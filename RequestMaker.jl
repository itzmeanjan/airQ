#!/usr/bin/julia

module RequestMaker
    import HTTP
    import StringEncodings
    import JSON
    push!(LOAD_PATH, pwd())
    import Config

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
        fetchIt(url::String)

    fetches near real time Air Quality Data from provided URL,
    which is them decoded and parsed properly so that it can be given
    proper custom datatype, which will help us in handling dataset easily

    In case of unexpected error(s), returns an empty Dict{String, Any}

    # Example
    ```julia-repl
    julia> fetchIt("target_url")
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

    function fetchAll()::Bool
        try
            progress::Dict{String, Int16} = Config.getProgress()
            if isempty(progress)
                throw("progress holder missing")
            else
                while true
                    fetchIt()
                end
            end
        catch
            false
        end
    end
end
