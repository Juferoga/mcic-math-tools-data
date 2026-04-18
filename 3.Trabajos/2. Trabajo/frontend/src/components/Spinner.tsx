import React from 'react'

const Spinner: React.FC<{ size?: number }> = ({ size = 48 }) => {
  return (
    <div className="flex items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-blue-600"></div>
    </div>
  )
}

export default Spinner
