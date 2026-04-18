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

type Props = {
  A_values: number[]
  blocking_sim_mean: number[]
  blocking_theory: number[]
  wait_sim_mean: number[]
  wait_theory: number[]
}

const SensitivityChart: React.FC<Props> = ({ A_values, blocking_sim_mean, blocking_theory, wait_sim_mean, wait_theory }) => {
  const data = A_values.map((a, i) => ({
    A: parseFloat(a.toFixed(3)),
    blocking_sim: blocking_sim_mean[i],
    blocking_th: blocking_theory[i],
    wait_sim: wait_sim_mean[i],
    wait_th: wait_theory[i],
  }))

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div className="card">
        <h3 className="font-semibold mb-2">Probabilidad de Bloqueo (P_k): Simulación vs Teoría</h3>
        <div style={{ width: '100%', height: 300 }}>
          <ResponsiveContainer>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="A" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="blocking_sim" stroke="#2b6cb0" dot={{ r: 3 }} name="Simulación (media)" />
              <Line type="monotone" dataKey="blocking_th" stroke="#dd6b20" strokeDasharray="5 5" name="Teoría" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="card">
        <h3 className="font-semibold mb-2">Tiempo medio de espera en cola (Wq): Simulación vs Teoría</h3>
        <div style={{ width: '100%', height: 300 }}>
          <ResponsiveContainer>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="A" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="wait_sim" stroke="#2c7a7b" dot={{ r: 3 }} name="Simulación (media)" />
              <Line type="monotone" dataKey="wait_th" stroke="#9f7aea" strokeDasharray="5 5" name="Teoría (Wq)" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}

export default SensitivityChart
