import React from 'react'
import Sidebar from './components/Sidebar'
import SensitivityChart from './components/SensitivityChart'
import StatsPanel from './components/StatsPanel'
import APMPanel from './components/APMPanel'
import { useSimulation } from './hooks/useSimulation'

const App: React.FC = () => {
  const { loading, error, result, sensitivity, runSimulation, runSensitivity } = useSimulation()

  const handleSimulate = async (params: any) => {
    try {
      await runSimulation(params)
    } catch (e) {
      // handled in hook
    }
  }

  const handleSensitivity = async (opts: any) => {
    try {
      await runSensitivity(opts)
    } catch (e) {
      // handled in hook
    }
  }

  const avgConcurrent = result?.states && result.states.length > 0 ? result.states.reduce((a, b) => a + b, 0) / result.states.length : undefined

  return (
    <div className="min-h-screen flex">
      <aside className="w-80 p-4 border-r bg-white">
        <h1 className="text-xl font-bold mb-4">MM1K — Dashboard</h1>
        <Sidebar onSimulate={handleSimulate} onSensitivity={handleSensitivity} loading={loading} />
        {error && <div className="mt-4 text-sm text-red-600">Error: {error}</div>}
      </aside>

      <main className="flex-1 p-6">
        <APMPanel blocking={result?.blocking_probability} mean_wait={result?.mean_wait} avg_concurrent={avgConcurrent} />

        {sensitivity ? (
          <SensitivityChart
            A_values={sensitivity.A_values}
            blocking_sim_mean={sensitivity.blocking_sim_mean}
            blocking_theory={sensitivity.blocking_theory}
            wait_sim_mean={sensitivity.wait_sim_mean}
            wait_theory={sensitivity.wait_theory}
          />
        ) : (
          <div className="card mb-4">
            <h3 className="font-semibold">Resultados de la última simulación</h3>
            <div className="mt-2 text-sm text-gray-700">Probabilidad de bloqueo: <strong>{result?.blocking_probability ?? '-'}</strong></div>
            <div className="mt-1 text-sm text-gray-700">Tiempo medio de espera (s): <strong>{result?.mean_wait ?? '-'}</strong></div>
          </div>
        )}

        <StatsPanel data={result?.wait_times} />
      </main>
    </div>
  )
}

export default App
