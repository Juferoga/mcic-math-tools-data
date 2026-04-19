import React, { useMemo } from 'react'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, ScatterChart, Scatter, CartesianGrid, Legend, ReferenceLine } from 'recharts'
import { GlassCard } from './glass'

type Props = {
  data?: number[]
}

/**
 * GlassStatsPanel - Statistical validation charts
 * 
 * Refactored with glass design system
 */
function histogram(data: number[], bins = 30): { x: number; y: number }[] {
  if (!data || data.length === 0) return []
  const min = Math.min(...data)
  const max = Math.max(...data)
  const width = (max - min) / bins || 1e-9
  const counts = new Array(bins).fill(0)
  data.forEach((v) => {
    const idx = Math.min(bins - 1, Math.floor((v - min) / width))
    counts[idx]++
  })
  return counts.map((c, i) => ({ x: min + i * width, y: c / data.length }))
}

function qqData(data: number[]): { x: number; y: number }[] {
  const n = data.length
  if (n === 0) return []
  const sorted = [...data].sort((a, b) => a - b)
  const mean = sorted.reduce((a, b) => a + b, 0) / n
  const rate = 1 / mean
  const points = sorted.map((v, idx) => {
    const p = (idx + 1 - 0.5) / n
    const theoretical = -Math.log(1 - p) / rate
    return { x: theoretical, y: v }
  })
  return points
}

// Custom tooltip for glass charts
const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    return (
      <div 
        className="glass-card p-3 text-sm"
        style={{ 
          background: 'var(--color-bg-elevated)',
          backdropFilter: 'blur(14px)'
        }}
      >
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Valor: <strong style={{ color: 'var(--color-text-primary)' }}>{label?.toFixed(3)}</strong>
        </p>
        <p style={{ color: 'var(--color-accent)' }}>
          Densidad: <strong>{payload[0]?.value?.toFixed(4)}</strong>
        </p>
      </div>
    )
  }
  return null
}

const QQTooltip = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    return (
      <div className="glass-card p-3 text-sm">
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Teórico: <strong style={{ color: 'var(--color-text-primary)' }}>{payload[0]?.payload?.x?.toFixed(3)}</strong>
        </p>
        <p style={{ color: '#dd6b20' }}>
          Muestral: <strong>{payload[0]?.payload?.y?.toFixed(3)}</strong>
        </p>
      </div>
    )
  }
  return null
}

const GlassStatsPanel: React.FC<Props> = ({ data }) => {
  const hist = useMemo(() => (data ? histogram(data, 30) : []), [data])
  const qq = useMemo(() => (data ? qqData(data) : []), [data])

  if (!data || data.length === 0) {
    return (
      <GlassCard className="mt-4">
        <h3 
          className="font-semibold mb-4"
          style={{ color: 'var(--color-text-primary)' }}
        >
          Validación Estadística
        </h3>
        <p style={{ color: 'var(--color-text-muted)' }}>
          Ejecuta una simulación para ver los gráficos de validación.
        </p>
      </GlassCard>
    )
  }

  return (
    <GlassCard className="mt-4">
      <h3 
        className="font-semibold mb-4"
        style={{ color: 'var(--color-text-primary)' }}
      >
        Validación Estadística
      </h3>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Histogram */}
        <div style={{ width: '100%', height: 350, minHeight: 300 }}>
          <h4 
            className="text-sm font-medium mb-2"
            style={{ color: 'var(--color-text-secondary)' }}
          >
            Histograma de Tiempos de Espera
          </h4>
          <ResponsiveContainer minHeight={300}>
            <BarChart data={hist} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
              <XAxis 
                dataKey="x" 
                tickFormatter={(v) => Number(v).toFixed(2)}
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
              />
              <YAxis tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }} />
              <Tooltip content={<CustomTooltip />} />
              <Bar 
                dataKey="y" 
                fill="var(--color-accent)" 
                radius={[4, 4, 0, 0]}
                name="densidad"
              />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Q-Q Plot */}
        <div style={{ width: '100%', height: 350, minHeight: 300 }}>
          <h4 
            className="text-sm font-medium mb-2"
            style={{ color: 'var(--color-text-secondary)' }}
          >
            Gráfico Q-Q (Teórico vs Muestral)
          </h4>
          <ResponsiveContainer minHeight={300}>
            <ScatterChart margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
              <CartesianGrid stroke="var(--color-border-subtle)" />
              <XAxis 
                dataKey="x" 
                name="Teórico" 
                tickFormatter={(v) => Number(v).toFixed(2)}
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                type="number"
                domain={['auto', 'auto']}
              />
              <YAxis 
                dataKey="y" 
                name="Muestral" 
                tickFormatter={(v) => Number(v).toFixed(2)}
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                type="number"
                domain={['auto', 'auto']}
              />
              <Tooltip content={<QQTooltip />} />
              <Legend 
                wrapperStyle={{ fontSize: 12, color: 'var(--color-text-muted)' }}
              />
              <Scatter 
                data={qq} 
                fill="#dd6b20" 
                name="Q-Q" 
                shape="circle"
              />
              {/* Diagonal reference line */}
              {qq.length > 0 && (
                <ReferenceLine 
                  segment={[
                    { x: Math.min(...qq.map(p => p.x)), y: Math.min(...qq.map(p => p.y)) },
                    { x: Math.max(...qq.map(p => p.x)), y: Math.max(...qq.map(p => p.y)) }
                  ]}
                  stroke="var(--color-border-strong)"
                  strokeDasharray="5 5"
                />
              )}
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Stats summary */}
      <div 
        className="mt-4 pt-4 flex gap-6 text-sm"
        style={{ borderTop: '1px solid var(--color-border-subtle)' }}
      >
        <div>
          <span style={{ color: 'var(--color-text-muted)' }}>Muestras: </span>
          <strong style={{ color: 'var(--color-text-primary)' }}>{data.length}</strong>
        </div>
        <div>
          <span style={{ color: 'var(--color-text-muted)' }}>Media: </span>
          <strong style={{ color: 'var(--color-text-primary)' }}>
            {(data.reduce((a, b) => a + b, 0) / data.length).toFixed(4)}s
          </strong>
        </div>
        <div>
          <span style={{ color: 'var(--color-text-muted)' }}>Desv. Est.: </span>
          <strong style={{ color: 'var(--color-text-primary)' }}>
            {Math.sqrt(data.reduce((sum, v) => sum + Math.pow(v - data.reduce((a, b) => a + b, 0) / data.length, 2), 0) / data.length).toFixed(4)}s
          </strong>
        </div>
      </div>
    </GlassCard>
  )
}

export default GlassStatsPanel
