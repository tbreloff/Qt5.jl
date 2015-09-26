module Qt5

__precompile__(false)


using ImmutableArrays

typealias P2 Vector2{Float64}
typealias P3 Vector3{Float64}
typealias Point Union(P2,P3)

const ORIGIN = P3(0,0,0)

P2(p::P3) = P2(p[1], p[2])
P3(p::P2, z::Real) = P3(p[1], p[2], z)
P3(p::P2) = P3(p, 0.0)

include("core.jl")
# include("cppdefs.jl")
include("widgets.jl")


end # module

q = Qt5
