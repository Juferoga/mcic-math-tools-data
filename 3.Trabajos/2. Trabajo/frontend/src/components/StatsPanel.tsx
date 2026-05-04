import React, { useMemo } from 'react'
import { BarChart, Bar, XAxis, YAxis, Tooltip as RechartsTooltip, ResponsiveContainer, ScatterChart, Scatter, CartesianGrid, Legend, ReferenceLine, ComposedChart, Line } from 'recharts'
import { Tooltip } from 'react-tooltip'
import 'react-tooltip/dist/react-tooltip.css'
import { GlassCard } from './glass'

type Props = {
  data?: number[]
  states?: number[]
}

// Histograma para cualquier distribución
function histogram(data: number[], bins = 30): { x: number; y: number; binCenter: number }[] {
  if (!data || data.length === 0) return []
  const min = Math.min(...data)
  const max = Math.max(...data)
  const width = (max - min) / bins || 1e-9
  const counts = new Array(bins).fill(0)
  data.forEach((v) => {
    const idx = Math.min(bins - 1, Math.floor((v - min) / width))
    counts[idx]++
  })
  return counts.map((c, i) => ({
    x: min + i * width,
    binCenter: min + (i + 0.5) * width,
    y: c / data.length
  }))
}

// Q-Q plot contra distribución exponencial teórica
function qqData(data: number[]): { theoretical: number; sample: number }[] {
  const n = data.length
  if (n === 0) return []
  const sorted = [...data].sort((a, b) => a - b)
  const mean = sorted.reduce((a, b) => a + b, 0) / n
  const rate = 1 / mean
  return sorted.map((v, idx) => {
    const p = (idx + 1 - 0.5) / n
    const theoretical = -Math.log(1 - p) / rate
    return { theoretical, sample: v }
  })
}

// Calcular distribución de estados (conteo de veces en cada estado)
function stateDistribution(states: number[], k: number): { state: number; count: number; probability: number }[] {
  if (!states || states.length === 0) return []
  const counts = new Array(k + 1).fill(0)
  states.forEach(s => {
    if (s >= 0 && s <= k) counts[s]++
  })
  const total = states.length
  return counts.map((c, i) => ({
    state: i,
    count: c,
    probability: c / total
  }))
}

// Custom tooltip para histogramas
const HistTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div
        className="glass-card p-3 text-sm"
        style={{ background: 'var(--color-bg-elevated)' }}
      >
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Bin: <strong style={{ color: 'var(--color-text-primary)' }}>{payload[0]?.payload?.binCenter?.toFixed(3)}</strong>
        </p>
        <p style={{ color: 'var(--color-accent)' }}>
          Densidad: <strong>{payload[0]?.value?.toFixed(4)}</strong>
        </p>
      </div>
    )
  }
  return null
}

// Tooltip para Q-Q plot
const QQTol = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="glass-card p-3 text-sm">
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Teórico: <strong style={{ color: 'var(--color-text-primary)' }}>{payload[0]?.payload?.theoretical?.toFixed(3)}</strong>
        </p>
        <p style={{ color: '#dd6b20' }}>
          Muestral: <strong>{payload[0]?.payload?.sample?.toFixed(3)}</strong>
        </p>
      </div>
    )
  }
  return null
}

// Tooltip para distribución de estados
const StateTooltip = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="glass-card p-3 text-sm">
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Estado n = <strong style={{ color: 'var(--color-text-primary)' }}>{payload[0]?.payload?.state}</strong>
        </p>
        <p style={{ color: 'var(--color-accent)' }}>
          Frecuencia: <strong>{payload[0]?.value}</strong>
        </p>
        <p style={{ color: 'var(--color-success)' }}>
          P(n): <strong>{(payload[0]?.payload?.probability || 0).toFixed(4)}</strong>
        </p>
      </div>
    )
  }
  return null
}

const GlassStatsPanel: React.FC<Props> = ({ data, states }) => {
  const hasData = data && data.length > 0
  const hasStates = states && states.length > 0

  // Si no hay datos, mostrar mensaje
  if (!hasData && !hasStates) {
    return (
      <GlassCard className="mt-4">
        <h3 className="font-semibold mb-4" style={{ color: 'var(--color-text-primary)' }}>
          Validación Estadística
        </h3>
        <p style={{ color: 'var(--color-text-muted)' }}>
          Ejecuta una simulación para ver los gráficos de validación.
        </p>
      </GlassCard>
    )
  }

  // Calcular histogramas y Q-Q solo si hay datos de tiempos
  const serviceHist = useMemo(() => hasData ? histogram(data, 25) : [], [data, hasData])
  const serviceQQ = useMemo(() => hasData ? qqData(data) : [], [data, hasData])

  // Calcular distribución de estados
  const k = hasStates ? Math.max(...states) : 0
  const stateDist = useMemo(() => hasStates ? stateDistribution(states, k) : [], [states, hasStates, k])

  // Calcular estadísticas
  const mean = hasData ? data.reduce((a, b) => a + b, 0) / data.length : 0
  const variance = hasData ? data.reduce((sum, v) => sum + Math.pow(v - mean, 2), 0) / data.length : 0
  const stdDev = Math.sqrt(variance)
  const theoreticalMean = 1 // Para servicio exponencial con mu=1

  return (
    <GlassCard className="mt-4">
      <h3 className="font-semibold mb-4" style={{ color: 'var(--color-text-primary)' }}>
        Validación Estadística
      </h3>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* 1. Histograma de Tiempos de Servicio */}
        {hasData && (
          <div style={{ width: '100%', height: 340 }}>
            <h4 className="text-sm font-medium mb-2" style={{ color: 'var(--color-text-secondary)' }}>
              Histograma: Tiempos de Servicio
              <span 
                data-tooltip-id="stats-info-tooltip"
                data-tooltip-content="Muestra la distribución de los tiempos que tardan los servidores en atender cada request. En M/M/k/k debería verse como una exponencial decreciente: muchos request cortos, pocos largos."
                style={{ marginLeft: 6, cursor: 'help' }}
                aria-hidden="true"
              >ⓘ</span>
            </h4>
            <ResponsiveContainer>
              <BarChart data={serviceHist} margin={{ top: 10, right: 10, left: 0, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
                <XAxis
                  dataKey="binCenter"
                  tickFormatter={(v) => v.toFixed(1)}
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  label={{ value: 'Tiempo (s)', position: 'bottom', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <YAxis tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }} />
                <RechartsTooltip content={<HistTooltip />} />
                <Bar dataKey="y" fill="var(--color-accent)" radius={[3, 3, 0, 0]} name="Frecuencia relativa" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}

        {/* 2. Q-Q Plot de Tiempos de Servicio */}
        {hasData && (
          <div style={{ width: '100%', height: 340 }}>
            <h4 className="text-sm font-medium mb-2" style={{ color: 'var(--color-text-secondary)' }}>
              Q-Q Plot: Validación de Distribución
              <span 
                data-tooltip-id="stats-info-tooltip"
                data-tooltip-content="Compara los cuantiles de tus datos vs los teóricos de una exponencial. Si los puntos siguen la línea diagonal, tus datos SÍ son exponenciales (validación exitosa)."
                style={{ marginLeft: 6, cursor: 'help' }}
                aria-hidden="true"
              >ⓘ</span>
            </h4>
            <ResponsiveContainer>
              <ScatterChart margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <CartesianGrid stroke="var(--color-border-subtle)" />
                <XAxis
                  dataKey="theoretical"
                  name="Teórico"
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  type="number"
                  domain={['auto', 'auto']}
                  label={{ value: 'Cuantil Teórico', position: 'bottom', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <YAxis
                  dataKey="sample"
                  name="Muestral"
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  type="number"
                  domain={['auto', 'auto']}
                  label={{ value: 'Cuantil Muestral', angle: -90, position: 'left', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <RechartsTooltip content={<QQTol />} />
                <Scatter data={serviceQQ} fill="#dd6b20" name="Datos" />
                {/* Línea de referencia y=x */}
                {serviceQQ.length > 0 && (
                  <ReferenceLine
                    segment={[
                      { x: 0, y: 0 },
                      { x: Math.max(...serviceQQ.map(p => p.theoretical)), y: Math.max(...serviceQQ.map(p => p.sample)) }
                    ]}
                    stroke="var(--color-success)"
                    strokeDasharray="5 5"
                    label={{ value: 'y=x', position: 'insideTopRight', fill: 'var(--color-success)', fontSize: 10 }}
                  />
                )}
              </ScatterChart>
            </ResponsiveContainer>
          </div>
        )}

{/* 3. Distribución de Estados del Sistema */}
        {hasStates && (
          <div style={{ width: '100%', height: 340 }}>
            <h4 className="text-sm font-medium mb-2" style={{ color: 'var(--color-text-secondary)' }}>
              Distribución de Estados P(n)
              <span 
                data-tooltip-id="stats-info-tooltip"
                data-tooltip-content="Muestra qué tan ocupado estuvo el sistema durante la simulación. P(n) es la probabilidad de que exactamente n servidores estén ocupados al mismo tiempo."
                style={{ marginLeft: 6, cursor: 'help' }}
                aria-hidden="true"
              >ⓘ</span>
            </h4>
            <ResponsiveContainer>
              <BarChart data={stateDist} margin={{ top: 10, right: 10, left: 0, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
                <XAxis
                  dataKey="state"
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  label={{ value: 'Estado n (servidores ocupados)', position: 'bottom', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <YAxis
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  tickFormatter={(v) => v.toFixed(3)}
                  label={{ value: 'P(n)', angle: -90, position: 'left', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <RechartsTooltip content={<StateTooltip />} />
                <Bar dataKey="probability" fill="var(--color-success)" radius={[3, 3, 0, 0]} name="P(n)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}

        {/* 4. Comparación Simulación vs Teoría (Solo si hay estados) */}
        {hasStates && k > 0 && (
          <div style={{ width: '100%', height: 340 }}>
            <h4 className="text-sm font-medium mb-2" style={{ color: 'var(--color-text-secondary)' }}>
              P(n) Simulada vs Teórica (Erlang B)
              <span 
                data-tooltip-id="stats-info-tooltip"
                data-tooltip-content="Compara la distribución real observada en la simulación (barras) con la predicción matemática de Erlang B (línea punteada). Si son similares, la simulación es correcta."
                style={{ marginLeft: 6, cursor: 'help' }}
                aria-hidden="true"
              >ⓘ</span>
            </h4>
            <ResponsiveContainer>
              <ComposedChart data={stateDist} margin={{ top: 10, right: 10, left: 0, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
                <XAxis
                  dataKey="state"
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  label={{ value: 'Estado n', position: 'bottom', fill: 'var(--color-text-muted)', fontSize: 10 }}
                />
                <YAxis
                  tick={{ fill: 'var(--color-text-muted)', fontSize: 10 }}
                  tickFormatter={(v) => v.toFixed(3)}
                />
                <RechartsTooltip />
                <Legend wrapperStyle={{ fontSize: 10 }} />
                <Bar dataKey="probability" fill="var(--color-accent)" name="Simulada" radius={[3, 3, 0, 0]} />
                <Line
                  type="monotone"
                  data={stateDist.map((d, i) => ({
                    state: d.state,
                    theoretical: Math.pow(mean * (k - d.state), k - d.state) / factorial(k - d.state) * Math.exp(-mean * (k - d.state))
                  }))}
                  dataKey="theoretical"
                  stroke="#dd6b20"
                  strokeDasharray="5 5"
                  name="Teórica (Poisson truncada)"
                  dot={false}
                />
              </ComposedChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>

      {/* Resumen de estadísticas */}
      <div className="mt-6 pt-5 flex flex-wrap gap-6 text-sm" style={{ borderTop: '1px solid var(--color-border-subtle)' }}>
        {hasData && (
          <>
            <div>
              <span style={{ color: 'var(--color-text-muted)' }}>Muestras (servicio): </span>
              <strong style={{ color: 'var(--color-text-primary)' }}>{data.length}</strong>
            </div>
            <div>
              <span style={{ color: 'var(--color-text-muted)' }}>Media: </span>
              <strong style={{ color: 'var(--color-text-primary)' }}>{mean.toFixed(4)}s</strong>
            </div>
            <div>
              <span style={{ color: 'var(--color-text-muted)' }}>Desv.Est: </span>
              <strong style={{ color: 'var(--color-text-primary)' }}>{stdDev.toFixed(4)}s</strong>
            </div>
            <div>
              <span style={{ color: 'var(--color-text-muted)' }}>Relación Media/Desv: </span>
              <strong style={{ color: mean / stdDev > 0.8 && mean / stdDev < 1.2 ? 'var(--color-success)' : 'var(--color-accent)' }}>
                {(mean / stdDev).toFixed(2)} {mean / stdDev > 0.8 && mean / stdDev < 1.2 ? '(✓ Exponencial)' : '(?)'}
              </strong>
            </div>
          </>
        )}
        {hasStates && (
          <div>
            <span style={{ color: 'var(--color-text-muted)' }}>Muestras (estados): </span>
            <strong style={{ color: 'var(--color-text-primary)' }}>{states.length}</strong>
          </div>
        )}
      </div>
      
      {/* Tooltip de react-tooltip para las ⓘ */}
      <Tooltip id="stats-info-tooltip" place="right" style={{ zIndex: 2147483647, maxWidth: 280 }} />
    </GlassCard>
  )
}

// Función factorial auxiliar
function factorial(n: number): number {
  if (n <= 1) return 1
  let result = 1
  for (let i = 2; i <= n; i++) result *= i
  return result
}

export default GlassStatsPanel