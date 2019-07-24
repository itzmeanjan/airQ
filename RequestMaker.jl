#!/usr/bin/julia

module RequestMaker
    import HTTP
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
            "$(data["url"])?api_key=$(data["api_key"])&format=$(data["format"])&offset=$(progress["offset"])&limit=$(progress["limit"])"
        end
    end
end
