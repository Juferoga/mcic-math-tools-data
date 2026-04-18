import React from 'react'

type Props = {
  blocking?: number
  mean_wait?: number
  avg_concurrent?: number
}

const formatPct = (v?: number) => (v == null ? '-' : `${(v * 100).toFixed(2)}%`)
const formatNum = (v?: number) => (v == null || !isFinite(v) ? '-' : v.toFixed(3))

const APMPanel: React.FC<Props> = ({ blocking, mean_wait, avg_concurrent }) => {
  return (
    <div className="card mb-4">
      <h3 className="font-semibold mb-2">Monitor — Caso: Pasarela de Pagos</h3>
      <div className="grid grid-cols-3 gap-4">
        <div className="p-3 bg-gray-50 rounded">
          <div className="text-sm text-gray-500">Prob. Transacción Rechazada</div>
          <div className="text-2xl font-bold">{formatPct(blocking)}</div>
        </div>
        <div className="p-3 bg-gray-50 rounded">
          <div className="text-sm text-gray-500">Tiempo medio de encolamiento (s)</div>
          <div className="text-2xl font-bold">{formatNum(mean_wait)}</div>
        </div>
        <div className="p-3 bg-gray-50 rounded">
          <div className="text-sm text-gray-500">Tráfico concurrente (promedio)</div>
          <div className="text-2xl font-bold">{formatNum(avg_concurrent)}</div>
        </div>
      </div>
    </div>
  )
}

export default APMPanel
