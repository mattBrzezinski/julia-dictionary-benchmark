# Comapre the differences between
# Dictionary
# LittleDict
# SymDict
# NamedTuples

# what are we going to test?
# insertion of a large amount of objects
# access of a large amount of objects
# deletion of a large amount of objects

# run tests 10,000 times
# average, median, min, max of type tested

using JSON
using OrderedCollections: LittleDict, OrderedDict
using ProgressMeter
using Random
using Statistics
using SymDict

TINY = 10
SMALL = 100
MEDIUM = 1000
LARGE = 10000
XLARGE = 100000
amounts = [TINY, SMALL, MEDIUM, LARGE]
iterations = 100

ud = Dict()
td = Dict{Symbol, String}()
sd = SymbolDict()
uld = LittleDict()
tld = LittleDict{Symbol, String}()

function insert_benchmark(dict::AbstractDict, amount::Integer)
    empty!(dict)

    return @timed for i = 1:amount
        dict[Symbol(randstring())] = randstring()
    end
end

function access_benchmark(dict::Union{AbstractDict, NamedTuple})
    return @timed for key in keys(dict)
        dict[key]
    end
end

function delete_benchmark(dict::AbstractDict)
    return @timed for key in keys(dict)
        delete!(dict, key)
    end
end

function benchmark(dict)
    benchmark = Dict()

    for amount in amounts
        results = Dict("insert"=>[], "access"=>[], "delete"=>[])

        @showprogress 1 "Computing $(typeof(dict))" for i in 1:iterations
            insert_result = insert_benchmark(dict, amount)
            access_result = access_benchmark(dict)
            delete_result = delete_benchmark(dict)

            push!(results["insert"], insert_result)
            push!(results["access"], access_result)
            push!(results["delete"], delete_result)
        end

        benchmark[amount] = results
    end

    return benchmark
end

function analyze_results(benchmarks::AbstractDict)
    function analyze(results)
        times = [result[2] for result in results]

        return Dict(
            "Minimum"=>minimum(times),
            "Maximum"=>maximum(times),
            "Mean"=>mean(times),
            "Median"=>median(times)
        )
    end

    analysis_result = Dict()

    for (amount, benchmark) in benchmarks
        analysis = Dict()

        analysis["insert"] = analyze(benchmark["insert"])
        analysis["access"] = analyze(benchmark["access"])
        analysis["delete"] = analyze(benchmark["delete"])

        analysis_result[amount] = analysis
    end

    return analysis_result
end

function write_analysis(analysis, file_name)
    result_path = joinpath(@__DIR__, "..", "$(file_name).json")

    open(result_path, "w") do f
        print(f, json(OrderedDict(analysis), 2))
    end
end

println("Benchmarking untyped dictionary")
ud_results = benchmark(ud)
ud_analysis = analyze_results(ud_results)
write_analysis(ud_analysis, "untyped_dictionary")

println("Benchmarking typed dictionary")
td_results = benchmark(td)
td_analysis = analyze_results(td_results)
write_analysis(td_analysis, "typed_dictionary")

println("Benchmarking symbol dictionary")
sd_results = benchmark(sd)
sd_analysis = analyze_results(sd_results)
write_analysis(sd_analysis, "symbol_dictionary")

println("Benchmarking untyped little dictionary")
uld_results = benchmark(uld)
uld_analysis = analyze_results(uld_results)
write_analysis(uld_analysis, "untyped_little_dictionary")

println("Benchmarking typed little dictionary")
tld_results = benchmark(tld)
tld_analysis = analyze_results(tld_results)
write_analysis(tld_analysis, "typed_little_dictionary")
