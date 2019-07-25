#!/usr/bin/julia

if !(pwd() in LOAD_PATH)
    push!(LOAD_PATH, pwd())
end
import RequestMaker
import Objectify
import JSON

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
                append!(toBeEliminated, filter(files) do it
                    parse(Int32, split(it, ".")[1]) < (Int32(floor(time())) - (24 * 3600))
                end)
            end
            foreach(elem->rm(elem), toBeEliminated)
            1
        end
    catch
        -1
    end
end


try
    "following line tries remove not-required files from data directory"
    historicalDataEliminator()
    if jsonify(RequestMaker.fetchAll())
        "success"
    else
        "failure"
    end |> e->println(e)
catch e
    println(e)
end
