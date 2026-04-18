import React, { useMemo } from 'react'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, ScatterChart, Scatter, CartesianGrid, Legend } from 'recharts'

type Props = {
  data?: number[]
}

function histogram(data: number[], bins = 30) {
  if (!data || data.length === 0) return [] as { x: number; y: number }[]
  const min = Math.min(...data)
  const max = Math.max(...data)
  const width = (max - min) / bins
  const counts = new Array(bins).fill(0)
  data.forEach((v) => {
    const idx = Math.min(bins - 1, Math.floor((v - min) / (width || 1e-9)))
    counts[idx]++
  })
  return counts.map((c, i) => ({ x: min + i * width, y: c / data.length }))
}

function qqData(data: number[]) {
  const n = data.length
  if (n === 0) return [] as { x: number; y: number }[]
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

const StatsPanel: React.FC<Props> = ({ data }) => {
  const hist = useMemo(() => (data ? histogram(data, 30) : []), [data])
  const qq = useMemo(() => (data ? qqData(data) : []), [data])

  return (
    <div className="card mt-4">
      <h3 className="font-semibold mb-2">Validación Estadística</h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div style={{ height: 300 }}>
          <ResponsiveContainer>
            <BarChart data={hist}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="x" tickFormatter={(v) => Number(v).toFixed(2)} />
              <YAxis />
              <Tooltip formatter={(val: any) => [val, 'densidad']} />
              <Bar dataKey="y" fill="#3182ce" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div style={{ height: 300 }}>
          <ResponsiveContainer>
            <ScatterChart>
              <CartesianGrid />
              <XAxis dataKey="x" name="Teórico" tickFormatter={(v) => Number(v).toFixed(2)} />
              <YAxis dataKey="y" name="Muestral" tickFormatter={(v) => Number(v).toFixed(2)} />
              <Tooltip cursor={{ strokeDasharray: '3 3' }} />
              <Legend />
              <Scatter data={qq} fill="#dd6b20" name="QQ" />
              {/* reference line y=x is not a data series; draw implicit by overlaying points near diagonal */}
            </ScatterChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}

export default StatsPanel
