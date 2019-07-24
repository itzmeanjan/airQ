#!/usr/bin/julia

module Objectify
    struct PM2_5
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct PM10
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct NO2
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct NH3
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct SO2
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct CO
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct OZONE
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    struct Record
        station::String
        city::String
        state::String
        country::String
        pm2_5::PM2_5
        pm10::PM10
        no2::NO2
        nh3::NH3
        so2::SO2
        co::CO
        ozone::OZONE
    end

    struct Records
        all::Array{Record}
    end

    struct FetchedData
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

    function buildObject(data::Array{Dict{String, Any}})::Records
        reduce(data, init = Array{Dict{String, Any}}[]) do acc, cur
            if isempty(acc)
                push!(acc, [cur])
            elseif any(elem -> any(inner -> isequal(inner["station"], cur["station"]), elem), acc)
                push!(filter(elem -> any(inner -> isequal(inner["station"], cur["station"]), elem), acc)[1], cur)
                acc
            else
                push!(acc, [cur])
            end
        end
        records::Records = Records()
    end

    function buildObject(data::Dict{String,Any})::FetchedData
        FetchedData(data["index_name"], data["created"], data["updated"], data["title"], data["desc"], Int16(data["count"]), parse(Int16, data["limit"]), Int16(data["total"]), parse(Int16, data["offset"]), buildObject(convert(Array{Dict{String, Any}}, data["records"])))
    end
end
