import { describe, expect, it, vi } from 'vitest'
import { render, screen } from '@testing-library/react'

vi.mock('react-tooltip', () => ({
  Tooltip: () => null,
}))

import Sidebar from './Sidebar'

describe('Sidebar tooltips', () => {
  it('adds info tooltip bindings to key labels and demo buttons', () => {
    render(
      <Sidebar
        onSimulate={vi.fn()}
        onSensitivity={vi.fn()}
        loading={false}
      />,
    )

    const tooltipBound = document.querySelectorAll('[data-tooltip-id="sidebar-info-tooltip"]')
    expect(tooltipBound.length).toBeGreaterThanOrEqual(10)

    const infos = Array.from(tooltipBound).filter((node) => node.textContent?.includes('ⓘ'))
    expect(infos.length).toBeGreaterThanOrEqual(6)

    infos.forEach((info) => {
      expect(info).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')
      expect(info).toHaveAttribute('data-tooltip-content')
    })

    expect(screen.getByLabelText(/Tamaño de muestra/i)).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')
    expect(screen.getByLabelText(/^A mín$/i)).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')
    expect(screen.getByLabelText(/^A máx$/i)).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')

    expect(screen.getByRole('button', { name: /Baja Carga/i })).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')
    expect(screen.getByRole('button', { name: /Alta Carga/i })).toHaveAttribute('data-tooltip-id', 'sidebar-info-tooltip')
  })
})
