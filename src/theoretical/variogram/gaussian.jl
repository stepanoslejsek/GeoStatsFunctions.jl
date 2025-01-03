# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    GaussianVariogram(; range, sill, nugget)
    GaussianVariogram(ball; sill, nugget)

A Gaussian variogram with `range`, `sill` and `nugget`.
Optionally, use a custom metric `ball`.
"""
struct GaussianVariogram{V,B} <: Variogram
  sill::V
  nugget::V
  ball::B
  GaussianVariogram(sill::V, nugget::V, ball::B) where {V,B} = new{float(V),B}(sill, nugget, ball)
end

GaussianVariogram(ball; sill=1.0, nugget=zero(typeof(sill))) = GaussianVariogram(sill, nugget, ball)

GaussianVariogram(; range=1.0, sill=1.0, nugget=zero(typeof(sill))) = GaussianVariogram(sill, nugget, MetricBall(range))

constructor(::GaussianVariogram) = GaussianVariogram

isstationary(::Type{<:GaussianVariogram}) = true

function (γ::GaussianVariogram)(h)
  # add small eps to nugget
  # for numerical stability
  r = radius(γ.ball)
  s = γ.sill
  n = γ.nugget + typeof(s)(1e-6)
  h′, r′ = unitless(h, r)
  (s - n) * (1 - exp(-3(h′ / r′)^2)) + (h′ > 0) * n
end
