using BenchmarkTools

BenchmarkTools.DEFAULT_PARAMETERS.evals = 1;
BenchmarkTools.DEFAULT_PARAMETERS.samples = 1_000;
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 1.0e-8;
BenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();

include("thingstotime.jl")

slow2 = @belapsed sums_toward_half(Rational{Int8},2)
fast2 = @belapsed sums_toward_half(FastRational{Int8, IsReduced},2)
slow6 = @belapsed sums_toward_half(Rational{Int16},6)
fast6 = @belapsed sums_toward_half(FastRational{Int16, IsReduced},6)
slow16 = @belapsed sums_toward_half(Rational{Int32},8)
fast16 = @belapsed sums_toward_half(FastRational{Int32, IsReduced},8)
slow17 = @belapsed sums_toward_half(Rational{Int64},17)
fast17 = @belapsed sums_toward_half(FastRational{Int64, IsReduced},17)
slow77 = @belapsed sums_toward_half(Rational{Int128},77)
fast77 = @belapsed sums_toward_half(FastRational{Int128, IsReduced},77)

uslow2 = @belapsed sums_toward_half(Rational{UInt8},2)
ufast2 = @belapsed sums_toward_half(FastRational{UInt8, IsReduced},2)
uslow6 = @belapsed sums_toward_half(Rational{UInt16},6)
ufast6 = @belapsed sums_toward_half(FastRational{UInt16, IsReduced},6)
uslow16 = @belapsed sums_toward_half(Rational{UInt32},8)
ufast16 = @belapsed sums_toward_half(FastRational{UInt32, IsReduced},8)
uslow17 = @belapsed sums_toward_half(Rational{UInt64},17)
ufast17 = @belapsed sums_toward_half(FastRational{UInt64, IsReduced},17)
uslow77 = @belapsed sums_toward_half(Rational{UInt128},77)
ufast77 = @belapsed sums_toward_half(FastRational{UInt128, IsReduced},77)
