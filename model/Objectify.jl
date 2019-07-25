#!/usr/bin/julia

__precompile__(false)
module Objectify
    struct Pollutant
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    mutable struct Record
        station::String
        city::String
        state::String
        country::String
        pollutants::Array{Pollutant}
    end

    mutable struct Records
        all::Array{Record}
    end

    mutable struct FetchedData
        indexName::String
        created::Int32
        updated::Int32
        title::String
        description::String
        count::Int16
        limit::Int16
        total::Int16
        offset::Int16
        records::Records
    end

    function mergeObject(mainObject::FetchedData, auxiliaryObject::FetchedData)::FetchedData
        reduce(auxiliaryObject.records.all, init = mainObject.records.all) do acc, cur
            matches = filter(acc) do it
                isequal(it.station, cur.station) && isequal(it.city, cur.city) && isequal(it.state, cur.state)
            end
            if !isempty(matches)
                reduce(cur.pollutants, init = matches[1].pollutants) do accInner, curInner
                    if any(elem -> isequal(curInner.pollutantId, elem.pollutantId), accInner)
                        push!(accInner, curInner)
                        accInner
                    else
                        accInner
                    end
                end
                acc
            else
                acc
            end
        end
        mainObject.total = auxiliaryObject.total
        mainObject.offset = auxiliaryObject.offset
        mainObject.count = auxiliaryObject.count
        mainObject
    end

    function buildObject(data::Array{Dict{String, Any}})::Records
        map(reduce(data, init = Array{Dict{String, Any}}[]) do acc, cur
            if isempty(acc)
                push!(acc, [cur])
            elseif any(elem -> any(inner -> isequal(inner["station"], cur["station"]) && isequal(inner["city"], cur["city"]) && isequal(inner["state"], cur["state"]), elem), acc)
                push!(filter(elem -> any(inner -> isequal(inner["station"], cur["station"]), elem), acc)[1], cur)
                acc
            else
                push!(acc, [cur])
            end
        end) do it
            Record(it[1]["station"],it[1]["city"],it[1]["state"],it[1]["country"], map(it) do elem
                Pollutant(elem["pollutant_id"], elem["pollutant_unit"], try 
                    parse(Float32, elem["pollutant_min"])
                catch
                    .0f0
                end,
                try
                    parse(Float32, elem["pollutant_max"])
                catch
                    .0f0
                end,
                try 
                    parse(Float32, elem["pollutant_avg"])
                catch 
                    .0f0 
                end, elem["last_update"])
            end)
        end |> e -> Records(e)
    end

    function buildObject(data::Dict{String,Any})::FetchedData
        FetchedData(data["index_name"], data["created"], data["updated"], data["title"], data["desc"], Int16(data["count"]), parse(Int16, data["limit"]), Int16(data["total"]), parse(Int16, data["offset"]), buildObject(convert(Array{Dict{String, Any}}, data["records"])))
    end
end
