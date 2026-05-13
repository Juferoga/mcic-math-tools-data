import React, { useId } from 'react'

export interface GlassInputProps {
  label?: string
  value?: string | number
  onChange?: (value: string) => void
  type?: 'text' | 'number' | 'email' | 'password'
  placeholder?: string
  disabled?: boolean
  error?: string
  className?: string
  step?: string | number
  min?: number
  max?: number
  required?: boolean
}

/**
 * GlassInput - Glass-styled input component
 * 
 * Based on Design System specs:
 * - Border radius: radius-sm
 * - Padding: space-3 space-4
 * - Focus: accent border + ring
 * - Error: border color-error + message with role="alert"
 * - A11y: label association, aria-invalid
 */
export const GlassInput: React.FC<GlassInputProps> = ({
  label,
  value,
  onChange,
  type = 'text',
  placeholder,
  disabled = false,
  error,
  className = '',
  step,
  min,
  max,
  required = false
}) => {
  const id = useId()
  const errorId = `${id}-error`
  
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onChange?.(e.target.value)
  }
  
  return (
    <div className={className}>
      {label && (
        <label 
          htmlFor={id} 
          className="glass-label"
        >
          {label}
          {required && <span className="text-[var(--color-error)] ml-1" aria-hidden="true">*</span>}
        </label>
      )}
      
      <input
        id={id}
        type={type}
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
        disabled={disabled}
        step={step}
        min={min}
        max={max}
        required={required}
        aria-invalid={!!error}
        aria-describedby={error ? errorId : undefined}
        className={`
          glass-input
          ${error ? 'border-[var(--color-error)] focus:border-[var(--color-error)]' : ''}
          ${disabled ? 'opacity-50 cursor-not-allowed' : ''}
        `}
      />
      
      {error && (
        <p 
          id={errorId} 
          role="alert" 
          className="mt-1 text-xs text-[var(--color-error)]"
        >
          {error}
        </p>
      )}
    </div>
  )
}

/**
 * GlassNumberInput - Specialized number input with increment/decrement
 */
export const GlassNumberInput: React.FC<{
  label?: string
  value: number
  onChange: (value: number) => void
  min?: number
  max?: number
  step?: number
  disabled?: boolean
  className?: string
}> = ({
  label,
  value,
  onChange,
  min = 0,
  max = Infinity,
  step = 1,
  disabled = false,
  className = ''
}) => {
  const id = useId()
  
  const decrement = () => {
    const newValue = Math.max(min, value - step)
    onChange(newValue)
  }
  
  const increment = () => {
    const newValue = Math.min(max, value + step)
    onChange(newValue)
  }
  
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = parseFloat(e.target.value) || min
    const clamped = Math.max(min, Math.min(max, val))
    onChange(clamped)
  }
  
  return (
    <div className={className}>
      {label && (
        <label htmlFor={id} className="glass-label">
          {label}
        </label>
      )}
      
      <div className="flex items-center">
        <button
          type="button"
          onClick={decrement}
          disabled={disabled || value <= min}
          aria-label="Disminuir valor"
          className="glass-btn glass-btn-secondary px-3 py-2 rounded-l-md rounded-r-none border-r-0"
        >
          −
        </button>
        
        <input
          id={id}
          type="number"
          value={value}
          onChange={handleInputChange}
          min={min}
          max={max}
          step={step}
          disabled={disabled}
          className="glass-input rounded-none border-l-0 border-r-0 text-center [appearance:textfield]"
        />
        
        <button
          type="button"
          onClick={increment}
          disabled={disabled || value >= max}
          aria-label="Aumentar valor"
          className="glass-btn glass-btn-secondary px-3 py-2 rounded-l-none rounded-r-md border-l-0"
        >
          +
        </button>
      </div>
    </div>
  )
}

/**
 * GlassSelect - Glass-styled select component
 */
export interface GlassSelectProps {
  label?: string
  value?: string
  onChange?: (value: string) => void
  options: { value: string; label: string }[]
  disabled?: boolean
  error?: string
  className?: string
  required?: boolean
}

export const GlassSelect: React.FC<GlassSelectProps> = ({
  label,
  value,
  onChange,
  options,
  disabled = false,
  error,
  className = '',
  required = false
}) => {
  const id = useId()
  const errorId = `${id}-error`
  
  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    onChange?.(e.target.value)
  }
  
  return (
    <div className={className}>
      {label && (
        <label htmlFor={id} className="glass-label">
          {label}
          {required && <span className="text-[var(--color-error)] ml-1" aria-hidden="true">*</span>}
        </label>
      )}
      
      <select
        id={id}
        value={value}
        onChange={handleChange}
        disabled={disabled}
        aria-invalid={!!error}
        aria-describedby={error ? errorId : undefined}
        className={`
          glass-select
          ${error ? 'border-[var(--color-error)] focus:border-[var(--color-error)]' : ''}
          ${disabled ? 'opacity-50 cursor-not-allowed' : ''}
        `}
      >
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      
      {error && (
        <p id={errorId} role="alert" className="mt-1 text-xs text-[var(--color-error)]">
          {error}
        </p>
      )}
    </div>
  )
}

export default GlassInput