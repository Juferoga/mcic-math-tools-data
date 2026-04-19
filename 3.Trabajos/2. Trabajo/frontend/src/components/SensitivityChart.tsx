import React from 'react'
import {
  ResponsiveContainer,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  CartesianGrid,
} from 'recharts'
import { GlassCard } from './glass'

type Props = {
  A_values: number[]
  blocking_sim_mean: number[]
  blocking_theory: number[]
  wait_sim_mean: number[]
  wait_theory: number[]
}

/**
 * GlassSensitivityChart - Sensitivity analysis charts with glass styling
 */
const SensitivityChart: React.FC<Props> = ({ 
  A_values, 
  blocking_sim_mean, 
  blocking_theory, 
  wait_sim_mean, 
  wait_theory 
}) => {
  const data = A_values.map((a, i) => ({
    A: parseFloat(a.toFixed(3)),
    blocking_sim: blocking_sim_mean[i],
    blocking_th: blocking_theory[i],
    wait_sim: wait_sim_mean[i],
    wait_th: wait_theory[i],
  }))

  // Custom tooltip for glass charts
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div 
          className="glass-card p-3 text-sm"
          style={{ background: 'var(--color-bg-elevated)' }}
        >
          <p style={{ color: 'var(--color-text-secondary)' }}>
            ρ = <strong style={{ color: 'var(--color-text-primary)' }}>{label}</strong>
          </p>
          {payload.map((entry: any, idx: number) => (
            <p key={idx} style={{ color: entry.color }}>
              {entry.name}: <strong>{entry.value?.toFixed(4)}</strong>
            </p>
          ))}
        </div>
      )
    }
    return null
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* Blocking Probability Chart */}
      <GlassCard>
        <h3 
          className="font-semibold mb-4"
          style={{ color: 'var(--color-text-primary)' }}
        >
          Probabilidad de Bloqueo: Simulación vs Teoría
        </h3>
        <div style={{ width: '100%', height: 350, minHeight: 300 }}>
          <ResponsiveContainer minHeight={300}>
            <LineChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
              <XAxis 
                dataKey="A" 
                name="ρ"
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                label={{ 
                  value: 'Intensidad de tráfico (ρ)', 
                  position: 'bottom', 
                  fill: 'var(--color-text-muted)',
                  fontSize: 11
                }}
              />
              <YAxis 
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                domain={[0, 1]}
                tickFormatter={(v) => v.toFixed(2)}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend 
                wrapperStyle={{ fontSize: 11, paddingTop: 10 }}
              />
              <Line 
                type="monotone" 
                dataKey="blocking_sim" 
                stroke="var(--color-accent)" 
                dot={{ r: 3, fill: 'var(--color-accent)' }} 
                name="Simulación (media)"
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="blocking_th" 
                stroke="#dd6b20" 
                strokeDasharray="5 5" 
                name="Teoría"
                strokeWidth={2}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </GlassCard>

      {/* Wait Time Chart */}
      <GlassCard>
        <h3 
          className="font-semibold mb-4"
          style={{ color: 'var(--color-text-primary)' }}
        >
          Tiempo medio de espera: Simulación vs Teoría
        </h3>
        <div style={{ width: '100%', height: 350, minHeight: 300 }}>
          <ResponsiveContainer minHeight={300}>
            <LineChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-border-subtle)" />
              <XAxis 
                dataKey="A" 
                name="ρ"
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                label={{ 
                  value: 'Intensidad de tráfico (ρ)', 
                  position: 'bottom', 
                  fill: 'var(--color-text-muted)',
                  fontSize: 11
                }}
              />
              <YAxis 
                tick={{ fill: 'var(--color-text-muted)', fontSize: 11 }}
                tickFormatter={(v) => v.toFixed(2)}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend 
                wrapperStyle={{ fontSize: 11, paddingTop: 10 }}
              />
              <Line 
                type="monotone" 
                dataKey="wait_sim" 
                stroke="#22C55E" 
                dot={{ r: 3, fill: '#22C55E' }} 
                name="Simulación (media)"
                strokeWidth={2}
              />
              <Line 
                type="monotone" 
                dataKey="wait_th" 
                stroke="#9f7aea" 
                strokeDasharray="5 5" 
                name="Teoría (Wq)"
                strokeWidth={2}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </GlassCard>
    </div>
  )
}

export default SensitivityChart
