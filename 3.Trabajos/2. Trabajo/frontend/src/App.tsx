import React from 'react'
import Sidebar from './components/Sidebar'
import SensitivityChart from './components/SensitivityChart'
import StatsPanel from './components/StatsPanel'
import APMPanel from './components/APMPanel'
import ExportPanel from './components/ExportPanel'
import Spinner from './components/Spinner'
import ErlangBEquationPanel from './components/ErlangBEquationPanel'
import ThreeDErlangBView from './components/ThreeDErlangBView'
import { useSimulation } from './hooks/useSimulation'
import GlassThemeToggle from './components/glass/GlassThemeToggle'

/**
 * Main App - Glassmorphism Dashboard
 */
const App: React.FC = () => {
  const { loading, error, result, sensitivity, runSimulation, runSensitivity } = useSimulation()
  const [viewMode, setViewMode] = React.useState<'2d' | '3d'>('2d')
  const [inputs, setInputs] = React.useState({ lam: 0.8, mu: 1, k: 10 })

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

  const avgConcurrent = result?.states && result.states.length > 0 
    ? result.states.reduce((a, b) => a + b, 0) / result.states.length 
    : undefined

  const currentBusy = result?.states && result.states.length > 0 ? result.states[result.states.length - 1] : 0

  const activeK = Number.isFinite(inputs.k) && inputs.k > 0 ? inputs.k : 1

  return (
    <div className="glass-app md:flex-row">
      {/* Glass Sidebar */}
      <aside className="glass-sidebar">
        <div className="glass-sidebar-inner">
          {/* Header */}
          <div
            className="glass-sidebar-header"
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24, paddingBottom: 16, borderBottom: '1px solid var(--color-border-subtle)' }}
          >
            <h1 style={{ fontSize: 20, fontWeight: 700, color: 'var(--color-text-primary)', margin: 0, lineHeight: 1.2 }}>
              M/M/k/k — Dashboard
            </h1>
            <GlassThemeToggle />
          </div>

          {/* Sidebar content */}
          <Sidebar
            onSimulate={handleSimulate}
            onSensitivity={handleSensitivity}
            onParamsChange={setInputs}
            loading={loading}
          />

          {/* Export panel */}
          <div className="glass-sidebar-footer" style={{ marginTop: 24, paddingTop: 16, borderTop: '1px solid var(--color-border-subtle)' }}>
            <ExportPanel />
          </div>

          {/* Error */}
          {error && (
            <div style={{ marginTop: 16, padding: 12, borderRadius: 8, fontSize: 14, background: 'rgba(239, 68, 68, 0.15)', color: 'var(--color-error)' }}>
              Error: {error}
            </div>
          )}
        </div>
      </aside>

      {/* Main content */}
      <main className="glass-main">
        <div id="export-area" className="glass-main-stack">
          <div className="glass-toolbar" style={{ marginBottom: 4 }}>
            <h2 style={{ margin: 0, color: 'var(--color-text-primary)' }}>
              {viewMode === '2d' ? 'Vista 2D' : 'Vista 3D'}
            </h2>
            <button
              type="button"
              className="glass-btn w-full md:w-auto"
              onClick={() => setViewMode((m) => (m === '2d' ? '3d' : '2d'))}
            >
              {viewMode === '2d' ? 'Ir a Vista 3D' : 'Volver a Vista 2D'}
            </button>
          </div>

          <div style={{ display: viewMode === '2d' ? 'block' : 'none' }}>
            <>
              {/* APM Panel */}
              <APMPanel
                blocking={result?.blocking_probability}
                mean_wait={result?.mean_wait}
                avg_concurrent={avgConcurrent}
              />

              <ErlangBEquationPanel
                lam={inputs.lam}
                mu={inputs.mu}
                k={activeK}
                pBlocking={result?.blocking_probability}
              />

              {/* Sensitivity or Results */}
              {sensitivity ? (
                <div style={{ marginTop: 16 }}>
                  <SensitivityChart
                    A_values={sensitivity.A_values}
                    blocking_sim_mean={sensitivity.blocking_sim_mean}
                    blocking_theory={sensitivity.blocking_theory}
                    wait_sim_mean={sensitivity.wait_sim_mean}
                    wait_theory={sensitivity.wait_theory}
                  />
                </div>
              ) : (
                <div className="glass-card" style={{ marginBottom: 16 }}>
                  <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>
                    Resultados de la última simulación
                  </h3>
                  <div style={{ fontSize: 14, color: 'var(--color-text-secondary)', marginTop: 8 }}>
                    Probabilidad de bloqueo: <strong>{result?.blocking_probability ?? '—'}</strong>
                  </div>
                  <div style={{ fontSize: 14, color: 'var(--color-text-secondary)', marginTop: 4 }}>
                    Tiempo de espera en cola (Erlang-B): <strong>0</strong> (sin cola)
                  </div>
                </div>
              )}

              {/* Stats Panel */}
              <StatsPanel data={result?.wait_times} />
            </>
          </div>

          <div style={{ display: viewMode === '3d' ? 'block' : 'none' }}>
            <ThreeDErlangBView k={activeK} currentBusy={currentBusy} />
          </div>
        </div>

        {/* Loading overlay */}
        {loading && (
          <div 
            className="glass-loading-overlay"
            aria-live="polite"
            aria-busy="true"
          >
            <div style={{ textAlign: 'center', color: 'var(--color-text-primary)' }}>
              <Spinner />
              <div style={{ marginTop: 12 }}>
                Ejecutando simulación — por favor espera...
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}

export default App
