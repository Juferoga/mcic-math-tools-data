import React, { useState } from 'react'
import * as htmlToImage from 'html-to-image'
import jsPDF from 'jspdf'

const ExportPanel: React.FC = () => {
  const [exporting, setExporting] = useState(false)

  async function handleExport() {
    const node = document.getElementById('export-area')
    if (!node) return alert('No se encontró el área para exportar')
    setExporting(true)
    try {
      // generar imagen a partir del nodo
      const dataUrl = await (htmlToImage as any).toPng(node, { cacheBust: true, pixelRatio: 2 })
      const pdf = new jsPDF('p', 'mm', 'a4')
      const imgProps = pdf.getImageProperties(dataUrl)
      const pdfWidth = pdf.internal.pageSize.getWidth()
      const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width

      const pageHeight = pdf.internal.pageSize.getHeight()
      if (pdfHeight <= pageHeight) {
        pdf.addImage(dataUrl, 'PNG', 0, 0, pdfWidth, pdfHeight)
      } else {
        // escalar para ajustarse a la altura de la página
        pdf.addImage(dataUrl, 'PNG', 0, 0, pdfWidth, pageHeight)
      }

      pdf.save('MM1K_Report.pdf')
    } catch (e) {
      console.error(e)
      alert('Error al exportar a PDF: ' + String(e))
    } finally {
      setExporting(false)
    }
  }

  return (
    <div className="mt-4">
      <button onClick={handleExport} disabled={exporting} className="px-3 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 disabled:opacity-60">
        {exporting ? 'Exportando...' : 'Exportar APM + Gráficas a PDF'}
      </button>
    </div>
  )
}

export default ExportPanel
