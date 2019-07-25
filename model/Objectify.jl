#!/usr/bin/julia

__precompile__(false)

"""
    # Note
    
    Beware, this module uses a lot of functional programming notations ;)
"""
module Objectify
    """
        Pollutant(pollutantId::String, pollutantUnit::String, pollutantMin::Float32, pollutantMax::Float32, pollutantAvg::Float32, lastUpdate::String)
    
    A Pollutant data holder class, where we indentify a certain pollutant using its unique
    `pollutantId`

    This record will be kept for each place,
    for which we'll keep track of near real time pollution condition,
    in `Record.pollutants` field, as `Array{Pollutant}`

    At max 7 different `Pollutant`, can be stored ( to be identified using `pollutant_id` )
    
    """
    struct Pollutant
        pollutantId::String
        pollutantUnit::String
        pollutantMin::Float32
        pollutantMax::Float32
        pollutantAvg::Float32
        lastUpdate::String
    end

    """
        Record(station::String, city::String, state::String, country::String, pollutants::Array{Pollutant})

    Holds current pollution data for a certain place
    ( i.e. data fetched from a ground monitoring station in hourly basis )
    
    Place can be uniquely identified using a combination of `station`, `city` & `state`

    Well `country` field will always stay same, _India_

    Record of `pollutants` are kept using an `Array{Pollutant}`, holding at max 7 elements

    """
    mutable struct Record
        station::String
        city::String
        state::String
        country::String
        pollutants::Array{Pollutant}
    end

    """
        Records(all::Array{Record})

    Holds all records fetched, processed, merged & objectified,
    using an `Array` of `Record`(s)

    """
    mutable struct Records
        all::Array{Record}
    end

    """
        FetchedData()

    Holds record of all data fetched either in this iteration or
    all data ever fetched

    Main pollutant data, kept in `records` field

    You may be also interested in learning about `updated` field,
    which can be used to take decision regarding, whether or not to fetch
    records again ( for refershing dataset )
    """
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

    """
        mergeObject(mainObject::FetchedData, auxiliaryObject::FetchedData)

    As you may have already learnt, during multiple iteration(s) for fetching whole dataset,
    we may be placing some data of a certain monitoring station in one
    `FetchedData` object ( lets assume this is the main  one, which will survive ultimately `;)` ),
    and some remainging data in other `FetchedData` object ( well this is just created, result of this iteration ).

    So what we need to do, is to merge those two records up into main `FetchedData` object,
    which can be used for further iteration steps or other operation(s), we may be doing in future
    
    Well that's what is done here, merging of two different `FetchedData` object's, and returns merged one as result
    """
    function mergeObject(mainObject::FetchedData, auxiliaryObject::FetchedData)::FetchedData
        mainObject.records.all = reduce(auxiliaryObject.records.all, init = mainObject.records.all) do acc, cur
            if any(it -> isequal(it.station, cur.station) && isequal(it.city, cur.city) && isequal(it.state, cur.state), acc)
                reduce(cur.pollutants, init = filter(acc) do it
                                                isequal(it.station, cur.station) && isequal(it.city, cur.city) && isequal(it.state, cur.state)
                                            end[1].pollutants) do accInner, curInner
                    if !any(elem -> isequal(curInner.pollutantId, elem.pollutantId), accInner)
                        push!(accInner, curInner)
                        accInner
                    else
                        accInner
                    end
                end
                acc
            else
                push!(acc, cur)
                acc
            end
        end
        mainObject.total = auxiliaryObject.total
        mainObject.offset = auxiliaryObject.offset
        mainObject.count = auxiliaryObject.count
        mainObject
    end

    """
        buildObject(data::Array{Dict{String, Any}})

    Here we're much more interested in processing `records` field in received
    `Dict{String, Any}` dataset ( which was taken in another definition of this method )

    You may have already learnt, we can fetch 10 records in every iteration ( *at max* ),
    so we may have to go through multiple iterations for grabbing all pollutants record for a certain
    place. Then what we need to do is to classify all records for certain place in an `Array`,
    thus for every different monitoring station, a seperate `Array`, while another parent `Array`,
    holding them all

    Which is mainly done here and then we objectify then to an instance of `Records`,
    holding all place records fetched in this iteration
    """
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

    """
        buildObject(data::Dict{String,Any})

    In each iteration 10 records are fetched,
    and processed using `RequestMaker.fetchIt()` function,
    which eventually returns data in `Dict{String,Any}` form

    To objectify this data, so that it can be
    easily used for merging with future iteration dataSet(s),
    we'd like to use this method, which will return an instance of `FetchedData`,
    holding all data fetched in current iteration,
    which can be easily merged with another instance of `FetchedData` ( for classifying it & removing duplicacy ),
    using `mergeObject()` function

    # Example
    ```julia-repl
    julia> buildObject(RequestMaker.fetchIt())
    ```
    """
    function buildObject(data::Dict{String,Any})::FetchedData
        FetchedData(data["index_name"], data["created"], data["updated"], data["title"], data["desc"], Int16(data["count"]), parse(Int16, data["limit"]), Int16(data["total"]), parse(Int16, data["offset"]), buildObject(convert(Array{Dict{String, Any}}, data["records"])))
    end
end
