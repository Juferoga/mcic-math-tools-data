module.exports = {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        'aurora-1': '#0ff7d6',
        'aurora-2': '#9b8cff',
        'sunset-1': '#ff9a9e',
        'sunset-2': '#fad0c4',
        'glass-foreground': 'rgba(255,255,255,0.12)',
        'glass-border': 'rgba(255,255,255,0.18)'
      },
      backgroundImage: {
        'aurora-sunset': 'radial-gradient(600px 400px at 10% 20%, rgba(10,132,255,0.14) 0%, rgba(0,196,255,0.06) 10%, transparent 30%), radial-gradient(500px 300px at 90% 80%, rgba(255,154,154,0.12) 0%, rgba(250,208,196,0.04) 20%, transparent 40%), linear-gradient(180deg, rgba(12,12,13,0.85), rgba(12,12,13,0.65))'
      },
      boxShadow: {
        'glass-lg': '0 8px 32px rgba(31,38,135,0.37)',
        'glow-sm': '0 4px 24px rgba(154, 84, 255, 0.12), 0 0 18px rgba(10,132,255,0.08)'
      },
      backdropBlur: {
        xs: '4px',
        sm: '8px',
        md: '12px'
      }
    },
  },
  plugins: [],
}
