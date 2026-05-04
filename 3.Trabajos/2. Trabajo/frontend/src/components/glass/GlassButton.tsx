import React from 'react'

export interface GlassButtonProps {
  children: React.ReactNode
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  className?: string
  type?: 'button' | 'submit' | 'reset'
  onClick?: () => void
  ariaLabel?: string
}

/**
 * GlassButton - Glass-styled button component
 * 
 * Based on Design System specs:
 * - Min height: 40px
 * - Border radius: radius-sm
 * - Padding: space-3 space-4
 * - States: default, hover, active, disabled, loading
 * - A11y: aria-disabled, focus visible ring
 */
export const GlassButton: React.FC<GlassButtonProps> = ({
  children,
  variant = 'secondary',
  size = 'md',
  disabled = false,
  loading = false,
  className = '',
  type = 'button',
  onClick,
  ariaLabel
}) => {
  const baseClasses = 'glass-btn'
  
  const variantClasses: Record<string, string> = {
    primary: 'glass-btn-primary',
    secondary: 'glass-btn-secondary',
    ghost: 'glass-btn-ghost'
  }
  
  const sizeClasses: Record<string, string> = {
    sm: 'text-sm px-3 py-2 min-h-[32px]',
    md: 'text-sm px-4 py-2 min-h-[40px]',
    lg: 'text-base px-5 py-3 min-h-[48px]'
  }
  
  const isDisabled = disabled || loading
  
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={isDisabled}
      aria-disabled={isDisabled}
      aria-label={ariaLabel}
      aria-busy={loading}
      className={`
        ${baseClasses}
        ${variantClasses[variant]}
        ${sizeClasses[size]}
        ${isDisabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
        ${className}
      `}
    >
      {loading ? (
        <>
          <SpinnerIcon className="animate-spin -ml-1 mr-2 h-4 w-4" />
          <span className="sr-only">Cargando...</span>
          {/* Hidden text for screen readers */}
          <span aria-hidden="true">{children}</span>
        </>
      ) : (
        children
      )}
    </button>
  )
}

/**
 * Spinner icon for loading state
 */
const SpinnerIcon: React.FC<{ className?: string }> = ({ className = '' }) => (
  <svg 
    className={className} 
    xmlns="http://www.w3.org/2000/svg" 
    fill="none" 
    viewBox="0 0 24 24"
  >
    <circle 
      className="opacity-25" 
      cx="12" 
      cy="12" 
      r="10" 
      stroke="currentColor" 
      strokeWidth="4"
    />
    <path 
      className="opacity-75" 
      fill="currentColor" 
      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
    />
  </svg>
)

/**
 * IconButton - Circular glass icon button
 */
export const GlassIconButton: React.FC<{
  children: React.ReactNode
  onClick?: () => void
  disabled?: boolean
  className?: string
  ariaLabel: string
}> = ({
  children,
  onClick,
  disabled = false,
  className = '',
  ariaLabel
}) => (
  <button
    onClick={onClick}
    disabled={disabled}
    aria-disabled={disabled}
    aria-label={ariaLabel}
    className={`
      glass-btn
      glass-btn-secondary
      p-2
      min-h-[40px] min-w-[40px]
      rounded-full
      ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
      ${className}
    `}
  >
    {children}
  </button>
)

export default GlassButton