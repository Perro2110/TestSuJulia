# Abstract type hierarchy
abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

# simple functions on abstract types
describe(a::Asset) = "Something valuable"
describe(e::Investment) = "Financial investment"
describe(e::Property) = "Physical property"

# function that just raise an error
"""
    location(p::Property) 

Returns the location of the property as a tuple of (latitude, longitude).
"""
location(p::Property) = error("Location is not defined in the concrete type")

# an empty function
"""
    location(p::Property) 

Returns the location of the property as a tuple of (latitude, longitude).
"""
function location(p::Property) end

# interaction function that works at the abstract type level
function walking_disance(p1::Property, p2::Property)
    loc1 = location(p1)
    loc2 = location(p2)
    return abs(loc1.x - loc2.x) + abs(loc1.y - loc2.y)
end

# Concrete types

# Abstract types from abstract_types.jl
abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

# Define immutable/composite types
struct Stock <: Equity
    symbol::String
    name::String
end

# Create an instance
stock = Stock("AAPL", "Apple, Inc.")

#= REPL
julia> stock = Stock("AAPL", "Apple, Inc.")
Stock("AAPL", "Apple, Inc.")
=#

# implementing the contract from abstract type
function describe(s::Stock)
    return s.symbol * "(" * s.name * ")"
end

# It's immutable!
#= REPL
julia> stock.name = "Apple LLC"
ERROR: setfield! immutable struct of type Stock cannot be changed
=#

# Create another type
# Note that types are specified here
struct BasketOfStocks
    stocks::Vector{Stock}
    reason::String
end

many_stocks = [
    Stock("AAPL", "Apple, Inc."),
    Stock("IBM", "IBM")
]

# Create a basket of stocks
basket = BasketOfStocks(many_stocks, "Anniversary gift for my wife")

#= REPL
julia> many_stocks = [
           Stock("AAPL", "Apple, Inc."),
           Stock("IBM", "IBM")
       ]
2-element Array{Stock,1}:
 Stock("AAPL", "Apple, Inc.")
 Stock("IBM", "IBM")         

julia> basket = BasketOfStocks(many_stocks, "Anniversary gift for my wife")
BasketOfStocks(Stock[Stock("AAPL", "Apple, Inc."), Stock("IBM", "IBM")], "Anniversary gift for my wife")

julia> pop!(basket.stocks)
Stock("IBM", "IBM")

julia> basket
BasketOfStocks(Stock[Stock("AAPL", "Apple, Inc.")], "Anniversary gift for my wife")
=#

# ----------------------------------------
# mutable structs

# NOTE: restart REPL so we can define Stock again

mutable struct Stock <: Equity
    symbol::String
    name::String
end

#= REPL
julia> stock = Stock("AAPL", "Apple, Inc.")
StockHolding("AAPL", "Apple, Inc.")

julia> stock.name = "Apple LLC"
Apple LLC

julia> stock
Stock("AAPL", "Apple LLC")
=#

# conversion examples

# lossy

#=
julia> convert(Float64, 1//3)
0.3333333333333333

julia> convert(Rational, convert(Float64, 1//3))
6004799503160661//18014398509481984
=#



#= REPL

------------------------------------------------------------------------------
Use case #1

julia> x = rand(3)
3-element Array{Float64,1}:
 0.7472603457673705 
 0.08245417518187859
 0.06299555866248618

julia> x[1] = 1
1

julia> x
3-element Array{Float64,1}:
 1.0 
 0.08245417518187859
 0.06299555866248618
 
------------------------------------------------------------------------------
Use case #2

julia> mutable struct Foo 
           x::Float64
       end

julia> foo = Foo(1.0)
Foo(1.0)

julia> foo.x = 2
2

julia> foo
Foo(2.0)

------------------------------------------------------------------------------
Use case #3

julia> struct Foo 
           x::Float64
           Foo(v) = new(v)
       end

julia> Foo(1)
Foo(1.0)

------------------------------------------------------------------------------
Use case #4

julia> function foo()
           local x::Float64
           x = 1
           println(x, " has type of ", typeof(x))
       end

julia> foo()
1.0 has type of Float64

------------------------------------------------------------------------------
Use case #5

julia> function foo()::Float64
           return 1
       end

julia> foo()
1.0

------------------------------------------------------------------------------
Use case #6

julia> ccall((:exp, "libc"), Float64, (Float64,), 2)
7.38905609893065

------------------------------------------------------------------------------

julia> subtypetree(AbstractFloat)
AbstractFloat
    BigFloat
    Float16
    Float32
    Float64

julia> twice(x::AbstractFloat) = 2x;

julia> twice(1.0)
2.0

julia> BigFloat("1.5e1234")
1.500000000000000000000000000000000000000000000000000000000000000000000000000007e+1234

------------------------------------------------------------------------------

julia> twice(2)
ERROR: MethodError: no method matching twice(::Int64)

------------------------------------------------------------------------------

julia> twice(x) = 2x
twice (generic function with 1 method)

julia> twice(1.0)
2.0

julia> twice(1)
2

------------------------------------------------------------------------------

julia> twice(x::Number) = 2x
twice (generic function with 1 method)

julia> twice(2.0)
4.0

julia> twice(2)
4

julia> twice(2//3)
4//3
=#

# Parametric type examples

abstract type Asset end
abstract type Investment <: Asset end
abstract type Equity <: Investment end

struct Stock <: Equity
    symbol::String
    name::String
end

struct StockHolding{T <: Real} 
    stock::Stock
    quantity::T
end

#= REPL

julia> stock = Stock("AAPL", "Apple, Inc.");

julia> holding = StockHolding(stock, 100)
StockHolding{Int64}(Stock("AAPL", "Apple, Inc."), 100)

julia> holding = StockHolding(stock, 100.00)
StockHolding{Float64}(Stock("AAPL", "Apple, Inc."), 100.0)

julia> holding = StockHolding(stock, 100 // 3)
StockHolding{Rational}(Stock("AAPL", "Apple, Inc."), 100//3)
=#

#------------------------------------------------------------------------------

struct StockHolding2{T <: Real, P <: AbstractFloat} 
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end

#= REPL
julia> holding = StockHolding2(stock, 100, 180.00, 18000.00)
StockHolding2{Int64,Float64}(Stock("AAPL", "Apple, Inc."), 100, 180.0, 18000.0)

julia> holding = StockHolding2(stock, 100, 180.00, 18000)
ERROR: MethodError: no method matching StockHolding2(::Stock, ::Int64, ::Float64, ::Int64)
Closest candidates are:
  StockHolding2(::Stock, ::T<:Real, ::P<:AbstractFloat, ::P<:AbstractFloat) where {T<:Real, P<:AbstractFloat} at REPL[77]:2
=#

#------------------------------------------------------------------------------

abstract type Holding{P} end

mutable struct StockHolding3{T, P} <: Holding{P}
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end

mutable struct CashHolding{P} <: Holding{P}
    currency::String
    amount::P
    marketvalue::P
end

#= REPL
julia> stock = Stock("AAPL", "Apple, Inc.");

julia> certificate_in_the_safe = StockHolding3(stock, 100, 180.00, 18000.00)
StockHolding3{Int64,Float64}(Stock("AAPL", "Apple, Inc."), 100, 180.0, 18000.0)

julia> StockHolding3{Int64,Float64} <: Holding{Float64}
true

julia> certificate_in_the_safe isa Holding{Float64}
true

julia> Holding{Float64} <: Holding
true

julia> Holding{Int} <: Holding
true
=#

# Type Operators

#------------------------------------------------------------------------------
# isa operator
#= REPL
julia> 1 isa Int
true

julia> 1 isa Float64
false

julia> 1 isa Real
true
=#

#------------------------------------------------------------------------------
# What's Int type's heritage?
#= REPL
julia> supertype(Int)
Signed

julia> supertype(Signed)
Integer

julia> supertype(Integer)
Real
=#

#------------------------------------------------------------------------------
# check if Int is a subtype of Real
#= REPL
julia> Int <: Real
true
=#

#------------------------------------------------------------------------------
# documentation
#= REPL
help?> isa
search: isa isascii isapprox isabspath isassigned isabstracttype disable_sigint isnan ispath isvalid ismarked istaskdone

  isa(x, type) -> Bool

  Determine whether x is of the given type. Can also be used as an infix operator, e.g. x isa type.

help?> <:
search: <:

  <:(T1, T2)

  Subtype operator: returns true if and only if all values of type T1 are also of type T2.
=#

# Union type example

using Dates: Date

# abstract types from previous section
abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

# concrete types

struct Stock <: Equity
    symbol::String
    name::String
end

# new hierarchy

abstract type Art end

struct Painting <: Art
    artist::String
    title::String
end

# union type

struct BasketOfThings
    things::Vector{Union{Painting,Stock}}
    reason::String
end

#= REPL
julia> stock = Stock("AAPL", "Apple, Inc.",)
Stock("AAPL", "Apple, Inc.")

julia> monalisa = Painting("Leonardo da Vinci", "Monalisa")
Painting("Leonardo da Vinci", "Monalisa")

julia> things = Union{Painting,Stock}[stock, monalisa]
2-element Array{Union{Painting, Stock},1}:
 Stock("AAPL", "Apple, Inc.")             
 Painting("Leonardo da Vinci", "Monalisa")

julia> present = BasketOfThings(things, "Anniversary gift for my wife")
BasketOfThings(Union{Painting, Stock}[Stock("AAPL", "Apple, Inc."), Painting("Leonardo da Vinci", "Monalisa")], "Anniversary gift for my wife")
=#

# easier to read :-)

const Thing = Union{Painting,Stock}

struct BasketOfThings
    thing::Vector{Thing}
    reason::String
end