using Base.Test
using SIUnits
using SIUnits.ShortUnits

@test 1Meter === Quantity{Int64,SIUnit{LengthTuple}}(1)
@test 1.0Meter === Quantity{Float64,SIUnit{LengthTuple}}(1.0)
@test 1Meter*Second === Quantity{Int64,SIUnit{LengthTuple+TimeTuple}}(1.0)
@test 2*1Meter === 2Meter
@test 1.0Meter/2 === 0.5Meter
@test 1Meter + 2Meter === 3Meter
@test 1Meter + 2.0Meter === 3.0Meter
@test Meter^2 === Meter*Meter
@test Meter*Second === SIUnit{LengthTuple+TimeTuple}()
@test 1Meter < 2Meter
@test 3Meter > 2Meter
@test (2Meter)^2 === Quantity{Int64,SIUnit{2*LengthTuple}}(4)
@test 2Meter^2 === Quantity{Int64,SIUnit{2*LengthTuple}}(2)
@test 3Meter > 2Meter
@test 4Meter/2Meter == 2
@test 1Meter * (2/Meter) == 2

@test 1Meter == 1.0Meter
@test string(1Meter) == "1m"
@test string(1Meter^2) == "1m²"
@test string(1Meter^2*Second) == "1m²s"
@test string(1Meter^2/Second) == "1m²s⁻¹"

@test 1Inch === 1Inch
@test 1Inch == 1.0Inch
@test 1Inch + 1Inch === 2Inch
@test 1Inch + 1.0Inch === 2.0Inch

@test 1Inch * 1Meter == 0.0254Meter^2
@test 1Inch * 1Inch == (0.0254Meter)^2
@test 2Inch * 2.0Inch == (2.0Inch)^2

@test string(1Inch) == "1in"
@test string(1Inch * 1Inch) == string((0.0254Meter)^2)
