import React from 'react'
import ReactFlow, { Background, Controls, MarkerType, type Edge, type Node } from 'reactflow'
import 'reactflow/dist/style.css'

type MarkovChainDiagramProps = {
  k: number
}

const NODE_SPACING = 150

const MarkovChainDiagram: React.FC<MarkovChainDiagramProps> = ({ k }) => {
  const safeK = Math.max(0, Math.floor(Number.isFinite(k) ? k : 0))

  const nodes = React.useMemo<Node[]>(() => {
    return Array.from({ length: safeK + 1 }, (_, i) => ({
      id: `${i}`,
      data: { label: `${i}` },
      position: { x: i * NODE_SPACING, y: 0 },
      className: 'markov-node',
      style: {
        borderRadius: 14,
        border: '1px solid var(--glass-border-color)',
        background: 'var(--glass-bg)',
        color: 'var(--color-text-primary)',
        backdropFilter: 'blur(var(--glass-blur-sm))',
        WebkitBackdropFilter: 'blur(var(--glass-blur-sm))',
        width: 56,
        height: 56,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        boxShadow: 'var(--glass-shadow)'
      }
    }))
  }, [safeK])

  const edges = React.useMemo<Edge[]>(() => {
    const forward: Edge[] = Array.from({ length: safeK }, (_, i) => ({
      id: `f-${i}-${i + 1}`,
      source: `${i}`,
      target: `${i + 1}`,
      label: 'λ',
      labelStyle: {
        fill: 'var(--color-text-secondary)',
        fontWeight: 700,
        fontSize: 13
      },
      labelBgPadding: [6, 2],
      labelBgBorderRadius: 999,
      labelBgStyle: {
        fill: 'var(--glass-bg-strong)',
        fillOpacity: 0.9
      },
      markerEnd: {
        type: MarkerType.ArrowClosed,
        color: 'var(--color-accent)'
      },
      style: {
        stroke: 'var(--color-accent)',
        strokeWidth: 2
      },
      sourceHandle: null,
      targetHandle: null,
      type: 'smoothstep'
    }))

    const backward: Edge[] = Array.from({ length: safeK }, (_, i) => ({
      id: `b-${i + 1}-${i}`,
      source: `${i + 1}`,
      target: `${i}`,
      label: `${i + 1}μ`,
      labelStyle: {
        fill: 'var(--color-text-secondary)',
        fontWeight: 700,
        fontSize: 13
      },
      labelBgPadding: [6, 2],
      labelBgBorderRadius: 999,
      labelBgStyle: {
        fill: 'var(--glass-bg-strong)',
        fillOpacity: 0.9
      },
      markerEnd: {
        type: MarkerType.ArrowClosed,
        color: 'var(--color-success)'
      },
      style: {
        stroke: 'var(--color-success)',
        strokeWidth: 2
      },
      sourceHandle: null,
      targetHandle: null,
      type: 'smoothstep'
    }))

    return [...forward, ...backward]
  }, [safeK])

  return (
    <div className="glass-card" style={{ marginBottom: 16 }}>
      <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>
        Diagrama de transición de estados (M/M/k/k)
      </h3>
      <p style={{ marginTop: 0, marginBottom: 12, color: 'var(--color-text-secondary)', fontSize: 14 }}>
        Estados de ocupación desde 0 hasta {safeK}. Navegá con zoom y arrastre.
      </p>

      <div
        className="markov-diagram-surface"
        style={{
          height: 240,
          borderRadius: 14,
          border: '1px solid var(--color-border-subtle)',
          overflow: 'hidden'
        }}
      >
        <ReactFlow
          nodes={nodes}
          edges={edges}
          fitView
          minZoom={0.3}
          maxZoom={2}
          attributionPosition="bottom-left"
          proOptions={{ hideAttribution: true }}
        >
          <Background color="var(--color-border-subtle)" gap={20} />
          <Controls showInteractive={false} />
        </ReactFlow>
      </div>
    </div>
  )
}

export default MarkovChainDiagram
