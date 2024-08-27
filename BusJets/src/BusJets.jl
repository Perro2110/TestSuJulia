module BusJets

export BusJet

mutable struct BusJet
    "power status: true = on, false = off"
    power::Bool

    "wheels status: true = on, false = off"
    wheels::Bool

    "current direction in radians"
    direction::Float64

    "current position coordinate (x,y)"
    position::Tuple{Float64,Float64}
end


# Import generic functions
import Vehicle: power_on!, power_off!, turn!, move!, position , engage_wheels!, has_wheels

# Implementation of Vehicle interface

function power_on!(bj::BusJet)
    bj.wheels = true
    bj.power = true
    println("Powered on: ", bj)
    println("wheel open...")
    nothing
end

function power_off!(bj::BusJet)
    bj.power = false
    println("wheel open...")
    println("Powered off: ", bj)
    nothing
end

function turn!(bj::BusJet, direction)
    bj.direction = direction
    println("Changed direction to ", direction, ": ", bj)
    nothing
end

function move!(bj::BusJet, distance)
    x, y = bj.position
    dx = round(distance * cos(bj.direction), digits=2)
    dy = round(distance * sin(bj.direction), digits=2)
    bj.position = (x + dx, y + dy)
    println("Moved (", dx, ",", dy, "): ", bj)
    nothing
end

function position(bj::BusJet)
    bj.position
end

function has_wheels(bj::BusJet)
    bj.wheels
end

function engage_wheels!(bj::BusJet)
    bj.wheels=false
    println("wheel lock")
    return true
end

end # module
