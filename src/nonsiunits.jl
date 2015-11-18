export Inch, Foot, Rankine, ElectronVolt, Torr, Atmosphere, Degree

const Inch = NonSIUnit{LengthTuple,:in}()
convert(::Type{SIQuantity},::NonSIUnit{LengthTuple,:in}) = 0.0254Meter
const inch = Inch

const Foot = NonSIUnit{LengthTuple,:ft}()
convert(::Type{SIQuantity},::NonSIUnit{LengthTuple,:ft}) = 12*0.0254Meter
const ft = Foot

const Rankine = NonSIUnit{TemperatureTuple,:R}()
convert(::Type{SIQuantity},::NonSIUnit{TemperatureTuple,:R}) = 1.8K
const R = Rankine

const ElectronVolt = NonSIUnit{typeof(Joule),:eV}()
convert(::Type{SIQuantity},::typeof(ElectronVolt)) = 1.60217656535e-19Joule

const Torr = NonSIUnit{typeof(Pascal),:torr}()
convert(::Type{SIQuantity},::typeof(Torr)) = 133.322368Pascal

const Atmosphere = NonSIUnit{typeof(Pascal),:atm}()
convert(::Type{SIQuantity},::typeof(Atmosphere)) = 101325Pascal

const Degree = NonSIUnit{typeof(Radian),:deg}()
convert(::Type{SIQuantity},::typeof(Degree)) = π/180.*Radian

for (func,funcd) in ((:sin,:sind),
                     (:cos,:cosd),
                     (:tan,:tand),
                     (:cot,:cotd),
                     (:sec,:secd),
                     (:csc,:cscd))
    @eval $func{T}(θ::Quantity{T,$(typeof(Degree))}) = $funcd(θ.val)
end
