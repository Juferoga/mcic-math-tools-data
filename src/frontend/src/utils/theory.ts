export function mm1k_stationary_probs(lam: number, mu: number, K: number): number[] {
  if (K < 0) throw new Error('K debe ser >= 0')
  if (mu <= 0 || lam < 0) throw new Error('lam >=0 y mu > 0')
  const rho = lam / mu
  const Pn: number[] = []
  if (Math.abs(rho - 1.0) < 1e-12) {
    const val = 1 / (K + 1)
    for (let i = 0; i <= K; i++) Pn.push(val)
    return Pn
  }
  const denom = 1 - Math.pow(rho, K + 1)
  if (denom === 0) throw new Error('Denominador numérico igual a cero')
  const P0 = (1 - rho) / denom
  for (let n = 0; n <= K; n++) Pn.push(P0 * Math.pow(rho, n))
  return Pn
}

export function mm1k_blocking_probability(lam: number, mu: number, K: number): number {
  const Pn = mm1k_stationary_probs(lam, mu, K)
  return Pn[PkIndex(Pn.length)]
}

function PkIndex(length: number): number {
  return length - 1
}

export function mm1k_mean_wait(lam: number, mu: number, K: number): { W: number; Wq: number } {
  const Pn = mm1k_stationary_probs(lam, mu, K)
  const nArr = new Array(Pn.length).fill(0).map((_, i) => i)
  let L = 0
  for (let i = 0; i < Pn.length; i++) L += i * Pn[i]
  const Pk = Pn[Pn.length - 1]
  const lambda_eff = lam * (1 - Pk)
  if (lambda_eff <= 0) return { W: Infinity, Wq: Infinity }
  const W = L / lambda_eff
  const Wq = W - 1 / mu
  return { W, Wq }
}
