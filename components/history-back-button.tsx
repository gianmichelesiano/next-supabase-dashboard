'use client'

import * as React from 'react'
import { useRouter } from 'next/navigation'
import { useTranslation } from 'react-i18next'
import { icons } from 'lucide-react'

import { LucideIcon } from '@/lib/lucide-icon'
import { Button, ButtonProps } from '@/components/ui/button'

export interface HistoryBackButtonProps
  extends ButtonProps,
    React.ButtonHTMLAttributes<HTMLButtonElement> {
  title?: string
  startIconName?: keyof typeof icons
  endIconName?: keyof typeof icons
}

export function HistoryBackButton({
  children,
  startIconName,
  endIconName,
  title = 'Back',
  ...props
}: HistoryBackButtonProps) {
  const router = useRouter()
  const { t } = useTranslation()

  return (
    <Button onClick={() => router.back()} {...props}>
      {startIconName && (
        <LucideIcon name={startIconName} className="mr-2 size-4" />
      )}
      {title ? t(title) : children}
      {endIconName && <LucideIcon name={endIconName} className="ml-2 size-4" />}
    </Button>
  )
}
