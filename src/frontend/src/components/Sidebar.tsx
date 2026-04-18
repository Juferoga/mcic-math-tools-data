import React, { useState } from 'react'

type Props = {
  onSimulate: (params: {
    lam: number
    mu: number
    K: number
    sample_size?: number
    seed?: number
  }) => void
  onSensitivity: (opts: {
    mu: number
    K: number
    sample_size?: number
    replicates?: number
    a_min?: number
    a_max?: number
    steps?: number
    seed?: number
  }) => void
  loading?: boolean
}

const Sidebar: React.FC<Props> = ({ onSimulate, onSensitivity, loading = false }) => {
  const [lam, setLam] = useState<number>(0.8)
  const [mu, setMu] = useState<number>(1.0)
  const [K, setK] = useState<number>(10)
  const [sampleSize, setSampleSize] = useState<number>(10000)
  const [seed, setSeed] = useState<number | undefined>(42)
  const [scenario, setScenario] = useState<string>('Cola Simple Teórica')

  const [aMin, setAMin] = useState<number>(0.1)
  const [aMax, setAMax] = useState<number>(1.5)
  const [steps, setSteps] = useState<number>(20)
  const [replicates, setReplicates] = useState<number>(3)

  return (
    <div>
      <div className="mb-4">
        <label className="block text-sm font-medium">Lambda (arribos)</label>
        <input value={String(lam)} onChange={(e) => setLam(parseFloat(e.target.value))} type="number" step="0.01" className="mt-1 block w-full rounded border-gray-200" />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium">Mu (servicio)</label>
        <input value={String(mu)} onChange={(e) => setMu(parseFloat(e.target.value))} type="number" step="0.01" className="mt-1 block w-full rounded border-gray-200" />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium">Capacidad K</label>
        <input value={String(K)} onChange={(e) => setK(parseInt(e.target.value || '0'))} type="number" min={1} className="mt-1 block w-full rounded border-gray-200" />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium">Tamaño muestra</label>
        <input value={String(sampleSize)} onChange={(e) => setSampleSize(parseInt(e.target.value || '0'))} type="number" min={100} className="mt-1 block w-full rounded border-gray-200" />
      </div>

      <div className="mb-4">
        <label className="block text-sm font-medium">Escenario</label>
        <select value={scenario} onChange={(e) => setScenario(e.target.value)} className="mt-1 block w-full rounded border-gray-200">
          <option>Cola Simple Teórica</option>
          <option>Superfuncion (4 distribuciones)</option>
          <option>Caso Real: Pasarela de Pagos Bancaria</option>
        </select>
      </div>

      <div className="flex gap-2">
        <button
          onClick={() => onSimulate({ lam, mu, K, sample_size: sampleSize, seed })}
          disabled={loading}
          className="px-3 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-60"
        >
          Ejecutar Simulación
        </button>

        <button
          onClick={() => onSensitivity({ mu, K, sample_size: sampleSize, replicates, a_min: aMin, a_max: aMax, steps, seed })}
          disabled={loading}
          className="px-3 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-60"
        >
          Ejecutar Sensibilidad
        </button>
      </div>

      <details className="mt-4 text-sm text-gray-600">
        <summary className="cursor-pointer">Parámetros Sensibilidad (opcional)</summary>
        <div className="mt-2 space-y-2">
          <label className="block text-xs">A min</label>
          <input value={String(aMin)} onChange={(e) => setAMin(parseFloat(e.target.value))} type="number" step="0.01" className="block w-full rounded border-gray-200" />
          <label className="block text-xs">A max</label>
          <input value={String(aMax)} onChange={(e) => setAMax(parseFloat(e.target.value))} type="number" step="0.01" className="block w-full rounded border-gray-200" />
          <label className="block text-xs">Steps</label>
          <input value={String(steps)} onChange={(e) => setSteps(parseInt(e.target.value || '0'))} type="number" className="block w-full rounded border-gray-200" />
          <label className="block text-xs">Replicates</label>
          <input value={String(replicates)} onChange={(e) => setReplicates(parseInt(e.target.value || '0'))} type="number" className="block w-full rounded border-gray-200" />
        </div>
      </details>
    </div>
  )
}

export default Sidebar
