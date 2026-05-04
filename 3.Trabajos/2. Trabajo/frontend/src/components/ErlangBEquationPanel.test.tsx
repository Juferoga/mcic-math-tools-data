import { afterEach, describe, expect, it } from 'vitest'
import { cleanup, render, screen } from '@testing-library/react'
import ErlangBEquationPanel from './ErlangBEquationPanel'

afterEach(() => {
  cleanup()
})

describe('ErlangBEquationPanel', () => {
  it('renders formula title and substituted values for valid inputs', () => {
    render(<ErlangBEquationPanel lam={2} mu={1} k={3} pBlocking={0.21053} />)

    expect(screen.getByText(/Ecuación de Erlang-B/i)).toBeInTheDocument()
    expect(screen.getByText(/Interpretación:/i)).toBeInTheDocument()
  })

  it('keeps panel visible with symbolic fallback for invalid inputs', () => {
    render(<ErlangBEquationPanel lam={2} mu={0} k={3} />)

    expect(screen.getByText(/Ecuación de Erlang-B/i)).toBeInTheDocument()
    expect(screen.getByText(/sin cola de espera/i)).toBeInTheDocument()
  })
})
