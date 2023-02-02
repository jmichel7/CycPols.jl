# auto-generated tests from julia-repl docstrings
using Test, CycPols
function mytest(file::String,src::String,man::String)
  println(file," ",src)
  omit=src[end]==';'
  src=replace(src,"\\\\"=>"\\")
  exec=repr(MIME("text/plain"),eval(Meta.parse(src)),context=:limit=>true)
  if omit exec="nothing" end
  exec=replace(exec,r" *(\n|$)"s=>s"\1")
  exec=replace(exec,r"\n$"s=>"")
  man=replace(man,r" *(\n|$)"s=>s"\1")
  man=replace(man,r"\n$"s=>"")
  i=1
  while i<=lastindex(exec) && i<=lastindex(man) && exec[i]==man[i]
    i=nextind(exec,i)
  end
  if exec!=man 
    print("exec=$(repr(exec[i:end]))\nmanl=$(repr(man[i:end]))\n")
  end
  exec==man
end
@testset verbose = true "Gapjm" begin
@testset "CycPols.jl" begin
@test mytest("CycPols.jl","using LaurentPolynomials","nothing")
@test mytest("CycPols.jl","@Pol q","Pol{Int64}: q")
@test mytest("CycPols.jl","p=CycPol(q^25-q^24-2q^23-q^2+q+2)","(q-2)Φ₁Φ₂Φ₂₃")
@test mytest("CycPols.jl","p(q)","Pol{Int64}: q²⁵-q²⁴-2q²³-q²+q+2")
@test mytest("CycPols.jl","p*inv(CycPol(q^2+q+1))","(q-2)Φ₁Φ₂Φ₃⁻¹Φ₂₃")
@test mytest("CycPols.jl","-p","(-q+2)Φ₁Φ₂Φ₂₃")
@test mytest("CycPols.jl","valuation(p)","0")
@test mytest("CycPols.jl","degree(p)","25")
@test mytest("CycPols.jl","lcm(p,CycPol(q^3-1))","(q-2)Φ₁Φ₂Φ₃Φ₂₃")
@test mytest("CycPols.jl","subs(p,Pol()^-1)","(2-q⁻¹)q⁻²⁴Φ₁Φ₂Φ₂₃")
@test mytest("CycPols.jl","using CyclotomicNumbers","nothing")
@test mytest("CycPols.jl","subs(p,Pol([E(2)],1))","(-q-2)Φ₁Φ₂Φ₄₆")
@test mytest("CycPols.jl","CycPol(q^6-E(4))","Φ″₈Φ⁽¹³⁾₂₄")
@test mytest("CycPols.jl","CycPols.show_factors(24)","15-element Vector{Tuple{CycPol{Int64}, Pol}}:\n (Φ₂₄, q⁸-q⁴+1)\n (Φ′₂₄, q⁴+ζ₃²)\n (Φ″₂₄, q⁴+ζ₃)\n (Φ‴₂₄, q⁴-√2q³+q²-√2q+1)\n (Φ⁗₂₄, q⁴+√2q³+q²+√2q+1)\n (Φ⁽⁵⁾₂₄, q⁴-√6q³+3q²-√6q+1)\n (Φ⁽⁶⁾₂₄, q⁴+√6q³+3q²+√6q+1)\n (Φ⁽⁷⁾₂₄, q⁴+√-2q³-q²-√-2q+1)\n (Φ⁽⁸⁾₂₄, q⁴-√-2q³-q²+√-2q+1)\n (Φ⁽⁹⁾₂₄, q²+ζ₃²√-2q-ζ₃)\n (Φ⁽¹⁰⁾₂₄, q²-ζ₃²√-2q-ζ₃)\n (Φ⁽¹¹⁾₂₄, q²+ζ₃√-2q-ζ₃²)\n (Φ⁽¹²⁾₂₄, q²-ζ₃√-2q-ζ₃²)\n (Φ⁽¹³⁾₂₄, q⁴-ζ₄q²-1)\n (Φ⁽¹⁴⁾₂₄, q⁴+ζ₄q²-1)")
@test mytest("CycPols.jl","CycPol(;conductor=24,no=7)","Φ⁽⁷⁾₂₄")
@test mytest("CycPols.jl","CycPol(;conductor=24,no=7)(q)","Pol{Cyc{Int64}}: q⁴+√-2q³-q²-√-2q+1")
@test mytest("CycPols.jl","p=cyclotomic_polynomial(24)","Pol{Int64}: q⁸-q⁴+1")
@test mytest("CycPols.jl","CycPol(p)","Φ₂₄")
@test mytest("CycPols.jl","cyclotomic_polynomial(5)","Pol{Int64}: q⁴+q³+q²+q+1")
@test mytest("CycPols.jl","cyclotomic_polynomial(24)","Pol{Int64}: q⁸-q⁴+1")
@test mytest("CycPols.jl","@Pol q;CycPol(3*q^3-3q)","3qΦ₁Φ₂")
end
end
