import React, { useCallback, useEffect, useMemo, useState, useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Html, OrbitControls } from '@react-three/drei'
import * as THREE from 'three'
import type { Mesh } from 'three'
import type { MutableRefObject } from 'react'

type Props = {
  k: number
  currentBusy: number
}

type ServerState = {
  id: number
  x: number
  z: number
  busy: boolean
}

type ClientPhase = 'moving-to-server' | 'at-server' | 'blocked-evade' | 'done'

type ClientConfig = {
  id: number
  accepted: boolean
  targetServer: number | null
  startX: number
  startZ: number
}

type Particle = {
  id: number
  x: number
  y: number
  z: number
  vx: number
  vy: number
  vz: number
  life: number
  maxLife: number
}

type ThemeMode = 'light' | 'dark'

type SceneThemeColors = {
  ambientIntensity: number
  directionalIntensity: number
  floorColor: string
  serverBase: string
  serverTop: string
  serverBusy: string
  serverFree: string
  serverBusyEmissive: string
  clientAccepted: string
  clientRejected: string
  serverLabel: string
  viewportBackground: string
  trailColor: string
  particleColor: string
}

const getSceneThemeColors = (theme: ThemeMode): SceneThemeColors => {
  if (theme === 'light') {
    return {
      ambientIntensity: 0.75,
      directionalIntensity: 1.0,
      floorColor: '#e2e8f0',
      serverBase: '#94a3b8',
      serverTop: '#cbd5e1',
      serverBusy: '#22c55e',
      serverFree: '#64748b',
      serverBusyEmissive: '#14532d',
      clientAccepted: '#3b82f6',
      clientRejected: '#f97316',
      serverLabel: '#0f172a',
      viewportBackground: 'rgba(255, 255, 255, 0.35)',
      trailColor: '#60a5fa',
      particleColor: '#fb923c',
    }
  }

  return {
    ambientIntensity: 0.6,
    directionalIntensity: 1.2,
    floorColor: '#0f172a',
    serverBase: '#1e293b',
    serverTop: '#334155',
    serverBusy: '#22c55e',
    serverFree: '#475569',
    serverBusyEmissive: '#14532d',
    clientAccepted: '#60a5fa',
    clientRejected: '#fb923c',
    serverLabel: '#f1f5f9',
    viewportBackground: 'rgba(15, 23, 42, 0.4)',
    trailColor: '#93c5fd',
    particleColor: '#fdba74',
  }
}

const SERVER_SPACING = 2.2
const SERVER_Z = 0
const SPAWN_Z = -5
const SPAWN_X_VARIANCE = 3
const CLIENT_RADIUS = 0.25
const MOVE_TIME = 0.6
const SERVE_TIME = 0.9
const EVADE_TIME = 0.5
const SPAWN_MIN_TIME = 0.2
const SPAWN_MAX_TIME = 0.5
const MAX_PARTICLES = 50
const TRAIL_LENGTH = 8

const lerp = (a: number, b: number, t: number) => a + (b - a) * t
const clamp01 = (v: number) => Math.max(0, Math.min(1, v))
const randomBetween = (min: number, max: number) => min + Math.random() * (max - min)

const getDocumentTheme = (): ThemeMode => {
  if (typeof document === 'undefined') return 'light'
  return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'
}

const useThemeMode = (): ThemeMode => {
  const [theme, setTheme] = useState<ThemeMode>(() => getDocumentTheme())

  useEffect(() => {
    if (typeof document === 'undefined') return

    const root = document.documentElement
    const syncTheme = () => setTheme(getDocumentTheme())

    syncTheme()

    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-theme') {
          syncTheme()
          break
        }
      }
    })

    observer.observe(root, { attributes: true, attributeFilter: ['data-theme'] })

    return () => observer.disconnect()
  }, [])

  return theme
}

// Estela detrás del cliente
const ClientTrail: React.FC<{ 
  positions: THREE.Vector3[] 
  color: string 
}> = ({ positions, color }) => {
  const lineRef = React.useRef<any>(null)

  const geometry = useMemo(() => {
    const points = positions.map(p => new THREE.Vector3(p.x, p.y, p.z))
    return new THREE.BufferGeometry().setFromPoints(points)
  }, [positions])

  if (positions.length < 2) return null

  return (
    <line ref={lineRef} geometry={geometry}>
      <lineBasicMaterial color={color} transparent opacity={0.6} linewidth={2} />
    </line>
  )
}

// Partículas de bloqueo
const ParticleSystem: React.FC<{ 
  particles: Particle[] 
  color: string
}> = ({ particles, color }) => {
  return (
    <>
      {particles.map((p) => {
        const scale = p.life / p.maxLife
        return (
          <mesh key={`particle-${p.id}`} position={[p.x, p.y, p.z]}>
            <sphereGeometry args={[0.08 * scale, 8, 8]} />
            <meshStandardMaterial 
              color={color} 
              emissive={color}
              emissiveIntensity={0.5 * scale}
              transparent
              opacity={scale}
            />
          </mesh>
        )
      })}
    </>
  )
}

// Cliente con estela
const ClientNode: React.FC<{
  config: ClientConfig
  serverPositions: { x: number; z: number }[]
  onDone: (id: number, serverId: number | null) => void
  colors: SceneThemeColors
  onBlock: (x: number, y: number, z: number) => void
}> = ({ config, serverPositions, onDone, colors, onBlock }) => {
  const meshRef = React.useRef<Mesh>(null)
  const trailPositions = useRef<THREE.Vector3[]>([])
  const hasSpawnedParticles = useRef(false)
  
  const animationRef = React.useRef<ClientPhase>(
    config.accepted ? 'moving-to-server' : 'blocked-evade'
  )
  const elapsedRef = useRef(0)

  useFrame((_, delta) => {
    const state = animationRef.current
    const mesh = meshRef.current
    if (!mesh) return

    elapsedRef.current += delta

    if (state === 'moving-to-server' && config.targetServer !== null) {
      const target = serverPositions[config.targetServer]
      const t = clamp01(elapsedRef.current / MOVE_TIME)
      
      const x = lerp(config.startX, target.x, t)
      const z = lerp(config.startZ, target.z, t)
      const y = 0.3 + Math.sin(t * Math.PI) * 0.15
      
      mesh.position.set(x, y, z)
      
      // Agregar posición a la estela
      trailPositions.current.push(new THREE.Vector3(x, y, z))
      if (trailPositions.current.length > TRAIL_LENGTH) {
        trailPositions.current.shift()
      }
      
      const scale = 0.8 + t * 0.2
      mesh.scale.setScalar(scale)

      if (t >= 1) {
        animationRef.current = 'at-server'
        elapsedRef.current = 0
      }
      return
    }

    if (state === 'at-server') {
      const target = serverPositions[config.targetServer ?? 0]
      const pulse = 1 + Math.sin(elapsedRef.current * 8) * 0.1
      mesh.scale.setScalar(pulse)
      mesh.position.set(target.x, 0.35, target.z)
      
      // Mantener estela
      trailPositions.current.push(new THREE.Vector3(target.x, 0.35, target.z))
      if (trailPositions.current.length > TRAIL_LENGTH) {
        trailPositions.current.shift()
      }

      if (elapsedRef.current >= SERVE_TIME) {
        mesh.scale.setScalar(1)
        // Limpiar estela al terminar
        trailPositions.current = []
        onDone(config.id, config.targetServer)
      }
      return
    }

    if (state === 'blocked-evade') {
      const t = clamp01(elapsedRef.current / EVADE_TIME)
      
      // Spawn particles only once at the beginning
      if (!hasSpawnedParticles.current && t > 0.1) {
        hasSpawnedParticles.current = true
        onBlock(
          lerp(config.startX, config.startX + 1.5, 0.1),
          0.3,
          lerp(config.startZ, config.startZ + 4, 0.1)
        )
      }
      
      const x = lerp(config.startX, config.startX + 1.5, t)
      const z = lerp(config.startZ, config.startZ + 4, t)
      const y = lerp(0.3, 0.5, Math.sin(t * Math.PI))
      
      mesh.position.set(x, y, z)
      
      // Estela mientras se desvía
      trailPositions.current.push(new THREE.Vector3(x, y, z))
      if (trailPositions.current.length > TRAIL_LENGTH) {
        trailPositions.current.shift()
      }
      
      const scale = 1 - t * 0.6
      mesh.scale.setScalar(Math.max(0.2, scale))

      if (t >= 1) {
        trailPositions.current = []
        onDone(config.id, null)
      }
      return
    }
  })

  return (
    <>
      {/* Estela */}
      {trailPositions.current.length > 1 && (
        <ClientTrail 
          positions={trailPositions.current} 
          color={config.accepted ? colors.trailColor : colors.particleColor}
        />
      )}
      
      {/* Cliente */}
      <mesh ref={meshRef} position={[config.startX, 0.3, config.startZ]}>
        <sphereGeometry args={[CLIENT_RADIUS, 20, 20]} />
        <meshStandardMaterial 
          color={config.accepted ? colors.clientAccepted : colors.clientRejected}
          metalness={0.3}
          roughness={0.4}
          emissive={config.accepted ? colors.clientAccepted : colors.clientRejected}
          emissiveIntensity={0.2}
        />
      </mesh>
    </>
  )
}

// Серверы con brillo
const ServerWithGlow: React.FC<{ 
  pos: { x: number; z: number }
  busy: boolean
  colors: SceneThemeColors
}> = ({ pos, busy, colors }) => {
  const glowRef = React.useRef<any>(null)
  
  useFrame(({ clock }) => {
    if (glowRef.current && busy) {
      // Pulso de brillo
      const pulse = 0.3 + Math.sin(clock.elapsedTime * 3) * 0.15
      glowRef.current.material.opacity = pulse
    }
  })

  return (
    <group position={[pos.x, 0, pos.z]}>
      {/* Base platform */}
      <mesh position={[0, -0.05, 0]}>
        <cylinderGeometry args={[0.6, 0.7, 0.15, 32]} />
        <meshStandardMaterial color={colors.serverBase} metalness={0.2} roughness={0.6} />
      </mesh>
      
      {/* Server body */}
      <mesh position={[0, 0.4, 0]}>
        <cylinderGeometry args={[0.45, 0.45, 0.9, 32]} />
        <meshStandardMaterial
          color={busy ? colors.serverBusy : colors.serverFree}
          metalness={0.25}
          roughness={0.4}
          emissive={busy ? colors.serverBusyEmissive : '#000000'}
          emissiveIntensity={busy ? 0.35 : 0}
        />
      </mesh>
      
      {/* Glow ring cuando está ocupado */}
      {busy && (
        <mesh ref={glowRef} position={[0, 0.15, 0]} rotation={[-Math.PI / 2, 0, 0]}>
          <ringGeometry args={[0.5, 0.7, 32]} />
          <meshBasicMaterial 
            color={colors.serverBusy} 
            transparent 
            opacity={0.3}
            side={THREE.DoubleSide}
          />
        </mesh>
      )}
      
      {/* Server top indicator */}
      <mesh position={[0, 0.88, 0]}>
        <cylinderGeometry args={[0.35, 0.45, 0.06, 32]} />
        <meshStandardMaterial
          color={busy ? '#4ade80' : '#64748b'}
          emissive={busy ? '#22c55e' : '#000000'}
          emissiveIntensity={busy ? 0.5 : 0}
        />
      </mesh>
      
      {/* Label */}
      <Html position={[0, 1.1, 0]} center style={{ pointerEvents: 'none' }}>
        <div style={{
          background: busy ? 'rgba(34, 197, 94, 0.9)' : 'rgba(100, 116, 139, 0.8)',
          color: '#fff',
          padding: '2px 6px',
          borderRadius: 3,
          fontSize: 9,
          fontWeight: 600,
          fontFamily: 'monospace'
        }}>
          {busy ? '●' : '○'}
        </div>
      </Html>
    </group>
  )
}

const ErlangBScene: React.FC<{ k: number; currentBusy: number; colors: SceneThemeColors; speedMultiplier?: number }> = ({
  k,
  currentBusy,
  colors,
  speedMultiplier = 1,
}) => {
  const safeK = Number.isFinite(k) ? Math.max(1, Math.floor(k)) : 1
  const safeBusy = Number.isFinite(currentBusy)
    ? Math.max(0, Math.min(Math.floor(currentBusy), safeK))
    : 0

  const serverPositions = useMemo(() => {
    const totalWidth = (safeK - 1) * SERVER_SPACING
    return Array.from({ length: safeK }, (_, idx) => ({
      x: idx * SERVER_SPACING - totalWidth / 2,
      z: SERVER_Z
    }))
  }, [safeK])

  const [activeClients, setActiveClients] = useState<number[]>([])
  const [particles, setParticles] = useState<Particle[]>([])
  const particleIdRef = useRef(0)
  
  const clientConfigRef = React.useRef<Record<number, ClientConfig>>({})
  const nextClientIdRef = React.useRef(1)
  const simTimeRef = React.useRef(0)
  const nextSpawnAtRef = React.useRef(randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME))

  const serverBusyRef: MutableRefObject<boolean[]> = React.useRef(
    Array.from({ length: safeK }, (_, idx) => idx < safeBusy),
  )

  const [serverStates, setServerStates] = useState<ServerState[]>(
    serverPositions.map((pos, idx) => ({ id: idx, x: pos.x, z: pos.z, busy: idx < safeBusy })),
  )

  // Color del suelo
  const floorColor = colors.floorColor

  const syncServerStates = useCallback(() => {
    setServerStates(serverPositions.map((pos, idx) => ({ 
      id: idx, 
      x: pos.x, 
      z: pos.z,
      busy: serverBusyRef.current[idx] ?? false 
    })))
  }, [serverPositions])

  const claimFreeServer = useCallback(() => {
    for (let i = 0; i < safeK; i += 1) {
      if (serverBusyRef.current[i]) continue
      serverBusyRef.current[i] = true
      syncServerStates()
      return i
    }
    return null
  }, [safeK, syncServerStates])

  const releaseServer = useCallback(
    (serverId: number) => {
      if (serverId < 0 || serverId >= safeK) return
      if (!serverBusyRef.current[serverId]) return
      serverBusyRef.current[serverId] = false
      syncServerStates()
    },
    [safeK, syncServerStates],
  )

  const handleClientDone = useCallback(
    (clientId: number, serverId: number | null) => {
      if (serverId !== null) {
        releaseServer(serverId)
      }
      delete clientConfigRef.current[clientId]
      setActiveClients((prev) => prev.filter((id) => id !== clientId))
    },
    [releaseServer],
  )

  const spawnParticle = useCallback((x: number, y: number, z: number) => {
    const newParticles: Particle[] = []
    const count = 12
    
    for (let i = 0; i < count; i++) {
      const angle = (Math.PI * 2 * i) / count + Math.random() * 0.5
      const speed = 1.5 + Math.random() * 2
      const upSpeed = 2 + Math.random() * 2
      
      newParticles.push({
        id: particleIdRef.current++,
        x, y, z,
        vx: Math.cos(angle) * speed,
        vy: upSpeed,
        vz: Math.sin(angle) * speed,
        life: 1.0,
        maxLife: 1.0
      })
    }
    
    setParticles(prev => [...prev, ...newParticles].slice(-MAX_PARTICLES))
  }, [])

  // Actualizar partículas
  useFrame((_, delta) => {
    setParticles(prev => 
      prev
        .map(p => ({
          ...p,
          x: p.x + p.vx * delta,
          y: p.y + p.vy * delta,
          z: p.z + p.vz * delta,
          vy: p.vy - 3 * delta, // gravedad
          life: p.life - delta * 1.5
        }))
        .filter(p => p.life > 0)
    )
  })

  const spawnClient = useCallback(() => {
    const id = nextClientIdRef.current
    nextClientIdRef.current += 1

    const targetServer = claimFreeServer()
    const startX = randomBetween(-SPAWN_X_VARIANCE, SPAWN_X_VARIANCE)
    
    clientConfigRef.current[id] = {
      id,
      accepted: targetServer !== null,
      targetServer,
      startX,
      startZ: SPAWN_Z,
    }

    setActiveClients((prev) => [...prev, id])
  }, [claimFreeServer])

  React.useEffect(() => {
    serverBusyRef.current = Array.from({ length: safeK }, (_, idx) => idx < safeBusy)
    clientConfigRef.current = {}
    setActiveClients([])
    setParticles([])
    nextClientIdRef.current = 1
    simTimeRef.current = 0
    nextSpawnAtRef.current = randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME)
    setServerStates(serverPositions.map((pos, idx) => ({ id: idx, x: pos.x, z: pos.z, busy: idx < safeBusy })))
  }, [safeK, safeBusy, serverPositions])

  useFrame((_, delta) => {
    simTimeRef.current += delta * speedMultiplier
    const now = simTimeRef.current

    let spawnedInFrame = 0
    while (now >= nextSpawnAtRef.current && spawnedInFrame < 4) {
      spawnClient()
      nextSpawnAtRef.current += randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME)
      spawnedInFrame += 1
    }
  })

  const blockedNow = serverStates.every((s) => s.busy)
  const activeCount = activeClients.length

  return (
    <>
      <directionalLight position={[8, 10, 5]} intensity={colors.directionalIntensity} castShadow />
      <directionalLight position={[-5, 5, -5]} intensity={0.3} />
      <ambientLight intensity={colors.ambientIntensity} />

      {/* Floor con color dinámico */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.02, 0]} receiveShadow>
        <planeGeometry args={[20, 16]} />
        <meshStandardMaterial 
          color={floorColor}
          metalness={0.1}
          roughness={0.8}
        />
      </mesh>

      {/* Grid sutil */}
      <gridHelper args={[20, 40, '#475569', '#334155']} position={[0, 0.01, 0]} rotation={[0, 0, 0]} />

      {/* Servidores con brillo */}
      {serverStates.map((server) => (
        <ServerWithGlow
          key={`server-${server.id}`}
          pos={{ x: server.x, z: server.z }}
          busy={server.busy}
          colors={colors}
        />
      ))}

      {/* Línea de llegada */}
      <mesh position={[0, 0.02, SPAWN_Z - 1]}>
        <boxGeometry args={[8, 0.04, 0.15]} />
        <meshStandardMaterial color={colors.clientAccepted} emissive={colors.clientAccepted} emissiveIntensity={0.4} />
      </mesh>

      {/* Clientes activos */}
      {activeClients.map((clientId) => {
        const config = clientConfigRef.current[clientId]
        if (!config) return null
        return (
          <ClientNode
            key={`client-${clientId}`}
            config={config}
            serverPositions={serverPositions}
            onDone={handleClientDone}
            colors={colors}
            onBlock={spawnParticle}
          />
        )
      })}

      {/* Partículas */}
      <ParticleSystem particles={particles} color={colors.particleColor} />

      {/* Etiqueta pegada al suelo - visible desde arriba */}
      <Html 
        position={[0, 0.05, 3]} 
        center 
        transform 
        rotation={[-Math.PI / 2, 0, 0]}
        style={{ pointerEvents: 'none' }}
      >
        <div style={{
          background: blockedNow ? 'rgba(239, 68, 68, 0.85)' : 'rgba(34, 197, 94, 0.85)',
          color: '#fff',
          padding: '8px 20px',
          borderRadius: 8,
          fontSize: 14,
          fontWeight: 700,
          fontFamily: 'system-ui, sans-serif',
          boxShadow: '0 2px 10px rgba(0,0,0,0.3)',
          whiteSpace: 'nowrap'
        }}>
          {blockedNow ? '🚫 BLOQUEADO' : '✅ OPERATIVO'}
        </div>
      </Html>

      {/* Contador de clientes activos */}
      <Html position={[-6, 0.5, SPAWN_Z + 0.5]} center style={{ pointerEvents: 'none' }}>
        <div style={{
          background: 'rgba(0,0,0,0.6)',
          color: '#fff',
          padding: '4px 10px',
          borderRadius: 4,
          fontSize: 11,
          fontWeight: 600
        }}>
          {activeCount} clientes
        </div>
      </Html>

      {/* Indicador de carga */}
      <Html position={[6, 0.5, 0]} center style={{ pointerEvents: 'none' }}>
        <div style={{
          background: 'rgba(0,0,0,0.6)',
          color: '#fff',
          padding: '4px 10px',
          borderRadius: 4,
          fontSize: 11,
          fontWeight: 600
        }}>
          k={safeK} | uso={safeBusy}/{safeK}
        </div>
      </Html>

      <OrbitControls 
        enablePan={true} 
        minDistance={6} 
        maxDistance={20} 
        maxPolarAngle={Math.PI / 2}
        target={[0, 0.5, 0]}
      />
    </>
  )
}

const ThreeDErlangBView: React.FC<Props> = ({ k, currentBusy }) => {
  const theme = useThemeMode()
  const colors = useMemo(() => getSceneThemeColors(theme), [theme])
  const canRenderWebGL = typeof window !== 'undefined' && !!window.WebGLRenderingContext
  const [speedMultiplier, setSpeedMultiplier] = useState(1)

  const handleSpeedChange = (delta: number) => {
    setSpeedMultiplier(prev => Math.max(0.25, Math.min(4, prev + delta)))
  }

  if (!canRenderWebGL) {
    return (
      <div className="glass-card" style={{ marginTop: 16 }}>
        <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>Vista 3D Erlang-B</h3>
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Tu navegador no soporta WebGL.
        </p>
      </div>
    )
  }

  return (
    <div className="glass-card" style={{ marginTop: 16, minHeight: 520 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
        <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', margin: 0 }}>Vista 3D Erlang-B</h3>
        
        {/* Control de velocidad */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 12, color: 'var(--color-text-muted)' }}>Velocidad:</span>
          <button 
            onClick={() => handleSpeedChange(-0.25)}
            style={{
              background: 'var(--glass-bg)',
              border: '1px solid var(--glass-border-color)',
              borderRadius: 4,
              padding: '4px 10px',
              cursor: 'pointer',
              color: 'var(--color-text-primary)',
              fontSize: 14
            }}
          >
            −
          </button>
          <span style={{ 
            minWidth: 40, 
            textAlign: 'center', 
            fontWeight: 600,
            color: speedMultiplier === 1 ? 'var(--color-success)' : 'var(--color-accent)'
          }}>
            {speedMultiplier}x
          </span>
          <button 
            onClick={() => handleSpeedChange(0.25)}
            style={{
              background: 'var(--glass-bg)',
              border: '1px solid var(--glass-border-color)',
              borderRadius: 4,
              padding: '4px 10px',
              cursor: 'pointer',
              color: 'var(--color-text-primary)',
              fontSize: 14
            }}
          >
            +
          </button>
        </div>
      </div>
      
      <p style={{ marginBottom: 12, color: 'var(--color-text-secondary)', fontSize: 14 }}>
        Los clientes (esferas) llegan desde la zona izquierda. Se mueven hacia los servidores en línea diagonal con estela. 
        Cuando un servidor está ocupado, el cliente se desvía y aparecen partículas de bloqueo. 
        La etiqueta en el piso indica el estado del sistema.
      </p>

      <div
        style={{
          width: '100%',
          height: 420,
          borderRadius: 12,
          overflow: 'hidden',
          background: colors.viewportBackground,
          border: '1px solid var(--color-border-subtle)',
        }}
      >
        <Canvas camera={{ position: [0, 8, 14], fov: 45 }} gl={{ powerPreference: 'high-performance' }}>
          <ErlangBScene k={k} currentBusy={currentBusy} colors={colors} speedMultiplier={speedMultiplier} />
        </Canvas>
      </div>
    </div>
  )
}

export default ThreeDErlangBView