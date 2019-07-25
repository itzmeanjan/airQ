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

try
    if jsonify(RequestMaker.fetchAll())
        "success"
    else
        "failure"
    end |> e -> println(e)
catch e
    println(e)
end
