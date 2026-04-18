function factorial(n: number): number {
  if (n < 0) throw new Error('n must be >= 0')
  let r = 1
  for (let i = 2; i <= n; i++) r *= i
  return r
}

function powerDivFactorial(A: number, n: number): number {
  return Math.pow(A, n) / factorial(n)
}

export function mmkk_stationary_probs(lam: number, mu: number, k: number): number[] {
  if (k < 0) throw new Error('k debe ser >= 0')
  if (mu <= 0 || lam < 0) throw new Error('lam >=0 y mu > 0')
  const A = lam / mu
  const terms: number[] = []
  for (let n = 0; n <= k; n++) terms.push(powerDivFactorial(A, n))
  const denom = terms.reduce((a, b) => a + b, 0)
  if (denom === 0) throw new Error('Denominador numérico igual a cero')
  return terms.map((t) => t / denom)
}

export function mmkk_blocking_probability(lam: number, mu: number, k: number): number {
  const Pn = mmkk_stationary_probs(lam, mu, k)
  return Pn[Pn.length - 1]
}

export function mmkk_mean_wait(lam: number, mu: number, k: number): { W: number; Wq: number } {
  const Pn = mmkk_stationary_probs(lam, mu, k)
  let L = 0
  for (let i = 0; i < Pn.length; i++) L += i * Pn[i]
  const Pk = Pn[Pn.length - 1]
  const lambda_eff = lam * (1 - Pk)
  if (lambda_eff <= 0) return { W: Infinity, Wq: 0 }
  const W = L / lambda_eff
  const Wq = 0
  return { W, Wq }
}
