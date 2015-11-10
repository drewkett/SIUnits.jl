export ElectronVolt, Torr, Atmosphere, Degree

macro nonsiunit(unitname,printedunit,conversion)
    return quote
        local u = unit($conversion)
        const $(esc(unitname)) = NonSIUnit{typeof(u),$printedunit}()
        $(esc(:(Base.convert)))(::Type{SIQuantity},::typeof($(esc(unitname)))) = $conversion
    end
end

@nonsiunit(ElectronVolt,:eV,1.60217656535e-19Joule)
@nonsiunit(Torr,:torr,133.322368Pascal)
@nonsiunit(Atmosphere,:atm,101325Pascal)
@nonsiunit(Degree,:deg,π/180.*Radian)

for (func,funcd) in ((:sin,:sind),
                     (:cos,:cosd),
                     (:tan,:tand),
                     (:cot,:cotd),
                     (:sec,:secd),
                     (:csc,:cscd))
    @eval $func{T}(θ::NonSIQuantity{T,$(typeof(Degree))}) = $funcd(θ.val)
end
