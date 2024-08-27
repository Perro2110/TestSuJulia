module GameCapTre

#Space war game!

include("Vehicle.jl")
include("FighterJets.jl")

# Usa i moduli inclusi
using .Vehicle
using .FighterJets

# A thing is anything that exist in the universe.
# Concrete type of Thing should always have the following fields:
# 1. position
# 2. size
abstract type Thing end

# Functions that are applied for all Thing's
position(t::Thing) = t.position
size(t::Thing) = t.size
shape(t::Thing) = :unknown

mutable struct Position
    x::Int
    y::Int
end

struct Size
    width::Int
    height::Int
end

#Type of weapons
@enum Weapon Laser Missile

struct Widget
    name::String
    position::Position
    size::Size
end

# Spaceship
struct Spaceship <: Thing
    position::Position
    size::Size
    weapon::Weapon
end
shape(s::Spaceship) = :saucer

# Asteroid
struct Asteroid <: Thing
    s1position::Position
    size::Size
end

struct Rectangle
    top::Int
    left::Int
    bottom::Int
    right::Int
    # return two upper-left and lower-right points of the rectangle
    Rectangle(p::Position, s::Size) =
        new(p.y + s.height, p.x, p.y, p.x + s.width)
end

# check if the two rectangles (A & B) overlap
function overlap(A::Rectangle, B::Rectangle)
    return A.left < B.right && A.right > B.left &&
           A.top > B.bottom && A.bottom < B.top
end

function collide(A::Thing, B::Thing)
    println("Checking collision of thing vs. thing")
    rectA = Rectangle(position(A), size(A))
    rectB = Rectangle(position(B), size(B))
    return overlap(rectA, rectB)
end

function collide(A::Spaceship, B::Spaceship)
    println("Checking collision of spaceship vs. spaceship")
    return true # just a test
end

function collide(A::Asteroid, B::Thing)
    println("Checking collision of asteroid vs. thing")
    return true
end

function collide(A::Thing, B::Asteroid)
    println("Checking collision of thing vs. asteroid")
    return false
end

function collide(A::Asteroid, B::Asteroid)
    println("Checking collision of asteroid vs. asteroid")
    return true # just a test
end




# single-line functions
move_up!(widget, v) = widget.position.y -= v
move_down!(widget, v) = widget.position.y += v
move_left!(widget, v) = widget.position.x -= v
move_right!(widget, v) = widget.position.x += v

#=
# long version
function move_up!(widget, v)
    widget.position.y -= v
end
=#

# Define pretty print functions
Base.show(io::IO, p::Position) = print(io, "(", p.x, ",", p.y, ")")
Base.show(io::IO, s::Size) = print(io, s.width, " x ", s.height)
Base.show(io::IO, w::Widget) = print(io, w.name, " at ", w.position, " size
", w.size)

# Make a bunch of asteroids
function make_asteroids(N::Int, pos_range=0:200, size_range=10:30)
    pos_rand() = rand(pos_range)
    sz_rand() = rand(size_range)
    return [Widget("Asteroid #$i",
        Position(pos_rand(), pos_rand()),
        Size(sz_rand(), sz_rand()))
            for i in 1:N]
end

function make_asteroids2(N::Int; pos_range=0:200, size_range=10:30)
    pos_rand() = rand(pos_range)
    sz_rand() = rand(size_range)
    return [Widget("Asteroid #$i",
        Position(pos_rand(), pos_rand()),
        Size(sz_rand(), sz_rand()))
            for i in 1:N]
end

function make_asteroids3(; N::Int, pos_range=0:200, size_range=10:30)
    pos_rand() = rand(pos_range)
    sz_rand() = rand(size_range)
    return [Widget("Asteroid #$i",
        Position(pos_rand(), pos_rand()),
        Size(sz_rand(), sz_rand()))
            for i in 1:N]
end


# Shoot any number of targets
function shoot(from::Widget, targets::Widget...)
    println("Type of targets: ", typeof(targets), " ... ", targets)
    for target in targets
        println(from.name, " --> ", target.name)
    end
end

# Special arrangement before attacks
function triangular_formation!(s1::Widget, s2::Widget, s3::Widget)
    x_offset = 30
    y_offset = 50
    s2.position.x = s1.position.x - x_offset
    s3.position.x = s1.position.x + x_offset
    s2.position.y = s3.position.y = s1.position.y - y_offset
    (s1, s2, s3)
end

#=
function random_move()
    x = rand(1:4)
    if(x = 1)
        return move_up!
    if(x = 2)
        return move_right!
    if(x = 3)
        return move_left!
    if(x = 4)
        return move_down!
end
=#

function random_move()
    return rand([move_up!, move_down!, move_left!, move_right!])
end

function random_leap!(w::Widget, move_func::Function, distance::Int)
    move_func(w, distance)
    return w
end

function explode(x)
    println(x, " exploded!")
end

function clean_up_galaxy(asteroids)
    foreach(explode, asteroids)
end

# x -> println(x, " exploded!") // ANONIMUS FACTION!!!

function clean_up_galaxy2(asteroids)
    foreach(x -> println(x, " exploded!"), asteroids)
end

function clean_up_galaxy3(asteroids, spaceships)
    ep = x -> println(x, " exploded!")
    foreach(ep, asteroids)
    foreach(ep, spaceships)
end

# Random healthiness function for testing
healthy(spaceship) = rand(Bool)

function fire(f::Function, spaceship::Widget)
    if healthy(spaceship)
        f(spaceship)
    else
        println("Operation aborted as spaceship is not healthy")
    end
    return nothing
end

# randomly pick two things and check
function check_randomly(things)
    for i in 1:5
        two = rand(things, 2)
        collide(two...)
    end
end

# explode an array of objects
function explode(things::AbstractVector{Any})
    for t in things
        println("Exploding ", t)
    end
end

# explode an array of objects (parametric version)
function explode_parametric(things::AbstractVector{T}) where {T}
    for t in things
        println("Exploding ", t)
    end
end

# Same function with a more narrow type
function explode_subthings(things::AbstractVector{T}) where {T<:Thing}
    for t in things
        println("Exploding thing => ", t)
    end
end

# specifying abstract/concrete types in method signature
function tow(A::Spaceship, B::Thing)
    "tow 1"
end

# equivalent of parametric type
function tow2(A::Spaceship, B::T) where {T<:Thing}
    "tow 2"
end

function group_anything(A::Thing, B::Thing)
    println("Grouped ", A, " and ", B)
end

function group_same_things(A::T, B::T) where {T<:Thing}
    println("Grouped ", A, " and ", B)
end

eltype(things::AbstractVector{T}) where {T<:Thing} = T

end