'use client'

import * as React from 'react'
import { useTranslation } from 'react-i18next'

import { toast } from 'sonner'
import { LucideIcon } from '@/lib/lucide-icon'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'

import { useSWRConfig } from 'swr'
import { fetcher } from '@/lib/utils'
import { useAuth } from '@/hooks/use-auth'
import { EmailsAPI } from '@/types/api'
import { Email } from '@/types/database'

interface DeleteEmailProps {
  item: Email
}

const DeleteEmail = (props: DeleteEmailProps) => {
  const { item } = props

  const { t } = useTranslation()
  const { user } = useAuth()
  const { mutate } = useSWRConfig()

  const [isSubmitting, setIsSubmitting] = React.useState<boolean>(false)

  const handleClick = async () => {
    try {
      setIsSubmitting(true)

      if (!user) throw new Error('Require is not defined.')
      if (!item) throw new Error('Require is not defined.')

      const fetchUrl = `/api/v1/email?userId=${user?.id}`
      const result = await fetcher<EmailsAPI>(fetchUrl, {
        method: 'DELETE',
        body: JSON.stringify({
          data: { email: item?.email },
        }),
      })

      if (result?.error) throw new Error(result?.error?.message)

      mutate(`/api/v1/email/list?userId=${user?.id}`)

      toast.success(t('FormMessage.deleted_successfully'))
    } catch (e: unknown) {
      toast.error((e as Error)?.message)
    } finally {
      setIsSubmitting(false)
    }
  }

  if (item?.email === user?.email) return null

  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button
          variant="outline"
          className="h-auto p-1.5 text-destructive hover:bg-destructive hover:text-white"
          disabled={isSubmitting}
        >
          <LucideIcon name="Trash" className="size-4 min-w-4" />
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>
            {t('DeleteEmail.AlertDialogTitle')}
          </AlertDialogTitle>
          <AlertDialogDescription>
            {t('DeleteEmail.AlertDialogDescription')}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>
            {t('DeleteEmail.AlertDialogCancel')}
          </AlertDialogCancel>
          <AlertDialogAction onClick={handleClick}>
            {t('DeleteEmail.AlertDialogAction')}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}

export { DeleteEmail }