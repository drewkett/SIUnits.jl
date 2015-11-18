isdefined(Base, :__precompile__) && __precompile__()

module SIUnits
    export quantity, @quantity
    export SIPrefix, Meter, KiloGram, Second, Ampere, Kelvin, Mole, Candela, Radian, Steradian, Kilo, Mega, Giga,
            Tera, Peta, Exa, Zetta, Centi, Milli, Micro, Nano, Pico, Femto, Atto, Zepto, Yocto,
            Gram, Joule, Coulomb, Volt, Farad, Newton, Ohm, CentiMeter, Siemens, Hertz, Watt, Pascal
    export @prettyshow
    export as

    import Base: show, promote_rule, convert, +, -, *, /, isless, ==, round

    typealias UnitTuple NTuple{9,Int64}
    abstract AbstractUnit{Tup}

    immutable SIUnit{Tup} <: AbstractUnit{Tup} end
    immutable NonSIUnit{UnitLabel,Tup} <: AbstractUnit{Tup} end

    immutable Quantity{N<:Number,Unit<:AbstractUnit}
        val::N
    end
    typealias SIQuantity{N} Quantity{N,SIUnit}

    const ConstantTuple = (0,0,0,0,0,0,0,0,0)
    typealias ConstantUnit AbstractUnit{ConstantTuple}

    macro quantity(x,y)
        :(Quantity{$x,typeof($y)})
    end
    quantity{N<:Number,U<:AbstractUnit}(x::Type{N},y::U) = Quantity{N,U}
    tup{T}(::SIUnit{T}) = T
    tup{T}(::Type{SIUnit{T}}) = T
    tup{L,T}(::NonSIUnit{L,T}) = T
    tup{L,T}(::Type{NonSIUnit{L,T}}) = T
    tup{N,T}(::Quantity{N,SIUnit{T}}) = T
    tup{N,T}(::Type{Quantity{N,SIUnit{T}}}) = T
    tup{N,L,T}(::Quantity{N,NonSIUnit{L,T}}) = T
    tup{N,L,T}(::Type{Quantity{N,NonSIUnit{L,T}}}) = T

    const MassTuple        = (1,0,0,0,0,0,0,0,0)
    const LengthTuple      = (0,1,0,0,0,0,0,0,0)
    const TimeTuple        = (0,0,1,0,0,0,0,0,0)
    const CurrentTuple     = (0,0,0,1,0,0,0,0,0)
    const TemperatureTuple = (0,0,0,0,1,0,0,0,0)
    const AmountTuple      = (0,0,0,0,0,1,0,0,0)
    const LuminosityTuple  = (0,0,0,0,0,0,1,0,0)
    const AngleTuple       = (0,0,0,0,0,0,0,1,0)
    const SolidAngleTuple  = (0,0,0,0,0,0,0,0,1)

    const TypeNames = (:kg,:m,:s,:A,:K,:mol,:can,:rad,:sr)
    const KiloGram  = SIUnit{MassTuple}()
    const Meter     = SIUnit{LengthTuple}()
    const Second    = SIUnit{TimeTuple}()
    const Ampere    = SIUnit{CurrentTuple}()
    const Kelvin    = SIUnit{TemperatureTuple}()
    const Mole      = SIUnit{AmountTuple}()
    const Candela   = SIUnit{LuminosityTuple}()
    const Radian    = SIUnit{AngleTuple}()
    const Steradian = SIUnit{SolidAngleTuple}()

    #Basic UnitTuple Operations
    +(xs::UnitTuple,ys::UnitTuple) = ([x+y for (x,y) in zip(xs,ys)]...)
    -(xs::UnitTuple,ys::UnitTuple) = ([x-y for (x,y) in zip(xs,ys)]...)
    -(xs::UnitTuple) = ([-x for x in xs]...)
    *(x::Integer,ys::UnitTuple) = ([x*y for y in ys]...)
    *(xs::UnitTuple,y::Integer) = ([x*y for x in xs]...)

    #Basic SIUnit Operations
    -{T}(x::SIUnit{T}) = SIUnit{-T}()
    -{T}(x::Type{SIUnit{T}}) = SIUnit{-T}
    *{T1,T2}(x::SIUnit{T1},y::SIUnit{T2}) = SIUnit{T1+T2}()
    /{T1,T2}(x::SIUnit{T1},y::SIUnit{T2}) = SIUnit{T1-T2}()

    typealias SILength{N} @quantity(N,Meter)
    typealias SIVelocity{N} @quantity(N,Meter/Second)
    typealias SIAcceleration{N} @quantity(N,Meter/Second^2)
    typealias SIForce{N} @quantity(N,KiloGram*Meter/Second^2)
    typealias SIPressure{N} @quantity(N,KiloGram/Second^2/Meter)
    typealias SIDensity{N} @quantity(N,KiloGram/Meter^3)
    typealias SITemperature{N} @quantity(N,Kelvin)

    # Quantity Operation
    +{N<:Number,U<:AbstractUnit}(x::Quantity{N,U},y::Quantity{N,U}) = Quantity{N,U}(x.val+y.val)
    -{N<:Number,U<:AbstractUnit}(x::Quantity{N,U},y::Quantity{N,U}) = Quantity{N,U}(x.val-y.val)

    function *{N<:Number,T1,T2}(x::Quantity{N,SIUnit{T1}},y::Quantity{N,SIUnit{T2}})
        # Return number if units cancel
        if T1 == -T2
            x.val*y.val
        else
            Quantity{N,SIUnit{T1+T2}}(x.val*y.val)
        end
    end

    /{N<:Number,T1,T2}(x::Quantity{N,SIUnit{T1}},y::Quantity{N,SIUnit{T2}}) = Quantity{N,SIUnit{T1-T2}}(x.val/y.val)
    # Return number if units cancel
    /{N<:Number,T}(x::Quantity{N,SIUnit{T}},y::Quantity{N,SIUnit{T}}) = x.val/y.val

    # Handle NonSIUnit multiplication explicitly since it won't get promoted
    *(x::NonSIUnit,y::NonSIUnit) = convert(Quantity,x) * convert(Quantity,y)
    function *{N<:Number,U1<:AbstractUnit,U2<:AbstractUnit}(x::Quantity{N,U1},y::Quantity{N,U2})
        convert(SIQuantity,x) * convert(SIQuantity,y)
    end

    # # Handle EmptyUnits for multiply/divide aka Constants
    *{N<:Number,U<:NonSIUnit}(x::Quantity{N,SIUnit{ConstantTuple}},y::Quantity{N,U}) = Quantity{N,U}(x.val*y.val)
    *{N<:Number,U<:NonSIUnit}(x::Quantity{N,U},y::Quantity{N,SIUnit{ConstantTuple}}) = Quantity{N,U}(x.val*y.val)

    /{N<:Number,U<:NonSIUnit}(x::Quantity{N,SIUnit{ConstantTuple}},y::Quantity{N,U}) = Quantity{N,U}(x.val/y.val)
    /{N<:Number,U<:NonSIUnit}(x::Quantity{N,U},y::Quantity{N,SIUnit{ConstantTuple}}) = Quantity{N,-U}(x.val/y.val)

    #Comparison Operators
    isless{N<:Number,U<:AbstractUnit}(x::Quantity{N,U},y::Quantity{N,U}) = x.val < y.val
    =={N<:Number,U<:AbstractUnit}(x::Quantity{N,U},y::Quantity{N,U}) = x.val == y.val

    inv{T}(::SIUnit{T}) = SIUnit{-T}()

    #Support basic rounding of Quantities
    round{Q<:Quantity}(x::Q) = Q(round(x.val))
    round{Q<:Quantity}(x::Q,d::Integer) = Q(round(x.val,d))

    #Quantity/Number Promotion
    promote_rule{N1<:Number,N2<:Number,U<:AbstractUnit}(::Type{Quantity{N1,U}},::Type{N2}) = Quantity{promote_type(N1,N2)}
    #Unit/Number Promotion
    promote_rule{N<:Number,U<:AbstractUnit}(::Type{U},::Type{N}) = Quantity{N}
    #Quantity/Quantity Promotion
    promote_rule{N1<:Number,N2<:Number,U<:AbstractUnit}(::Type{Quantity{N1,U}},::Type{Quantity{N2,U}}) = Quantity{promote_type(N1,N2),U}
    #NonSIUnit/SIUnit Promotion
    promote_rule{N1<:Number,N2<:Number,L,T}(::Type{Quantity{N1,SIUnit{T}}},::Type{Quantity{N2,NonSIUnit{T,L}}}) = SIQuantity
    #Quantity/Unit Promotion
    promote_rule{N<:Number,U1<:AbstractUnit,U2<:AbstractUnit}(::Type{Quantity{N,U1}},::Type{U2}) = Quantity{N}

    #Number -> Quantity Conversion
    convert{N1<:Number,N2<:Number}(::Type{Quantity{N1}},x::N2) = Quantity{N1,SIUnit{ConstantTuple}}(convert(N1,x))
    #Unit -> Quantity Conversion
    convert{N<:Number,U<:AbstractUnit}(::Type{Quantity{N}},x::U) = Quantity{N,U}(one(N))
    #Quantity -> Quantity Conversion
    convert{N1<:Number,N2<:Number,U<:AbstractUnit}(::Type{Quantity{N1,U}},x::Quantity{N2,U}) = Quantity{N1,U}(convert(N1,x.val))
    convert{N1<:Number,N2<:Number,U<:AbstractUnit}(::Type{Quantity{N1}},x::Quantity{N2,U}) = Quantity{N1,U}(convert(N1,x.val))
    # Hanlde conversion from NonSIUnit to SIUnit
    convert{N<:Number,U<:SIUnit}(::Type{SIQuantity},x::Quantity{N,U}) = x
    convert{N<:Number,U<:NonSIUnit}(::Type{SIQuantity},x::Quantity{N,U}) = x.val*convert(SIQuantity,U())
    convert{N<:Number,U<:NonSIUnit}(::Type{SIQuantity{N}},x::Quantity{N,U}) = convert(SIQuantity{N},convert(SIQuantity,x))
    convert{N1<:Number,N2<:Number,U<:SIUnit}(::Type{SIQuantity{N1}},x::Quantity{N2,U}) = Quantity{N1,U}(convert(N1,x.val))
    convert{N1<:Number,N2<:Number,U<:NonSIUnit}(::Type{SIQuantity{N1}},x::Quantity{N2,U}) = convert(SIQuantity{N1},convert(SIQuantity,x))

    NumberOrSI = Union{Number,AbstractUnit,Quantity}
    +(x::NumberOrSI,y::NumberOrSI) = +(promote(x,y)...)
    -(x::NumberOrSI,y::NumberOrSI) = -(promote(x,y)...)
    *(x::NumberOrSI,y::NumberOrSI) = *(promote(x,y)...)
    /(x::NumberOrSI,y::NumberOrSI) = /(promote(x,y)...)
    isless(x::NumberOrSI,y::NumberOrSI) = isless(promote(x,y)...)
    ==(x::NumberOrSI,y::NumberOrSI) = ==(promote(x,y)...)

    typealias NameValuePair Tuple{Symbol,Int64}
    char_superscript(::Type{Val{'-'}}) = '\u207b'
    char_superscript(::Type{Val{'1'}}) = '\u00b9'
    char_superscript(::Type{Val{'2'}}) = '\u00b2'
    char_superscript(::Type{Val{'3'}}) = '\u00b3'
    char_superscript(::Type{Val{'4'}}) = '\u2074'
    char_superscript(::Type{Val{'5'}}) = '\u2075'
    char_superscript(::Type{Val{'6'}}) = '\u2076'
    char_superscript(::Type{Val{'7'}}) = '\u2077'
    char_superscript(::Type{Val{'8'}}) = '\u2078'
    char_superscript(::Type{Val{'9'}}) = '\u2079'
    char_superscript(::Type{Val{'0'}}) = '\u2070'
    superscript(x::Int64) = map(repr(x)) do c
        char_superscript(Val{c})
    end
    nonzero_value(p::NameValuePair) = p[2] != 0
    function show(io::IO,p::NameValuePair)
        print(io,p[1])
        if p[2] != 1
            print(io,superscript(p[2]))
        end
    end

    function show{T}(io::IO,::SIUnit{T})
        filtered_pairs = filter(nonzero_value,zip(TypeNames,T))
        print(io,join(map(string,filtered_pairs),""))
    end
    show{L,T}(io::IO,::NonSIUnit{T,L}) = print(io,L)
    show{N,U}(io::IO,x::Quantity{N,U}) = print(io,x.val,U())

    const SIPrefix = SIUnit{ConstantTuple}()
    const Kilo       = (1000)SIPrefix
    const Mega       = (10^6)SIPrefix
    const Giga       = (10^9)SIPrefix
    const Tera       = (10^12)SIPrefix
    const Peta       = (10^15)SIPrefix
    const Exa        = (10^18)SIPrefix
    const Zetta      = (10^21)SIPrefix
    const Yotta      = (10^24)SIPrefix
    const Centi      = (1//100)SIPrefix
    const Milli      = (1//1000)SIPrefix
    const Micro      = (1//10^6)SIPrefix
    const Nano       = (1//10^9)SIPrefix
    const Pico       = (1//10^12)SIPrefix
    const Femto      = (1//10^15)SIPrefix
    const Atto       = (1//10^18)SIPrefix
    const Zepto      = (1//10^21)SIPrefix
    const Yocto      = (1//10^24)SIPrefix

    const Gram       = (1//1000)KiloGram
    const Joule      = KiloGram*Meter^2/Second^2
    const Coulomb    = Ampere*Second
    const Volt       = Joule/Coulomb
    const Farad      = Coulomb^2/Joule
    const Newton     = KiloGram*Meter/Second^2
    const Ohm        = Volt/Ampere
    const Hertz      = inv(Second)
    const Siemens    = inv(Ohm)
    const Watt       = Joule/Second
    const Pascal     = Newton/Meter^2

    const CentiMeter = Centi*Meter

    include("nonsiunits.jl")
    include("shortunits.jl")

end # module
