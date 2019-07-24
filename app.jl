#!/usr/bin/julia

push!(LOAD_PATH, pwd())
using RequestMaker

println(RequestMaker.fetchIt())
