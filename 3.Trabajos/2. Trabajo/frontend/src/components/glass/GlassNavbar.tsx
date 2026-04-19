import React from 'react'

export interface GlassNavbarProps {
  children: React.ReactNode
  className?: string
}

/**
 * GlassNavbar - Sticky glass navigation bar
 * 
 * Based on Design System specs:
 * - Position: sticky top
 * - Height: 64px desktop, 56px mobile
 * - Blur: glass-blur-md
 * - Border bottom: subtle
 */
export const GlassNavbar: React.FC<GlassNavbarProps> = ({
  children,
  className = ''
}) => {
  return (
    <nav className={`glass-navbar ${className}`}>
      <div className="flex items-center justify-between h-full">
        {children}
      </div>
    </nav>
  )
}

/**
 * GlassNavbarBrand - Logo/brand area
 */
export const GlassNavbarBrand: React.FC<{
  children: React.ReactNode
  href?: string
  className?: string
}> = ({ children, href = '#', className = '' }) => (
  <a 
    href={href}
    className={`flex items-center gap-2 text-lg font-semibold ${className}`}
    style={{ color: 'var(--color-text-primary)' }}
  >
    {children}
  </a>
)

/**
 * GlassNavbarContent - Main navigation content
 */
export const GlassNavbarContent: React.FC<{
  children: React.ReactNode
  className?: string
}> = ({ children, className = '' }) => (
  <div className={`flex items-center gap-4 ${className}`}>
    {children}
  </div>
)

/**
 * GlassNavbarActions - Right side actions
 */
export const GlassNavbarActions: React.FC<{
  children: React.ReactNode
  className?: string
}> = ({ children, className = '' }) => (
  <div className={`flex items-center gap-2 ${className}`}>
    {children}
  </div>
)

export default GlassNavbar