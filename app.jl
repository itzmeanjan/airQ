#!/usr/bin/julia

if !(pwd() in LOAD_PATH)
    push!(LOAD_PATH, pwd())
end
import RequestMaker
import Objectify
import JSON
import StringEncodings

"""
    jsonify(fetchedData::Objectify.FetchedData)

Takes processed, cleaned up dataset,
holding near realtime pollutant records ( applicable for a certain hour ),
collected from monitoring station placed all over India,
and finally converts it into JSON string representation,
which is eventually written into a file `./data/updation_time_of_current_dataset.json`,
which can be loaded later on for deeper analysis purposes

On completion, returns true or false, depending upon status of operation
"""
function jsonify(fetchedData::Objectify.FetchedData, target_path::String = joinpath(pwd(), "data"))::Bool
    try
        if !isdir(target_path)
            mkdir(target_path)
        end
        open(joinpath(target_path, "$(fetchedData.updated).json"), "w") do fd
            write(fd, JSON.json(fetchedData, 4))
        end
        true
    catch
        false
    end
end

"""
    dejsonify(target_path::String)

This one is aimed to generate objectified form of any alerady fetched-cum-processed
dataset, ( stored in `./data` )

Will simply parse _JSON_ string and get `Dict{String, Any}`, which is to be
iterated over for finally generating an instance of _Objectify.FetchedData_,
which will hold all data collected for a certain time period,
from all monitoring stations, all over India
"""
function dejsonify(target_path::String)::Objectify.FetchedData
    if !isfile(target_path)
        throw("not a valid file path")
    end
    open(target_path, "r") do fd
        JSON.Parser.parse(StringEncodings.decode(read(fd), "UTF-8"))
    end |> data -> Objectify.FetchedData(data["indexName"], Int32(data["created"]), Int32(data["updated"]), data["title"], data["description"], Int16(data["count"]), Int16(data["limit"]), Int16(data["total"]), Int16(data["offset"]), Objectify.Records(map(data["records"]["all"]) do elem
        Objectify.Record(elem["station"], elem["city"], elem["state"], elem["country"], map(elem["pollutants"]) do innerElem
            Objectify.Pollutant(innerElem["pollutantId"], innerElem["pollutantUnit"], Float32(innerElem["pollutantMin"]), Float32(innerElem["pollutantMax"]), Float32(innerElem["pollutantAvg"]), innerElem["lastUpdate"])
        end)
    end))
end

"""
    historicalDataEliminator()

Currently I'm planning to only store last 24 hours historical dataset,
i.e. 24 JSON files, where each of them is designated using their `updation_time.json`

But after 24 hours we need to remove non required data files,
which can be accomplished using this function
"""
function historicalDataEliminator(target_path::String = joinpath(pwd(), "data"))
    try
        if !isdir(target_path)
            0
        else
            toBeEliminated::Array{String} = String[]
            for (root, dirs, files) in walkdir(target_path)
                append!(toBeEliminated, map(elem -> joinpath(root, elem) ,filter(files) do it
                    parse(Int32, split(it, ".")[1]) < (Int32(floor(time())) - (24 * 3600))
                end))
            end
            foreach(elem->rm(elem), toBeEliminated)
            1
        end
    catch
        -1
    end
end


try
    "following line tries remove not-required files from data directory i.e. which files aren't required to be sticking around, cause they are more than 24h old"
    historicalDataEliminator()
    if jsonify(RequestMaker.fetchAll())
        "success"
    else
        "failure"
    end |> e->println(e)
    """println(dejsonify(joinpath(pwd(), "data/1564059786.json")) |> elm -> JSON.json(elm, 4))"""
catch e
    println(e)
end
