#!/usr/bin/julia

push!(LOAD_PATH, pwd())
import RequestMaker

println(RequestMaker.getURL())
