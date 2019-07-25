#!/usr/bin/julia

if !(pwd() in LOAD_PATH)
    push!(LOAD_PATH, pwd())
end
using RequestMaker

println(RequestMaker.fetchAll())
