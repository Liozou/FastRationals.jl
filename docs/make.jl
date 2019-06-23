using Documenter, DoubleFloats

makedocs(
    modules = [FastRationals],
    sitename = "FastRationals.jl",
    authors = "Jeffrey Sarnoff",
    pages = Any[
        "Overview" => "index.md",
        "Appropriate Uses" => "appropriate.md",
        "Finding the Range" => "findingtherange.md",        
        "The Stateless Way" => "thestatelessway.md",
        "What cannot overflow?" => "mayoverflow.md",
        "Rational Magnitude In Action" => "rationalmagnitude.md",
        "Two States, Two Types" => "twostates_twotypes",
        "Parameterized Modality" => "parameterized_modality",
        "References" => "references.md"
    ]
)

deploydocs(
    repo = "github.com/JeffreySarnoff/FastRationals.jl.git",
    target = "build"
)
