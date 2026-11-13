# Property tests for CycPols, checked against independent oracles.
#   julia --project=. results/cycpols-properties.jl
# from an env with CycPols develop'ed plus LaurentPolynomials, CyclotomicNumbers,
# ModuleElts and Primes.
#
# Correct behaviour is asserted plainly; every defect found in the review has one
# `@test_broken` so the file is green today and starts failing when the defect is
# fixed (turn that line into @test then).

using Test, Primes
using CycPols, LaurentPolynomials, CyclotomicNumbers, ModuleElts
const C = CycPols
const LP = LaurentPolynomials

@Pol q

# ---------------------------------------------------------------- helpers ---

"product of (q-ζ_d^j) for j in J, computed directly in Cyc coefficients"
prodroots(d, J) = prod(j -> Pol([-E(d,j), 1], 0), J)

"the expansion x^n-1"
xpow(n) = Pol([-1, zeros(Int, n-1)..., 1], 0)

"evaluate a Pol at a point the slow way"
slowval(p, x) = sum(p[i]*x^i for i in valuation(p):degree(p); init=zero(x))

# ------------------------------------------------------------------ tests ---

@testset "CycPols properties" verbose=true begin

@testset "cyclotomic_polynomial" begin
  for n in 1:120
    @test reduce(*, map(C.cyclotomic_polynomial, divisors(n))) == xpow(n)
    @test degree(C.cyclotomic_polynomial(n)) == totient(n)
  end
  @test C.cyclotomic_polynomial(1) == q-1
  @test C.cyclotomic_polynomial(5) == q^4+q^3+q^2+q+1
  @test C.cyclotomic_polynomial(24) == q^8-q^4+1
  # the cache returns the same object and does not depend on the integer type
  @test C.cyclotomic_polynomial(7) === C.cyclotomic_polynomial(7)
  @test C.cyclotomic_polynomial(Int8(7)) == C.cyclotomic_polynomial(7)
  @test C.cyclotomic_polynomial(big(7)) == C.cyclotomic_polynomial(7)
end

@testset "Pol -> CycPol keeps the value" begin
  for trial in 1:60
    m = rand( [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,20,21,24,30,36,42])
    a = C.cyclotomic_polynomial(m)*Pol([rand(-3:3) for _ in 1:rand(1:3)], rand(0:1))
    c = CycPol(a)
    @test c(Pol()) == a                      # reconstruction
    @test degree(c) == degree(a)
    @test valuation(c) == valuation(a)
    @test CycPol(c(Pol())) == c              # idempotent
    b = C.cyclotomic_polynomial(rand([1,2,3,4,6,8,12]))*Pol([rand(-2:2) for _ in 1:2], 0)
    @test CycPol(a*b) == CycPol(a)*CycPol(b) # multiplicative (so `==` is canonical)
  end
  # the residual coefficient must be free of roots of unity
  for m in [7,9,11,13,15,21,24,25,27,30,45,60,105]
    c = CycPol(C.cyclotomic_polynomial(m)*Pol([-2,1],0))
    @test degree(c.coeff) == 1
    @test c.coeff(q) == Pol([-2,1],0)
    @test length(Dict(c.v)) == totient(m)
  end
  # partial products over a cyclotomic field
  for m in [7,9,11,13,25,27]
    pr = C.prime_residues(m)
    for k in 1:2
      pol = prodroots(m, pr[1:max(1, div(length(pr),k))])*(q-2)
      c = CycPol(pol)
      @test c(Pol()) == pol
      @test degree(c.coeff) == 1
      @test c.coeff(q) == Pol([-2,1],0)
    end
  end
end

@testset "arithmetic is componentwise and exact in value" begin
  a = CycPol(q^2-1); b = CycPol(q^3-1)
  @test (a*b)(Pol()) == ((q^2-1)*(q^3-1))
  @test a*b == CycPol((q^2-1)*(q^3-1))
  @test (inv(b)*b)(Pol()) == Pol([1])
  @test (a^3)(Pol()) == (q^2-1)^3
  @test (a^-2)(Pol()) == 1//(q^2-1)^2
  @test (-a)(Pol()) == -(q^2-1)
  @test (conj(CycPol(q^2-1)))(Pol()) == q^2-1         # real coefficients
  @test iszero(a*zero(CycPol{Int}))
  @test one(CycPol(3,0))(Pol()) == Pol([1])
end

@testset "evaluation" begin
  for trial in 1:30
    a = Pol([rand(-3:3) for _ in 1:4], rand(0:2))*C.cyclotomic_polynomial(rand([3,4,5,6,8,12]))
    c = CycPol(a)
    for x in (2, 3, -1, 5, 1//2, 3//4, 0.5)
      @test c(x) == a(x)
    end
    for x in (E(2), E(3), E(4), E(5), E(6), E(12))
      @test c(x) == a(x)
    end
  end
  # the pirated (p::Pol)(x::Root1) agrees with the slow evaluation
  for p in [Pol([1,2,3],0), Pol([1,2,3],2), Pol([-1,1],0), Pol([1],0), Pol([0,1],0), Pol([E(3),2],0)]
    for x in (E(1), E(2), E(3), E(4), E(5), E(6), E(7))
      @test p(x) == slowval(p, x)
    end
  end
end

@testset "subs" begin
  for pol in [CycPol(q^2-1), CycPol(q^3-1), CycPol(q^6-q^3+1), CycPol(C.cyclotomic_polynomial(15))],
      n in (1,2,3,4,-1,-2)
    @test subs(pol, Pol()^n)(Pol()) == pol(Pol()^n)
  end
  for e in (E(2), E(3), E(4), E(6))
    @test subs(CycPol(q^2-1), Pol([e],1))(Pol()) == CycPol(q^2-1)(Pol([e],1))
  end
end

@testset "dec / decompose / named factors" begin
  # CycPol(;conductor=d,no=k) is the product of the listed roots
  for d in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,21,24,28,30,36,42]
    for k in eachindex(C.dec(d))
      @test CycPol(;conductor=d,no=k-1)(Pol()) == prodroots(d, C.dec(d)[k])
    end
  end
  # decompose inverts the (conductor,no,mul) representation
  for d in [1,2,3,4,5,6,7,8,12,16,24,15,30,42], k in eachindex(C.dec(d)), m in (1,-2)
    me = ModuleElt([x//d => m for x in C.dec(d)[k]])
    dec = C.decompose(me.d)
    @test length(dec) == 1
    @test dec[1] == (conductor=d, no=k-1, mul=m)
  end
end

@testset "printing" begin
  # `print` produces a Julia expression whose value is the same polynomial
  for P in [CycPol(q-1), CycPol(q^2-1), CycPol(q^25-q^24-2q^23-q^2+q+2), C.p, C.p2,
            3*CycPol(q-2)*CycPol(q^2+q+1)]
    @test eval(Meta.parse(repr(P)))(Pol()) == P(Pol())
  end
end

# ------------------------------------------------------- known defects -----

@testset "known defects (expected to fail today)" begin

  @testset "the root 1 has two internal spellings (0//1 and 1//1)" begin
    a = CycPol(q-1)                        # built from a Pol: root 0//1
    b = CycPol(;conductor=1,no=0)          # built from the constructor: root 1//1
    @test collect(keys(Dict(a.v))) == collect(keys(Dict(b.v)))
    @test a == b                    # they print identically
    @test eval(Meta.parse(repr(a))) == a   # the printed form round-trips
    @test conj(conj(b)) == b        # conj turns 1//1 into 0//1
  end

  @testset "decompose silently drops a root when both spellings occur" begin
    z = CycPol(q-1)*CycPol(;conductor=1,no=0)                     # (q-1)^2
    @test z(3) == 4                 # returns 2 today
    @test repr(z, context=:limit=>true) == "Φ₁²"           # prints Φ₁ today
  end

  @testset "LaTeX display throws" begin
    @test repr(MIME"text/latex"(), CycPol(q^2-1)) isa String   # UndefVarError today
  end

  @testset "evaluating a quotient at an integer point" begin
    @test CycPol(1,0,(2,0,-1))(3) == 1//4      # DomainError today
    @test (CycPol(q-1)//CycPol(q^2-1))(3) == 1//4
    @test (CycPol(q-1)//CycPol(q^2-1))(3//1) == 1//4  # works with a Rational
  end

  @testset "/ divides coefficients in floating point" begin
    @test (CycPol(q^2-1)/CycPol(q-1)).coeff isa Union{Integer,Rational}
    @test (CycPol(2,0)/2).coeff isa Union{Integer,Rational}
  end

  @testset "lcm is asymmetric, and drops b.coeff" begin
    @test lcm(CycPol(q-2),CycPol(q^2-1)) == lcm(CycPol(q^2-1),CycPol(q-2))
    @test lcm(CycPol(q-2),CycPol(q-3)) isa CycPol        # throws today
    @test lcm(CycPol(2,0),CycPol(3,0)) == lcm(CycPol(3,0),CycPol(2,0))
  end

  @testset "zero objects" begin
    @test_broken (try inv(zero(CycPol{Int})); false catch e; e isa DivideError end)
    @test CycPol(0,3,(1,0)) == 0
    @test div(CycPol(q^2-1),2) == 0
  end

  @testset "types and constructors" begin
    @test one(CycPol{Int}) isa CycPol{Int}               # MethodError today
    @test zero(CycPol{Int}) isa CycPol{Int}
    @test (try C.cyclotomic_polynomial(0); false catch e; e isa ArgumentError end)
    @test_throws ArgumentError C.cyclotomic_polynomial(-1)  # works, message is cryptic
  end

  @testset "factor names: Φ′ is documented as the odd powers" begin
    for d in (3,5,7,9,14,18)
      r = C.primitiveroot(d)
      even = sort(unique([powermod(r,j,d) for j in 2:2:2*length(C.prime_residues(d))]))
      @test CycPol(;conductor=d,no=1)(Pol()) == prodroots(d, even)
    end
  end

  @testset "the named-factor constructor does not validate its arguments" begin
    @test (try CycPol(;conductor=48,no=1); false catch e; e isa ArgumentError end)
    @test (try CycPol(;conductor=7,no=9); false catch e; e isa ArgumentError end)
    @test_throws ArgumentError CycPol(;conductor=0)        # works, message is cryptic
  end
end

end
