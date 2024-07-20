import * as React from 'react'

interface SiteLogoProps extends React.SVGProps<SVGSVGElement> {}

const SiteLogo = ({
  xmlns = 'http://www.w3.org/2000/svg',
  width = '1024',
  height = '1024',
  viewBox = '0 0 1024 1024',
  ...props
}: SiteLogoProps) => {
  return (
    <svg
      xmlns={xmlns}
      width={width}
      height={height}
      viewBox={viewBox}
      {...props}
    >
      <path
        fill="#66B814"
        d="M512 4.098C231.95 4.098 4.098 231.949 4.098 512c0 280.05 227.851 507.902 507.902 507.902 280.055 0 507.902-227.851 507.902-507.902C1019.902 231.95 792.055 4.098 512 4.098zm0 0"
      />
      <path
        fill="#ffffff"
        d="M584.066 585.809c-3.785-31.157-15.632-72.903-26.793-103.778-2.992-8.258-10.242-18.32-17.476-30.508-9.766-16.433-21.235-28.52-23.524-25.593-4.015 5.117 15.555 57.601 25.211 84.922 22.868 64.761 30.496 170.375 16.47 238.05-8.727 42.121-31.153 79.496-3.79 83.43 28.57 4.05 30.356-30.512 32.922-53.8 6.691-61.708 5.555-120.712-3.02-192.723zm-144.55-184.66c-10.973.214-38.942 1.359-64.582 8.937-31.09 9.18-74.91 26.535-101.961 61.766-27.078 35.16-31.543 78.53.449 107.878 33.039 30.415 73.203 16.348 93.703 4.883 0 0-12.375 84.594 58.438 99.332 62.015 9.34 102.73-48.84 98.433-127.625-3.922-72.222-19.055-108.96-24.867-114.113-7.3-6.45-15.953-6.094-29.809 11.691-12.218 15.711-74.718 97.653-74.718 97.653s49.082-94.535 63.148-114.785c16.297-23.516 10.152-28.172 4.86-31.121-6.653-3.758-15.458-4.622-23.094-4.497v.001zm78.527-32.231c8.535-10.129 36.59-29.098 60.68-40.664 38.07-18.223 78.726-35.953 123.023-38.512 47.625-2.687 88.55 29.543 81.93 72.457-6.75 44.43-44.371 51.246-67.563 55.11 0 0 77.14 38.59 39.184 102.976-36.832 62.528-115.125 49.356-173.008-8.832-23.59-23.719-34.476-44.418-44.441-56.719-12.028-14.78-18.567-18.12-21.047-22.043-1.438-2.265-1.153-6.82-.77-8.441 1.14-5.059 2.996-13.832 22.766-11.813 21.668 2.145 57.695 1.754 57.695 1.754s9.848-.406-66.637-16.148c-27.054-7.898-18.148-21.66-11.812-29.125zm-7.336-3.684c5.875-11.847 15.016-41.546 8.918-67.59-8.793-37.472-16.469-51.84-32.074-73.753-25.746-36.125-53.594-48.22-89.844-36.313-42.727 13.93-53.156 50.633-47.488 73.457 0 0-63.496-23.758-96.469 40.684-25.5 57.34 35.93 91.633 91.363 93.5 91.25 3.11 106.989-.574 112.399-4.426 6.547-4.668 7.523-13.57-5.606-28.484-13.191-14.93-63.265-55.395-63.265-55.395s44.757 15.11 90.64 59.059c17.973 21.687 27.098 8.07 31.426-.739zm0 0"
      />
    </svg>
  )
}

export { SiteLogo, type SiteLogoProps }
