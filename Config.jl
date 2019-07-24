#!/usr/bin/julia

module Config
    import JSON

    """
        getConfig(target_file)

    reads a configuration file, located at `./config.json`,
    and returns _Dict{String, String}_, holding data.

    In case of any unexpected error(s), returns an _empty Dict{String, String}_

    # Example
    ```julia-repl
    julia> getConfig()
    Dict{String,String} with 3 entries:
    "api_key" => "your-api-key"
    "format"  => "json"
    "url"     => "https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69"

    ```
    """
    function getConfig(target_file::String = "./config.json")::Dict{String,String}
        try
            open(target_file, "r") do fd
                JSON.Parser.parse(fd)
            end
        catch
            Dict()
        end
    end

    """
        getProgress(target_file)

    reads progress holder JSON file, and returns Dict{String, String},
    which can be eventually used to generate URL, where to be queried

    Later on this progress holder file, will also be updated, which will be
    used in next iteration

    # Example
    ```julia-repl
    julia> getProgress()
    Dict{String,Int16} with 2 entries:
        "offset" => 0
        "limit"  => 10

    ```
    """
    function getProgress(target_file::String = "./progress.json")::Dict{String,Int16}
        try
            open(target_file, "r") do fd
                JSON.Parser.parse(fd)
            end
        catch
            Dict()
        end
    end

    """
        updateProgress(offset, limit, target_file)

    updates progress holder data file, so that in next iteration it can
    start from proper position

    # Example
    ```julia-repl
    julia> updateProcess(0)
    true

    ```
    """
    function updateProgress(offset::Int16, limit::Int16 = 10, target_file::String = "./progress.json")::Bool
        try
            open(target_file, "w") do fd
                write(fd, JSON.json(Dict{String,Int16}("limit" => limit, "offset" => offset), 4))
            end
            true
        catch
            false
        end
    end
end
