import React from 'react'
import ReactFlow, { Background, Controls, Edge, Node, EdgeProps, MarkerType } from 'reactflow'
import 'reactflow/dist/style.css'

type MarkovChainDiagramProps = {
  k: number
}

const NODE_SPACING = 150
const NODE_Y = 100
const NODE_HEIGHT = 56
const NODE_TOP = NODE_Y
const NODE_BOTTOM = NODE_Y + NODE_HEIGHT

// Edges λ (llegadas) - Carril de ABAJO
const LambdaEdge: React.FC<EdgeProps> = (props) => {
  const sourceX = props.sourceX
  const targetX = props.targetX
  // Usar el borde inferior del nodo
  const sourceY = NODE_BOTTOM
  const targetY = NODE_BOTTOM
  // Curva hacia ABAJO (positive curvature)
  const curvature = 50
  const midY = NODE_BOTTOM + curvature
  // Posición del label en el medio de la curva
  const labelX = (sourceX + targetX) / 2
  const labelY = midY

  return (
    <g>
      <path
        d={`M ${sourceX} ${sourceY} C ${sourceX} ${midY}, ${targetX} ${midY}, ${targetX} ${targetY}`}
        fill="none"
        stroke="var(--color-accent)"
        strokeWidth={2}
        strokeDasharray="5,5"
      />
      {/* Label */}
      <rect
        x={labelX - 24}
        y={labelY - 10}
        width={48}
        height={20}
        rx={4}
        fill="var(--glass-bg-strong)"
        fillOpacity={0.95}
      />
      <text
        x={labelX}
        y={labelY + 4}
        textAnchor="middle"
        fill="var(--color-accent)"
        fontSize={10}
        fontWeight={700}
        style={{ fontFamily: 'sans-serif' }}
      >
        {props.label}
      </text>
    </g>
  )
}

// Edges μ (salidas) - Carril de ARRIBA
const MuEdge: React.FC<EdgeProps> = (props) => {
  const sourceX = props.sourceX
  const targetX = props.targetX
  // Usar el borde superior del nodo
  const sourceY = NODE_TOP
  const targetY = NODE_TOP
  // Curva hacia ARRIBA (negative curvature)
  const curvature = 50
  const midY = NODE_TOP - curvature
  // Posición del label en el medio de la curva
  const labelX = (sourceX + targetX) / 2
  const labelY = midY

  return (
    <g>
      <path
        d={`M ${sourceX} ${sourceY} C ${sourceX} ${midY}, ${targetX} ${midY}, ${targetX} ${targetY}`}
        fill="none"
        stroke="var(--color-success)"
        strokeWidth={2}
      />
      {/* Label */}
      <rect
        x={labelX - 30}
        y={labelY - 10}
        width={60}
        height={20}
        rx={4}
        fill="var(--glass-bg-strong)"
        fillOpacity={0.95}
      />
      <text
        x={labelX}
        y={labelY + 4}
        textAnchor="middle"
        fill="var(--color-success)"
        fontSize={10}
        fontWeight={700}
        style={{ fontFamily: 'sans-serif' }}
      >
        {props.label}
      </text>
    </g>
  )
}

const MarkovChainDiagram: React.FC<MarkovChainDiagramProps> = ({ k }) => {
  const safeK = Math.max(0, Math.floor(Number.isFinite(k) ? k : 0))

  const nodes = React.useMemo<Node[]>(() => {
    return Array.from({ length: safeK + 1 }, (_, i) => ({
      id: `${i}`,
      data: { label: `${i}` },
      position: { x: i * NODE_SPACING, y: NODE_Y },
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
    // λ (forward): de n a n+1 - CARRIL INFERIOR (abajo)
    // Notación: λ·P_n (tasa λ por probabilidad del estado n)
    const forward: Edge[] = Array.from({ length: safeK }, (_, i) => ({
      id: `lambda-${i}-${i + 1}`,
      source: `${i}`,
      target: `${i + 1}`,
      label: `λ·P${i}`,
      labelStyle: {
        fill: 'var(--color-accent)',
        fontWeight: 700,
        fontSize: 11
      },
      labelBgPadding: [6, 2],
      labelBgBorderRadius: 999,
      labelBgStyle: {
        fill: 'var(--glass-bg-strong)',
        fillOpacity: 0.9
      },
      style: {
        stroke: 'var(--color-accent)',
        strokeWidth: 2,
        strokeDasharray: '5,5'
      },
      markerEnd: {
        type: MarkerType.ArrowClosed,
        color: 'var(--color-accent)'
      },
      type: 'lambda',
      animated: false
    }))

    // μ (backward): de n+1 a n - CARRIL SUPERIOR (arriba)
    // Notación: (n+1)·μ·P_{n+1} (n+1 servidores * tasa μ * probabilidad)
    const backward: Edge[] = Array.from({ length: safeK }, (_, i) => ({
      id: `mu-${i + 1}-${i}`,
      source: `${i + 1}`,
      target: `${i}`,
      label: `${i + 1}μ·P${i + 1}`,
      labelStyle: {
        fill: 'var(--color-success)',
        fontWeight: 700,
        fontSize: 11
      },
      labelBgPadding: [6, 2],
      labelBgBorderRadius: 999,
      labelBgStyle: {
        fill: 'var(--glass-bg-strong)',
        fillOpacity: 0.9
      },
      style: {
        stroke: 'var(--color-success)',
        strokeWidth: 2
      },
      markerEnd: {
        type: MarkerType.ArrowClosed,
        color: 'var(--color-success)'
      },
      type: 'mu',
      animated: false
    }))

    return [...forward, ...backward]
  }, [safeK])

  const edgeTypes = React.useMemo(() => ({
    lambda: LambdaEdge,
    mu: MuEdge
  }), [])

  return (
    <div className="glass-card" style={{ marginBottom: 16 }}>
      <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>
        Diagrama de transición de estados (M/M/k/k)
      </h3>
      <p style={{ marginTop: 0, marginBottom: 12, color: 'var(--color-text-secondary)', fontSize: 14 }}>
        Estados de ocupación desde 0 hasta {safeK}. Navegá con zoom y arrastre.
      </p>

      {/* Leyenda */}
      <div style={{ 
        display: 'flex', 
        gap: 24, 
        marginBottom: 12, 
        padding: '8px 12px', 
        background: 'var(--glass-bg)',
        borderRadius: 8,
        fontSize: 13
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ 
            width: 24, 
            height: 3, 
            background: 'var(--color-accent)',
            borderRadius: 2,
            backgroundImage: 'linear-gradient(90deg, var(--color-accent) 5px, transparent 5px)',
            backgroundSize: '10px 100%'
          }}></div>
          <span style={{ color: 'var(--color-accent)', fontWeight: 600 }}>λ (Llegadas)</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ 
            width: 24, 
            height: 3, 
            background: 'var(--color-success)',
            borderRadius: 2
          }}></div>
          <span style={{ color: 'var(--color-success)', fontWeight: 600 }}>μ (Salidas)</span>
        </div>
      </div>

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
          edgeTypes={edgeTypes}
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