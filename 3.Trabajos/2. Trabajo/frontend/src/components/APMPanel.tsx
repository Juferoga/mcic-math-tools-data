import React from 'react'
import { GlassCard, GlassMetricCard, GlassMetricGrid } from './glass'

type Props = {
  blocking?: number
  mean_wait?: number
  avg_concurrent?: number
}

/**
 * GlassAPMPanel - Metrics display for APM monitoring
 * 
 * Refactored with glass design system
 */
const formatPct = (v?: number) => (v == null ? '—' : `${(v * 100).toFixed(2)}%`)
const formatNum = (v?: number) => (v == null || !isFinite(v) ? '—' : v.toFixed(3))
const formatQueueWait = (v?: number) => {
  if (v == null || !isFinite(v)) return '—'
  return `${v.toFixed(3)} (Erlang-B sin cola)`
}

const GlassAPMPanel: React.FC<Props> = ({ blocking, mean_wait, avg_concurrent }) => {
  // Determine variant based on value thresholds
  const getBlockingVariant = (): 'default' | 'success' | 'warning' | 'error' => {
    if (blocking == null) return 'default'
    if (blocking < 0.01) return 'success'
    if (blocking < 0.05) return 'warning'
    return 'error'
  }

  const getWaitVariant = (): 'default' | 'success' | 'warning' | 'error' => {
    if (mean_wait == null) return 'default'
    if (mean_wait < 0.5) return 'success'
    if (mean_wait < 2) return 'warning'
    return 'error'
  }

  return (
    <GlassCard className="mb-4">
      <div className="flex items-center justify-between mb-4">
        <h3 
          className="text-lg font-semibold"
          style={{ color: 'var(--color-text-primary)' }}
        >
          Monitor — Caso: Pasarela de Pagos
        </h3>
        
        {/* Status indicator */}
        {blocking !== undefined && (
          <span 
            className="flex items-center gap-1.5 text-xs px-2 py-1 rounded-full"
            style={{ 
              background: `color-mix(in srgb, var(--color-${getBlockingVariant() === 'success' ? 'success' : getBlockingVariant() === 'warning' ? 'warning' : 'error'}) 15%, transparent)`,
              color: `var(--color-${getBlockingVariant() === 'success' ? 'success' : getBlockingVariant() === 'warning' ? 'warning' : 'error'})`
            }}
          >
            <span 
              className="w-1.5 h-1.5 rounded-full"
              style={{ background: 'currentColor' }}
            />
            {getBlockingVariant() === 'success' ? 'Óptimo' : getBlockingVariant() === 'warning' ? 'Advertencia' : 'Crítico'}
          </span>
        )}
      </div>

      <GlassMetricGrid>
        <GlassMetricCard
          label="Prob. Transacción Rechazada"
          value={formatPct(blocking)}
          variant={getBlockingVariant()}
        />
        <GlassMetricCard
          label="Tiempo de espera en cola Wq (s)"
          value={formatQueueWait(mean_wait)}
          variant={getWaitVariant()}
        />
        <GlassMetricCard
          label="Tráfico concurrente (promedio)"
          value={formatNum(avg_concurrent)}
        />
      </GlassMetricGrid>
    </GlassCard>
  )
}

export default GlassAPMPanel
