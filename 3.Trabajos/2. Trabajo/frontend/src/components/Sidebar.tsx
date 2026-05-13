import React, { useEffect, useState } from 'react'
import { Tooltip } from 'react-tooltip'
import 'react-tooltip/dist/react-tooltip.css'

type Props = {
  onSimulate: (params: {
    lam: number
    mu: number
    k: number
    sample_size?: number
    seed?: number
  }) => void
  onSensitivity: (opts: {
    mu: number
    k: number
    sample_size?: number
    replicates?: number
    a_min?: number
    a_max?: number
    steps?: number
    seed?: number
  }) => void
  onParamsChange?: (params: {
    lam: number
    mu: number
    k: number
  }) => void
  loading?: boolean
}

/**
 * GlassSidebar - Glass-styled sidebar with form controls
 * Using inline CSS classes for reliability
 */
const Sidebar: React.FC<Props> = ({ onSimulate, onSensitivity, onParamsChange, loading = false }) => {
  const [lam, setLam] = useState<number>(0.8)
  const [mu, setMu] = useState<number>(1.0)
  const [k, setK] = useState<number>(10)
  const [sampleSize, setSampleSize] = useState<number>(10000)
  const [seed, setSeed] = useState<number | undefined>(42)
  const [scenario, setScenario] = useState<string>('Cola Simple Teórica')

  const [aMin, setAMin] = useState<number>(0.1)
  const [aMax, setAMax] = useState<number>(1.5)
  const [steps, setSteps] = useState<number>(20)
  const [replicates, setReplicates] = useState<number>(3)

  const scenarioOptions = [
    { value: 'Cola Simple Teórica', label: 'Cola Simple Teórica' },
    { value: 'Superfuncion (4 distribuciones)', label: 'Superfunción (4 distribuciones)' },
    { value: 'Caso Real: Pasarela de Pagos Bancaria', label: 'Caso Real: Pasarela de Pagos' }
  ]

  const demoPresets = [
    { id: 'low-load', label: 'Baja Carga', lam: 2, mu: 1, k: 5 },
    { id: 'high-load', label: 'Alta Carga / Bloqueo', lam: 10, mu: 1, k: 2 },
  ]

  const applyDemoPreset = (preset: { lam: number; mu: number; k: number }) => {
    setLam(preset.lam)
    setMu(preset.mu)
    setK(preset.k)
  }

  useEffect(() => {
    onParamsChange?.({ lam, mu, k })
  }, [k, lam, mu, onParamsChange])

  return (
    <div className="glass-flex glass-flex-col glass-gap-3" style={{ marginTop: 16 }}>
      {/* Title */}
      <h2 
        className="text-lg font-semibold"
        style={{ color: 'var(--color-text-primary)', marginBottom: 16 }}
      >
        Parámetros
      </h2>

      {/* Lambda input */}
      <div>
        <label className="glass-label" htmlFor="lam-input">
          Lambda (arribos)
          <span
            data-tooltip-id="sidebar-info-tooltip"
            data-tooltip-content="λ: tasa de arribos por unidad de tiempo."
            style={{ marginLeft: 6, cursor: 'help' }}
            aria-hidden="true"
          >
            ⓘ
          </span>
        </label>
        <input 
          id="lam-input"
          type="number" 
          value={lam}
          onChange={(e) => setLam(parseFloat(e.target.value) || 0)}
          step="0.01"
          disabled={loading}
          className="glass-input"
          aria-describedby="lam-help"
        />
        <span id="lam-help" className="sr-only">Lambda: tasa de llegadas al sistema M/M/k/k.</span>
      </div>

      {/* Mu input */}
      <div>
        <label className="glass-label" htmlFor="mu-input">
          Mu (servicio)
          <span
            data-tooltip-id="sidebar-info-tooltip"
            data-tooltip-content="μ: tasa de servicio por servidor."
            style={{ marginLeft: 6, cursor: 'help' }}
            aria-hidden="true"
          >
            ⓘ
          </span>
        </label>
        <input 
          id="mu-input"
          type="number" 
          value={mu}
          onChange={(e) => setMu(parseFloat(e.target.value) || 0)}
          step="0.01"
          disabled={loading}
          className="glass-input"
          aria-describedby="mu-help"
        />
        <span id="mu-help" className="sr-only">Mu: capacidad de atención de cada servidor.</span>
      </div>

      {/* K (servers) input */}
      <div>
        <label className="glass-label" htmlFor="k-input">
          Servidores (k)
          <span
            data-tooltip-id="sidebar-info-tooltip"
            data-tooltip-content="k: cantidad de servidores; capacidad máxima del sistema (sin cola)."
            style={{ marginLeft: 6, cursor: 'help' }}
            aria-hidden="true"
          >
            ⓘ
          </span>
        </label>
        <input 
          id="k-input"
          type="number" 
          value={k}
          onChange={(e) => setK(parseInt(e.target.value) || 0)}
          min={1}
          disabled={loading}
          className="glass-input"
          aria-describedby="k-help"
        />
        <span id="k-help" className="sr-only">k: número de servidores simultáneos disponibles en el sistema.</span>
      </div>

      {/* Sample size input */}
      <div>
        <label className="glass-label" htmlFor="sample-size-input">
          Tamaño de muestra (N)
          <span
            data-tooltip-id="sidebar-info-tooltip"
            data-tooltip-content="Número total de eventos simulados. Mayor N mejora estabilidad estadística pero aumenta tiempo de cómputo."
            style={{ marginLeft: 6, cursor: 'help' }}
            aria-hidden="true"
          >
            ⓘ
          </span>
        </label>
        <input 
          id="sample-size-input"
          type="number" 
          value={sampleSize}
          onChange={(e) => setSampleSize(parseInt(e.target.value) || 0)}
          min={100}
          disabled={loading}
          className="glass-input"
          data-tooltip-id="sidebar-info-tooltip"
          data-tooltip-content="Cantidad de corridas/eventos de la simulación (N)."
        />
      </div>

      {/* Scenario select */}
      <div>
        <label className="glass-label">Escenario</label>
        <select 
          value={scenario}
          onChange={(e) => setScenario(e.target.value)}
          disabled={loading}
          className="glass-select"
        >
          {scenarioOptions.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
      </div>

      {/* Demo presets */}
      <div style={{ marginTop: 8 }}>
        <label className="glass-label">
          Demos / Escenarios
          <span
            data-tooltip-id="sidebar-info-tooltip"
            data-tooltip-content="Atajos para cargar configuraciones representativas y comparar comportamientos del sistema."
            style={{ marginLeft: 6, cursor: 'help' }}
            aria-hidden="true"
          >
            ⓘ
          </span>
        </label>
        <div className="glass-flex glass-flex-col glass-gap-2">
          {demoPresets.map((preset) => (
            <button
              key={preset.id}
              type="button"
              className="glass-btn"
              onClick={() => applyDemoPreset(preset)}
              disabled={loading}
              data-tooltip-id="sidebar-info-tooltip"
              data-tooltip-content={`Aplicar preset ${preset.label}: λ=${preset.lam}, μ=${preset.mu}, k=${preset.k}`}
              style={{ justifyContent: 'space-between' }}
            >
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                {preset.label}
                <span aria-hidden="true">ⓘ</span>
              </span>
              <span style={{ fontSize: 12, opacity: 0.85 }}>
                λ={preset.lam}, μ={preset.mu}, k={preset.k}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Action buttons */}
      <div className="glass-flex glass-flex-col glass-gap-2" style={{ marginTop: 8 }}>
        <button
          onClick={() => onSimulate({ lam, mu, k, sample_size: sampleSize, seed })}
          disabled={loading}
          className="glass-btn glass-btn-primary"
        >
          {loading ? 'Ejecutando...' : 'Ejecutar Simulación'}
        </button>

        <button
          onClick={() => onSensitivity({ mu, k, sample_size: sampleSize, replicates, a_min: aMin, a_max: aMax, steps, seed })}
          disabled={loading}
          className="glass-btn"
        >
          Ejecutar Sensibilidad
        </button>
      </div>

      {/* Sensitivity parameters (collapsible) */}
      <details 
        className="glass-details" 
        style={{ marginTop: 16, paddingTop: 16, borderTop: '1px solid var(--color-border-subtle)' }}
      >
        <summary 
          className="cursor-pointer flex items-center justify-between"
          style={{ color: 'var(--color-text-secondary)', padding: '8px 0' }}
        >
          <span className="text-sm font-medium">Parámetros Sensibilidad</span>
          <svg 
            className="w-4 h-4" 
            fill="none" 
            viewBox="0 0 24 24" 
            stroke="currentColor"
            style={{ transition: 'transform 160ms ease' }}
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </summary>
        
        <div className="glass-flex glass-flex-col glass-gap-2" style={{ padding: '8px 0' }}>
          <div>
            <label className="glass-label" htmlFor="a-min-input">
              Rango de sensibilidad (A mín / A máx)
              <span
                data-tooltip-id="sidebar-info-tooltip"
                data-tooltip-content="Define el rango de intensidad de tráfico A=λ/μ usado para barrer el análisis de sensibilidad."
                style={{ marginLeft: 6, cursor: 'help' }}
                aria-hidden="true"
              >
                ⓘ
              </span>
            </label>
          </div>

          <div>
            <label className="glass-label" htmlFor="a-min-input">A mín</label>
            <input 
              id="a-min-input"
              type="number" 
              value={aMin}
              onChange={(e) => setAMin(parseFloat(e.target.value) || 0)}
              step="0.01"
              disabled={loading}
              className="glass-input"
              data-tooltip-id="sidebar-info-tooltip"
              data-tooltip-content="Valor inicial del barrido de sensibilidad para A."
            />
          </div>
          
          <div>
            <label className="glass-label" htmlFor="a-max-input">A máx</label>
            <input 
              id="a-max-input"
              type="number" 
              value={aMax}
              onChange={(e) => setAMax(parseFloat(e.target.value) || 0)}
              step="0.01"
              disabled={loading}
              className="glass-input"
              data-tooltip-id="sidebar-info-tooltip"
              data-tooltip-content="Valor final del barrido de sensibilidad para A."
            />
          </div>
          
          <div>
            <label className="glass-label">Steps</label>
            <input 
              type="number" 
              value={steps}
              onChange={(e) => setSteps(parseInt(e.target.value) || 0)}
              min={1}
              disabled={loading}
              className="glass-input"
            />
          </div>
          
          <div>
            <label className="glass-label">Replicaciones</label>
            <input 
              type="number" 
              value={replicates}
              onChange={(e) => setReplicates(parseInt(e.target.value) || 0)}
              min={1}
              disabled={loading}
              className="glass-input"
            />
          </div>
        </div>
      </details>

      <Tooltip id="sidebar-info-tooltip" place="right" style={{ zIndex: 2147483647, maxWidth: 280 }} />
    </div>
  )
}

export default Sidebar
