import React, { useState } from 'react'
import * as htmlToImage from 'html-to-image'
import jsPDF from 'jspdf'
import { GlassButton } from './glass/GlassButton'

/**
 * GlassExportPanel - Export functionality with glass styling
 */
const ExportPanel: React.FC = () => {
  const [exporting, setExporting] = useState(false)

  async function handleExport() {
    const node = document.getElementById('export-area')
    if (!node) {
      alert('No se encontró el área para exportar')
      return
    }
    
    setExporting(true)
    try {
      // Generate image from the node
      const dataUrl = await (htmlToImage as any).toPng(node, { 
        cacheBust: true, 
        pixelRatio: 2,
        backgroundColor: '#F5F7FB' // Use the base background color
      })
      
      const pdf = new jsPDF('p', 'mm', 'a4')
      const imgProps = pdf.getImageProperties(dataUrl)
      const pdfWidth = pdf.internal.pageSize.getWidth()
      const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width

      const pageHeight = pdf.internal.pageSize.getHeight()
      if (pdfHeight <= pageHeight) {
        pdf.addImage(dataUrl, 'PNG', 0, 0, pdfWidth, pdfHeight)
      } else {
        // Scale to fit page height
        pdf.addImage(dataUrl, 'PNG', 0, 0, pdfWidth, pageHeight)
      }

      pdf.save('MMkk_Report.pdf')
    } catch (e) {
      console.error(e)
      alert('Error al exportar a PDF: ' + String(e))
    } finally {
      setExporting(false)
    }
  }

  return (
    <div>
      <GlassButton
        variant="primary"
        onClick={handleExport}
        loading={exporting}
        className="w-full"
      >
        {exporting ? 'Exportando...' : 'Exportar a PDF'}
      </GlassButton>
    </div>
  )
}

export default ExportPanel
