import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'

// Design tokens + UI system
import './styles/index.css'

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
