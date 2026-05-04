import React from 'react'
import katex from 'katex'
import 'katex/dist/katex.min.css'

type Props = {
  lam: number
  mu: number
  k: number
  pBlocking?: number
}

function factorial(n: number): number {
  if (!Number.isInteger(n) || n < 0) return NaN
  if (n === 0 || n === 1) return 1
  let result = 1
  for (let i = 2; i <= n; i += 1) result *= i
  return result
}

function erlangB(A: number, k: number): number {
  if (!Number.isFinite(A) || A < 0 || !Number.isInteger(k) || k < 0) return NaN
  let numerator = Math.pow(A, k) / factorial(k)
  let denominator = 0
  for (let n = 0; n <= k; n += 1) {
    denominator += Math.pow(A, n) / factorial(n)
  }
  return numerator / denominator
}

const renderMath = (expr: string): string => {
  try {
    return katex.renderToString(expr, { throwOnError: false, displayMode: true })
  } catch {
    return expr
  }
}

const ErlangBEquationPanel: React.FC<Props> = ({ lam, mu, k, pBlocking }) => {
  const safeK = Number.isFinite(k) ? Math.max(0, Math.floor(k)) : 0
  const hasValidInputs = Number.isFinite(lam) && Number.isFinite(mu) && mu > 0 && safeK >= 0
  const A = hasValidInputs ? lam / mu : undefined
  const computedBlocking = hasValidInputs && A != null ? erlangB(A, safeK) : undefined
  const displayedBlocking = Number.isFinite(pBlocking) ? pBlocking : computedBlocking

  const symbolic = String.raw`B(k,A)=\frac{\frac{A^k}{k!}}{\sum_{n=0}^{k}\frac{A^n}{n!}},\quad A=\frac{\lambda}{\mu}`
  const substituted =
    hasValidInputs && A != null
      ? String.raw`A=\frac{${lam.toFixed(3)}}{${mu.toFixed(3)}}=${A.toFixed(3)},\quad B(${safeK},${A.toFixed(3)})\approx ${(
          displayedBlocking ?? 0
        ).toFixed(5)}`
      : String.raw`A=\frac{\lambda}{\mu}\;\text{(definido cuando }\mu>0\text{)}\quad\text{y}\quad B(k,A)\;\text{depende de entradas válidas}`

  return (
    <div className="glass-card" style={{ marginBottom: 16 }}>
      <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>
        Ecuación de Erlang-B (M/M/k/k)
      </h3>
      <div
        style={{ color: 'var(--color-text-primary)', overflowX: 'auto' }}
        dangerouslySetInnerHTML={{ __html: renderMath(symbolic) }}
      />
      <div
        style={{ color: 'var(--color-text-secondary)', overflowX: 'auto' }}
        dangerouslySetInnerHTML={{ __html: renderMath(substituted) }}
      />
      <p style={{ marginTop: 8, fontSize: 13, color: 'var(--color-text-muted)' }}>
        Interpretación: cuando todos los servidores están ocupados, las llegadas se bloquean (sin cola de espera).
      </p>
    </div>
  )
}

export default ErlangBEquationPanel
