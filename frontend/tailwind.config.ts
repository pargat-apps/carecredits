// frontend/tailwind.config.ts
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        background: '#FCF9F4',
        surface: {
          lowest: '#FFFFFF', low: '#F6F3EE', DEFAULT: '#F0EDE9',
          high: '#EBE8E3', highest: '#E5E2DD', dim: '#DCDAD5', inverse: '#31302D',
        },
        ink:   { DEFAULT: '#1C1C19', variant: '#44474C', inverse: '#F3F0EB' },
        line:  { DEFAULT: '#75777D', variant: '#C5C6CC' },
        brand: { DEFAULT: '#000000', on: '#FFFFFF', navy: '#101C2B', onNavy: '#798498' },
        teal:  { DEFAULT: '#006A62', on: '#FFFFFF', container: '#83F2E5', onContainer: '#006F67' },
        deep:  { DEFAULT: '#00201C', on: '#009485', glow: '#62FAE3' },
        hero:  { start: '#071322', end: '#11998E' },     // promoted from literals
        ok:    { container: '#DCFCE7', on: '#166534' },   // F-2
        warn:  { DEFAULT: '#B45309' },                     // F-2
        danger:{ DEFAULT: '#BA1A1A', container: '#FFDAD6', onContainer: '#93000A' },
      },
      fontFamily: {
        display: ['"Space Grotesk"', 'system-ui', 'sans-serif'],
        body:    ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'label-caps':    ['12px', { lineHeight: '1',   letterSpacing: '0.05em', fontWeight: '600' }],
        'body-md':       ['15px', { lineHeight: '1.5' }],
        'body-lg':       ['17px', { lineHeight: '1.6' }],
        'number-display':['24px', { lineHeight: '1',   fontWeight: '700' }],
        'headline-md':   ['24px', { lineHeight: '1.3', fontWeight: '600' }],
        'headline-lg':   ['32px', { lineHeight: '1.2', letterSpacing: '-0.01em', fontWeight: '600' }],
        'headline-xl':   ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em', fontWeight: '700' }],
        'number-hero':   ['60px', { lineHeight: '1',   letterSpacing: '-0.02em', fontWeight: '700' }],
        'senior-body':   ['24px', { lineHeight: '1.5' }],
        'senior-tile':   ['32px', { lineHeight: '1.2', fontWeight: '600' }],
      },
      borderRadius: { sm:'4px', DEFAULT:'8px', md:'12px', lg:'16px', xl:'24px' },
      spacing: { 'stack-sm':'8px','stack-md':'16px','stack-lg':'24px',
                 gutter:'24px','container-margin':'32px','section-gap':'64px' },
      boxShadow: {
        e1:      '0 1px 8px rgba(0,0,0,0.04)',
        'e1-up': '0 -1px 8px rgba(0,0,0,0.04)',
        e2:      '0 10px 25px -5px rgba(7,19,34,0.04)',
        e3:      '0 20px 50px -10px rgba(0,0,0,0.3)',
        teal:    '0 4px 12px rgba(0,106,98,0.2)',
        glow:    '0 0 40px rgba(131,242,229,0.4)',
        selected:'inset 0 0 0 2px #006A62, 0 10px 30px -5px rgba(0,106,98,0.2)',
      },
      backgroundImage: {
        hero:      'linear-gradient(to bottom right,#071322,#11998E)',
        'hero-rev':'linear-gradient(to bottom right,#11998E,#071322)',
        balance:   'linear-gradient(to bottom right,#101C2B,#006A62)',
        cta:       'linear-gradient(to right,#000000,#006A62)',
        dots:      'radial-gradient(circle at 2px 2px, rgba(255,255,255,0.4) 1px, transparent 0)',
      },
      backgroundSize: { dots: '32px 32px' },
      maxWidth: { content: '1280px' },
      transitionDuration: { micro:'150ms', panel:'240ms', page:'360ms' },
    },
  },
}
