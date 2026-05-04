import React from 'react'

/**
 * GlassSpinner - Animated loading spinner with glass styling
 */
const Spinner: React.FC<{ size?: number }> = ({ size = 48 }) => {
  return (
    <div className="flex items-center justify-center">
      <div 
        className="animate-spin rounded-full"
        style={{ 
          width: size, 
          height: size,
          borderWidth: size / 12,
          borderColor: 'var(--color-accent)',
          borderTopColor: 'transparent'
        }}
      />
    </div>
  )
}

export default Spinner