using JSON
using Printf
using OrderedCollections: OrderedDict

function load_data(path)
    return JSON.parsefile(path, dicttype=OrderedDict)
end

function get_median(data)
    medians = Dict()

    for (amount, results) in data
        medians[amount] = Dict(
            "insert"=>results["insert"]["Median"],
            "access"=>results["access"]["Median"],
            "delete"=>results["delete"]["Median"]
        )
    end

    return medians
end

sd_path = joinpath(@__DIR__, "..", "symbol_dictionary.json")
td_path = joinpath(@__DIR__, "..", "typed_dictionary.json")
ud_path = joinpath(@__DIR__, "..", "untyped_dictionary.json")
tld_path = joinpath(@__DIR__, "..", "typed_little_dictionary.json")
uld_path = joinpath(@__DIR__, "..", "untyped_little_dictionary.json")

sd_data = load_data(sd_path)
td_data = load_data(td_path)
ud_data = load_data(ud_path)
tld_data = load_data(tld_path)
uld_data = load_data(uld_path)

for (d, data) in get_median(uld_data)
    println(d)
    println(data["insert"])
    println(data["access"])
    println(data["delete"])
    println("\n")
end