import { ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from 'wasp/client/auth';
import { cn } from '../../lib/utils';
import {
  LayoutDashboard,
  Users,
  Settings,
  FileText,
  Building2,
  LogOut,
  Menu,
  CheckCircle,  // Add this
} from 'lucide-react';
import { Button } from '../../components/ui/button';
import { useState } from 'react';
import { Sheet, SheetContent, SheetTrigger } from '../../components/ui/sheet';

interface AdminLayoutProps {
  children: ReactNode;
}

const navigationItems = [
  {
    name: 'Dashboard',
    href: '/admin',
    icon: LayoutDashboard,
  },
  {
    name: 'Users',
    href: '/admin/users',
    icon: Users,
  },
  {
    name: 'Configuration',
    href: '/admin/configuration',
    icon: Settings,
  },
  {
    name: 'Purchase Orders',
    href: '/purchase-orders',
    icon: FileText,
  },
  {
    name: 'Approvals',  // NEW
    href: '/approvals',
    icon: CheckCircle,  // Add this import: CheckCircle
  },
  {
    name: 'Invoices',
    href: '/invoices/manual',  // Changed to manual invoices
    icon: FileText,
  },
  {
    name: 'OCR Invoices',
    href: '/invoices',
    icon: FileText,
  },
];

export function AdminLayout({ children }: AdminLayoutProps) {
  const { data: user } = useAuth();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  if (!user) {
    return null;
  }

  const isActive = (href: string) => {
    if (href === '/admin') {
      return location.pathname === href;
    }
    return location.pathname.startsWith(href);
  };

  return (
    <div className="flex min-h-screen">
      <aside className="hidden lg:flex lg:flex-col lg:w-64 lg:fixed lg:inset-y-0 bg-card border-r">
        <div className="flex flex-col flex-1 min-h-0">
          <div className="flex items-center h-16 px-6 border-b">
            <Building2 className="h-6 w-6 text-primary" />
            <span className="ml-2 text-lg font-semibold">Admin Panel</span>
          </div>
          <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
            {navigationItems.map((item) => {
              const Icon = item.icon;
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={cn(
                    'flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors',
                    isActive(item.href)
                      ? 'bg-primary text-primary-foreground'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                  )}
                >
                  <Icon className="h-5 w-5 mr-3" />
                  {item.name}
                </Link>
              );
            })}
          </nav>
          <div className="flex-shrink-0 px-3 py-4 border-t">
            <div className="flex items-center">
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{user.email}</p>
                <p className="text-xs text-muted-foreground truncate">{user.role}</p>
              </div>
            </div>
            <Button
              variant="ghost"
              className="w-full mt-3 justify-start"
              onClick={() => {
                window.location.href = '/login';
              }}
            >
              <LogOut className="h-4 w-4 mr-2" />
              Sign out
            </Button>
          </div>
        </div>
      </aside>

      <div className="lg:hidden fixed top-0 left-0 right-0 z-50 flex items-center h-16 px-4 bg-card border-b">
        <Sheet open={mobileMenuOpen} onOpenChange={setMobileMenuOpen}>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon">
              <Menu className="h-6 w-6" />
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="w-64 p-0">
            <div className="flex flex-col h-full">
              <div className="flex items-center h-16 px-6 border-b">
                <Building2 className="h-6 w-6 text-primary" />
                <span className="ml-2 text-lg font-semibold">Admin Panel</span>
              </div>
              <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
                {navigationItems.map((item) => {
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.name}
                      to={item.href}
                      onClick={() => setMobileMenuOpen(false)}
                      className={cn(
                        'flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors',
                        isActive(item.href)
                          ? 'bg-primary text-primary-foreground'
                          : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                      )}
                    >
                      <Icon className="h-5 w-5 mr-3" />
                      {item.name}
                    </Link>
                  );
                })}
              </nav>
              <div className="flex-shrink-0 px-3 py-4 border-t">
                <div className="flex items-center">
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{user.email}</p>
                    <p className="text-xs text-muted-foreground truncate">{user.role}</p>
                  </div>
                </div>
              </div>
            </div>
          </SheetContent>
        </Sheet>
        <div className="flex-1 flex items-center justify-center">
          <Building2 className="h-6 w-6 text-primary" />
          <span className="ml-2 text-lg font-semibold">Admin Panel</span>
        </div>
      </div>

      <main className="flex-1 lg:pl-64">
        <div className="lg:pt-0 pt-16">
          {children}
        </div>
      </main>
    </div>
  );
}
