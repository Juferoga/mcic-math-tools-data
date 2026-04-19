import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Html, OrbitControls } from '@react-three/drei'
import type { Mesh } from 'three'
import type { MutableRefObject } from 'react'

type Props = {
  k: number
  currentBusy: number
}

type ServerState = {
  id: number
  x: number
  busy: boolean
}

type ClientPhase = 'approaching' | 'serving' | 'blocked-hit' | 'blocked-fall'

type ClientConfig = {
  id: number
  accepted: boolean
  targetServer: number | null
}

type ClientAnimationState = {
  phase: ClientPhase
  elapsed: number
}

type ThemeMode = 'light' | 'dark'

type SceneThemeColors = {
  ambientIntensity: number
  directionalIntensity: number
  floor: string
  serverBase: string
  serverPlatform: string
  serverBusy: string
  serverFree: string
  serverBusyEmissive: string
  rejectionWall: string
  rejectionLabel: string
  serverLabel: string
  arrivalLabel: string
  statusAccepted: string
  statusBlocked: string
  clientsLabel: string
  clientAccepted: string
  clientRejected: string
  viewportBackground: string
}

const SERVER_SPACING = 1.8
const ARRIVAL_X = -6
const WALL_X = -1.75
const FLOOR_Y = -0.75
const CLIENT_RADIUS = 0.23
const APPROACH_TIME = 0.52
const SERVE_TIME = 0.95
const HIT_TIME = 0.16
const FALL_TIME = 0.38
const SPAWN_MIN_TIME = 0.3
const SPAWN_MAX_TIME = 0.8
const INITIAL_BUSY_MIN = 0.45
const INITIAL_BUSY_MAX = 1.15

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

    observer.observe(root, {
      attributes: true,
      attributeFilter: ['data-theme'],
    })

    window.addEventListener('storage', syncTheme)

    return () => {
      observer.disconnect()
      window.removeEventListener('storage', syncTheme)
    }
  }, [])

  return theme
}

const getSceneThemeColors = (theme: ThemeMode): SceneThemeColors => {
  if (theme === 'light') {
    return {
      ambientIntensity: 0.84,
      directionalIntensity: 0.95,
      floor: '#f1f5f9',
      serverBase: '#cbd5e1',
      serverPlatform: '#e2e8f0',
      serverBusy: '#22c55e',
      serverFree: '#94a3b8',
      serverBusyEmissive: '#166534',
      rejectionWall: '#f87171',
      rejectionLabel: '#7f1d1d',
      serverLabel: '#0f172a',
      arrivalLabel: '#1d4ed8',
      statusAccepted: '#166534',
      statusBlocked: '#b91c1c',
      clientsLabel: '#1e293b',
      clientAccepted: '#0284c7',
      clientRejected: '#dc2626',
      viewportBackground: 'rgba(255, 255, 255, 0.35)',
    }
  }

  return {
    ambientIntensity: 0.7,
    directionalIntensity: 1.1,
    floor: '#0f172a',
    serverBase: '#1e293b',
    serverPlatform: '#1e293b',
    serverBusy: '#22c55e',
    serverFree: '#64748b',
    serverBusyEmissive: '#14532d',
    rejectionWall: '#dc2626',
    rejectionLabel: '#fecaca',
    serverLabel: '#ffffff',
    arrivalLabel: '#bfdbfe',
    statusAccepted: '#86efac',
    statusBlocked: '#fca5a5',
    clientsLabel: '#cbd5e1',
    clientAccepted: '#38bdf8',
    clientRejected: '#ef4444',
    viewportBackground: 'rgba(15, 23, 42, 0.4)',
  }
}

const ClientNode: React.FC<{
  config: ClientConfig
  serverPositions: number[]
  onDone: (id: number, serverId: number | null) => void
  colors: SceneThemeColors
}> = ({ config, serverPositions, onDone, colors }) => {
  const meshRef = React.useRef<Mesh>(null)
  const animationRef = React.useRef<ClientAnimationState>({
    phase: config.accepted ? 'approaching' : 'blocked-hit',
    elapsed: 0,
  })

  useFrame((_, delta) => {
    const state = animationRef.current
    const mesh = meshRef.current
    if (!mesh) return

    state.elapsed += delta

    const setClientPosition = (x: number, y: number) => {
      mesh.position.x = x
      mesh.position.y = y
    }

    const setClientScale = (scale: number) => {
      mesh.scale.set(scale, scale, scale)
    }

    if (state.phase === 'approaching') {
      const targetX = config.targetServer !== null ? serverPositions[config.targetServer] ?? 0 : WALL_X
      const t = clamp01(state.elapsed / APPROACH_TIME)
      setClientPosition(lerp(ARRIVAL_X, targetX, t), 0.24 + Math.sin(t * Math.PI) * 0.12)

      if (t >= 1) {
        state.phase = 'serving'
        state.elapsed = 0
      }
      return
    }

    if (state.phase === 'serving') {
      const x = config.targetServer !== null ? serverPositions[config.targetServer] ?? 0 : 0
      const pulsate = 1 + Math.sin(state.elapsed * 10) * 0.08
      setClientScale(pulsate)
      setClientPosition(x, 0.24)

      if (state.elapsed >= SERVE_TIME) {
        setClientScale(1)
        onDone(config.id, config.targetServer)
      }
      return
    }

    if (state.phase === 'blocked-hit') {
      const t = clamp01(state.elapsed / HIT_TIME)
      setClientPosition(lerp(ARRIVAL_X, WALL_X + 0.2, t), 0.22 + Math.sin(t * Math.PI) * 0.16)

      if (t >= 1) {
        state.phase = 'blocked-fall'
        state.elapsed = 0
      }
      return
    }

    if (state.phase === 'blocked-fall') {
      const t = clamp01(state.elapsed / FALL_TIME)
      setClientPosition(WALL_X + 0.2 + t * 0.45, lerp(0.22, FLOOR_Y - 1.6, t))
      const s = 1 - t * 0.58
      setClientScale(Math.max(0.2, s))

      if (t >= 1) {
        onDone(config.id, null)
      }
    }
  })

  return (
    <mesh ref={meshRef} position={[ARRIVAL_X, 0.2, 0]}>
      <sphereGeometry args={[CLIENT_RADIUS, 18, 18]} />
      <meshStandardMaterial color={config.accepted ? colors.clientAccepted : colors.clientRejected} />
    </mesh>
  )
}

const ErlangBScene: React.FC<{ k: number; currentBusy: number; colors: SceneThemeColors }> = ({
  k,
  currentBusy,
  colors,
}) => {
  const safeK = Number.isFinite(k) ? Math.max(1, Math.floor(k)) : 1
  const safeBusy = Number.isFinite(currentBusy)
    ? Math.max(0, Math.min(Math.floor(currentBusy), safeK))
    : 0

  const serverPositions = useMemo(
    () => Array.from({ length: safeK }, (_, idx) => (idx - (safeK - 1) / 2) * SERVER_SPACING),
    [safeK],
  )

  const [activeClients, setActiveClients] = useState<number[]>([])
  const clientConfigRef = React.useRef<Record<number, ClientConfig>>({})
  const nextClientIdRef = React.useRef(1)
  const simTimeRef = React.useRef(0)
  const nextSpawnAtRef = React.useRef(randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME))

  const serverBusyRef: MutableRefObject<boolean[]> = React.useRef(
    Array.from({ length: safeK }, (_, idx) => idx < safeBusy),
  )
  const serverBusyUntilRef = React.useRef<number[]>(Array.from({ length: safeK }, () => 0))

  const [serverStates, setServerStates] = useState<ServerState[]>(
    serverPositions.map((x, idx) => ({ id: idx, x, busy: idx < safeBusy })),
  )

  const syncServerStates = useCallback(() => {
    setServerStates(serverPositions.map((x, idx) => ({ id: idx, x, busy: serverBusyRef.current[idx] ?? false })))
  }, [serverPositions])

  const claimFreeServer = useCallback(() => {
    for (let i = 0; i < safeK; i += 1) {
      if (serverBusyRef.current[i]) continue
      serverBusyRef.current[i] = true
      // Mark as occupied until the serving client finishes.
      serverBusyUntilRef.current[i] = Number.POSITIVE_INFINITY
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
      serverBusyUntilRef.current[serverId] = 0
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

  const spawnClient = useCallback(() => {
    const id = nextClientIdRef.current
    nextClientIdRef.current += 1

    const targetServer = claimFreeServer()
    clientConfigRef.current[id] = {
      id,
      accepted: targetServer !== null,
      targetServer,
    }

    setActiveClients((prev) => [...prev, id])
  }, [claimFreeServer])

  React.useEffect(() => {
    const busyUntil = Array.from({ length: safeK }, (_, idx) => {
      if (idx >= safeBusy) return 0
      return randomBetween(INITIAL_BUSY_MIN, INITIAL_BUSY_MAX)
    })

    serverBusyRef.current = Array.from({ length: safeK }, (_, idx) => idx < safeBusy)
    serverBusyUntilRef.current = busyUntil
    clientConfigRef.current = {}
    setActiveClients([])
    nextClientIdRef.current = 1
    simTimeRef.current = 0
    nextSpawnAtRef.current = randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME)
    setServerStates(serverPositions.map((x, idx) => ({ id: idx, x, busy: idx < safeBusy })))
  }, [safeK, safeBusy, serverPositions])

  useFrame((_, delta) => {
    simTimeRef.current += delta
    const now = simTimeRef.current

    // Free initially busy servers when their synthetic service finishes.
    let updatedBusy = false
    for (let i = 0; i < serverBusyRef.current.length; i += 1) {
      if (serverBusyRef.current[i] && Number.isFinite(serverBusyUntilRef.current[i]) && serverBusyUntilRef.current[i] <= now) {
        serverBusyRef.current[i] = false
        serverBusyUntilRef.current[i] = 0
        updatedBusy = true
      }
    }
    if (updatedBusy) {
      syncServerStates()
    }

    // Frequent arrivals to keep the scene dynamic and busy.
    let spawnedInFrame = 0
    while (now >= nextSpawnAtRef.current && spawnedInFrame < 5) {
      spawnClient()
      nextSpawnAtRef.current += randomBetween(SPAWN_MIN_TIME, SPAWN_MAX_TIME)
      spawnedInFrame += 1
    }
  })

  const blockedNow = serverStates.every((s) => s.busy)
  const label = blockedNow ? 'Bloqueado (sin cola)' : 'Aceptado (entra a servidor)'

  return (
    <>
      <directionalLight position={[6, 8, 4]} intensity={colors.directionalIntensity} />
      <ambientLight intensity={colors.ambientIntensity} />

      {/* Floor */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, FLOOR_Y, 0]} receiveShadow>
        <planeGeometry args={[Math.max(14, safeK * 2.4), 9]} />
        <meshStandardMaterial color={colors.floor} />
      </mesh>

      {/* Rejection wall */}
      <mesh position={[WALL_X + 0.4, 0.35, -0.95]}>
        <boxGeometry args={[0.2, 1.4, 0.4]} />
        <meshStandardMaterial color={colors.rejectionWall} metalness={0.1} roughness={0.4} />
      </mesh>
      <Html position={[WALL_X + 0.4, 1.25, -0.95]} center style={{ color: colors.rejectionLabel, fontSize: 11 }}>
        NO QUEUE
      </Html>

      {/* Servers row */}
      {serverStates.map((server) => (
        <group key={`server-${server.id}`} position={[server.x, 0, 0]}>
          <mesh position={[0, -0.12, 0]}>
            <boxGeometry args={[1.15, 0.16, 1.15]} />
            <meshStandardMaterial color={colors.serverPlatform} />
          </mesh>
          <mesh>
            <boxGeometry args={[1, 0.95, 1]} />
            <meshStandardMaterial
              color={server.busy ? colors.serverBusy : colors.serverFree}
              metalness={0.15}
              roughness={0.45}
              emissive={server.busy ? colors.serverBusyEmissive : colors.serverBase}
              emissiveIntensity={server.busy ? 0.2 : 0}
            />
          </mesh>
          <Html position={[0, 0.95, 0]} center style={{ color: colors.serverLabel, fontSize: 11 }}>
            S{server.id + 1} {server.busy ? '(busy)' : '(free)'}
          </Html>
        </group>
      ))}

      {/* Concurrent clients */}
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
          />
        )
      })}

      {/* Labels */}
      <Html position={[ARRIVAL_X, 1.05, 0]} center style={{ color: colors.arrivalLabel, fontSize: 12 }}>
        Llegada
      </Html>
      <Html
        position={[0, 1.45, 0]}
        center
        style={{ color: blockedNow ? colors.statusBlocked : colors.statusAccepted, fontSize: 12 }}
      >
        {label}
      </Html>
      <Html position={[ARRIVAL_X + 1.15, 1.42, 0]} center style={{ color: colors.clientsLabel, fontSize: 11 }}>
        Clientes activos: {activeClients.length}
      </Html>

      <OrbitControls enablePan={false} minDistance={8} maxDistance={16} maxPolarAngle={Math.PI / 2.1} />
    </>
  )
}

const ThreeDErlangBView: React.FC<Props> = ({ k, currentBusy }) => {
  const theme = useThemeMode()
  const colors = useMemo(() => getSceneThemeColors(theme), [theme])
  const canRenderWebGL = typeof window !== 'undefined' && !!window.WebGLRenderingContext

  if (!canRenderWebGL) {
    return (
      <div className="glass-card" style={{ marginTop: 16 }}>
        <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>Vista 3D Erlang-B</h3>
        <p style={{ color: 'var(--color-text-secondary)' }}>
          Tu navegador/dispositivo no soporta WebGL. Seguís teniendo disponible la vista 2D sin perder estado.
        </p>
      </div>
    )
  }

  return (
    <div className="glass-card" style={{ marginTop: 16, minHeight: 520 }}>
      <h3 style={{ fontWeight: 600, color: 'var(--color-text-primary)', marginBottom: 8 }}>Vista 3D Erlang-B</h3>
      <p style={{ marginBottom: 12, color: 'var(--color-text-secondary)', fontSize: 14 }}>
        Cada esfera representa una llegada. Si hay servidor libre, se asigna y procesa. Si todos están ocupados,
        rebota en la barrera roja y cae: Erlang-B puro, SIN cola.
      </p>

      <div
        style={{
          width: '100%',
          height: 410,
          borderRadius: 12,
          overflow: 'hidden',
          background: colors.viewportBackground,
          border: '1px solid var(--color-border-subtle)',
        }}
      >
        <Canvas camera={{ position: [0, 5.4, 10], fov: 50 }} gl={{ powerPreference: 'high-performance' }}>
          <ErlangBScene k={k} currentBusy={currentBusy} colors={colors} />
        </Canvas>
      </div>
    </div>
  )
}

export default ThreeDErlangBView
