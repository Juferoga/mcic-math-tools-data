import { useState } from 'react'
import type { SimRequest, SimResponse } from '../api'
import { simulate } from '../api'
import { mm1k_blocking_probability, mm1k_mean_wait } from '../utils/theory'

export type SensitivityResult = {
  A_values: number[]
  blocking_sim_mean: number[]
  blocking_sim_std: number[]
  blocking_theory: number[]
  wait_sim_mean: number[]
  wait_sim_std: number[]
  wait_theory: number[]
}

export function useSimulation() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<SimResponse | null>(null)
  const [sensitivity, setSensitivity] = useState<SensitivityResult | null>(null)

  async function runSimulation(params: SimRequest) {
    setLoading(true)
    setError(null)
    try {
      const res = await simulate(params)
      setResult(res)
      return res
    } catch (e: any) {
      setError(e?.message || String(e))
      throw e
    } finally {
      setLoading(false)
    }
  }

  async function runSensitivity(opts: {
    mu: number
    K: number
    sample_size?: number
    replicates?: number
    a_min?: number
    a_max?: number
    steps?: number
    seed?: number
  }) {
    setLoading(true)
    setError(null)
    try {
      const a_min = opts.a_min ?? 0.1
      const a_max = opts.a_max ?? 1.5
      const steps = opts.steps ?? 20
      const replicates = opts.replicates ?? 3
      const mu = opts.mu
      const K = opts.K
      const sample_size = opts.sample_size ?? 10000
      const seed = opts.seed ?? 0

      const A_values = Array.from({ length: steps }, (_, i) => a_min + (i * (a_max - a_min)) / (steps - 1))

      const blocking_sim_mean: number[] = []
      const blocking_sim_std: number[] = []
      const blocking_theory: number[] = []
      const wait_sim_mean: number[] = []
      const wait_sim_std: number[] = []
      const wait_theory: number[] = []

      for (let i = 0; i < A_values.length; i++) {
        const A = A_values[i]
        const lam = A * mu
        const bvals: number[] = []
        const wvals: number[] = []
        for (let r = 0; r < replicates; r++) {
          const s = seed + i * 100 + r
          // small sample_size for interactive runs recommended
          // eslint-disable-next-line no-await-in-loop
          const res = await simulate({ lam, mu, K, sample_size, seed: s })
          bvals.push(res.blocking_probability)
          wvals.push(res.mean_wait)
        }
        const bmean = bvals.reduce((a, b) => a + b, 0) / bvals.length
        const wmean = wvals.reduce((a, b) => a + b, 0) / wvals.length
        const bstd = Math.sqrt(bvals.reduce((a, b) => a + Math.pow(b - bmean, 2), 0) / bvals.length)
        const wstd = Math.sqrt(wvals.reduce((a, b) => a + Math.pow(b - wmean, 2), 0) / wvals.length)

        blocking_sim_mean.push(bmean)
        blocking_sim_std.push(bstd)
        wait_sim_mean.push(wmean)
        wait_sim_std.push(wstd)

        // theory
        const p_k = mm1k_blocking_probability(lam, mu, K)
        const { W, Wq } = mm1k_mean_wait(lam, mu, K)
        blocking_theory.push(p_k)
        wait_theory.push(Wq)
      }

      const out: SensitivityResult = {
        A_values,
        blocking_sim_mean,
        blocking_sim_std,
        blocking_theory,
        wait_sim_mean,
        wait_sim_std,
        wait_theory,
      }
      setSensitivity(out)
      return out
    } catch (e: any) {
      setError(e?.message ?? String(e))
      throw e
    } finally {
      setLoading(false)
    }
  }

  return {
    loading,
    error,
    result,
    sensitivity,
    runSimulation,
    runSensitivity,
  }
}
