import { LucideIconName } from '@/lib/lucide-icon'

export interface MiniDrawerItemProps {
  id: number
  href: string
  title: string
  iconName?: LucideIconName | undefined
  translate?: 'yes' | 'no' | undefined
  disabled?: boolean | undefined
  badge?: number | undefined
}

export interface MiniDrawerGroupItemProps {
  id: number
  items: MiniDrawerItemProps[]
  separator?: boolean | undefined
}

export interface DrawerItemProps {
  id: number
  href: string
  title: string
  iconName?: LucideIconName | undefined
  translate?: 'yes' | 'no' | undefined
  disabled?: boolean | undefined
}

export interface DrawerGroupItemProps {
  id: number
  label: string
  items: DrawerItemProps[]
  separator?: boolean | undefined
  translate?: 'yes' | 'no' | undefined
}

export interface DashboardConfig {
  miniDrawerGroupItems: MiniDrawerGroupItemProps[]
}

export interface MediaConfig {
  drawerGroupItems: DrawerGroupItemProps[]
}

export interface PostsConfig {
  drawerGroupItems: DrawerGroupItemProps[]
}

export interface SettingsConfig {
  drawerGroupItems: DrawerGroupItemProps[]
}
