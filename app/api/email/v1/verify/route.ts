import { NextResponse, type NextRequest } from 'next/server'
import { authorize } from '@/lib/supabase/auth'
import { createClient } from '@/lib/supabase/server'
import { jwtVerify } from '@/lib/jsonwebtoken'

interface TokenPayload {
  user_id: string
  email: string
}

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const next = searchParams.get('next') ?? '/'
  const redirectTo = request.nextUrl.clone()
  redirectTo.pathname = next

  const token_hash = searchParams.get('token_hash') ?? ''
  const token = jwtVerify(token_hash)

  if (token?.error) {
    return new Response(token?.error?.name, { status: 401 })
  }

  const payload = token?.payload as TokenPayload
  const { isAuthorized } = await authorize(payload?.user_id)

  if (!isAuthorized) {
    return new Response('Unauthorized', { status: 401 })
  }

  try {
    const data = { email_confirmed_at: new Date().toISOString() }
    const supabase = createClient()
    const response = await supabase
      .from('emails')
      .update(data)
      .eq('user_id', payload?.user_id)
      .eq('email', payload?.email)

    if (response?.error) throw new Error(response?.error?.message)

    return NextResponse.redirect(redirectTo)
  } catch (e: unknown) {
    return new Response((e as Error)?.message, { status: 400 })
  }

  // return the user to an error page with some instructions
  // redirectTo.pathname = '/errors/400'
  // return NextResponse.redirect(redirectTo)
}