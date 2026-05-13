import React from 'react'

export interface GlassCardProps {
  children: React.ReactNode
  className?: string
  variant?: 'sm' | 'md' | 'lg'
  strong?: boolean
  onClick?: () => void
}

/**
 * GlassCard - Main glass surface component
 * 
 * Based on Design System specs:
 * - Padding: space-5 (16-24px)
 * - Border radius: radius-md
 * - Blur: glass-blur-md (14px)
 * - Hover: enhanced shadow
 */
export const GlassCard: React.FC<GlassCardProps> = ({
  children,
  className = '',
  variant = 'md',
  strong = false,
  onClick
}) => {
  const baseClasses = 'glass-card'
  const variantClasses = {
    sm: 'glass--sm',
    md: 'glass--md',
    lg: 'glass--lg'
  }
  const strongClass = strong ? 'glass--strong' : ''

  return (
    <div
      className={`${baseClasses} ${variantClasses[variant]} ${strongClass} ${className}`}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      onKeyDown={onClick ? (e) => e.key === 'Enter' && onClick() : undefined}
    >
      {children}
    </div>
  )
}

/**
 * GlassCardHeader - Optional header for cards
 */
export const GlassCardHeader: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className = ''
}) => (
  <div className={`flex items-center justify-between ${className}`}>
    {children}
  </div>
)

/**
 * GlassCardBody - Content area
 */
export const GlassCardBody: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className = ''
}) => (
  <div className={`text-sm ${className}`}>
    {children}
  </div>
)

/**
 * GlassCardFooter - Optional footer
 */
export const GlassCardFooter: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className = ''
}) => (
  <div className={`flex justify-end gap-3 ${className}`}>
    {children}
  </div>
)

export default GlassCard