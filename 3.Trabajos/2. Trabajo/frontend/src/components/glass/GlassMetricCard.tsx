import React from 'react'

export interface GlassMetricCardProps {
  label: string
  value: string | number
  sublabel?: string
  variant?: 'default' | 'success' | 'warning' | 'error'
  className?: string
}

/**
 * GlassMetricCard - Display metric values in glass style
 * 
 * Used for APM panel metrics display
 */
export const GlassMetricCard: React.FC<GlassMetricCardProps> = ({
  label,
  value,
  sublabel,
  variant = 'default',
  className = ''
}) => {
  const variantColors: Record<string, string> = {
    default: 'var(--color-accent)',
    success: 'var(--color-success)',
    warning: 'var(--color-warning)',
    error: 'var(--color-error)'
  }

  return (
    <div 
      className={`glass-metric ${className}`}
      style={{ 
        background: `color-mix(in srgb, ${variantColors[variant]} 12%, transparent)`,
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)'
      }}
    >
      <div 
        className="text-sm mb-1"
        style={{ color: 'var(--color-text-muted)' }}
      >
        {label}
      </div>
      <div 
        className="text-2xl font-bold"
        style={{ color: 'var(--color-text-primary)' }}
      >
        {value}
      </div>
      {sublabel && (
        <div 
          className="text-xs mt-1"
          style={{ color: variantColors[variant] }}
        >
          {sublabel}
        </div>
      )}
    </div>
  )
}

/**
 * GlassMetricGrid - Grid of metrics (3 columns)
 */
export const GlassMetricGrid: React.FC<{
  children: React.ReactNode
  className?: string
}> = ({ children, className = '' }) => (
  <div className={`grid grid-cols-1 md:grid-cols-3 gap-4 ${className}`}>
    {children}
  </div>
)

/**
 * GlassContainer - Main layout container
 */
export const GlassContainer: React.FC<{
  children: React.ReactNode
  className?: string
}> = ({ children, className = '' }) => (
  <div 
    className={`min-h-screen flex ${className}`}
    style={{ background: 'var(--color-bg-base)' }}
  >
    {children}
  </div>
)

/**
 * GlassMain - Main content area
 */
export const GlassMain: React.FC<{
  children: React.ReactNode
  className?: string
}> = ({ children, className = '' }) => (
  <main className={`flex-1 p-6 relative ${className}`}>
    {children}
  </main>
)

export default GlassMetricCard
