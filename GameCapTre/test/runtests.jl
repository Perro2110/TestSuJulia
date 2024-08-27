using GameCapTre
using Test

@testset "GameCapTre.jl" begin
    include("Vehicle.jl")
    include("FighterJets.jl")
    
    using .Vehicle
    using .FighterJets
    
    println("Vehicle and FighterJets modules loaded successfully.")
    
end
