import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth, logout } from 'wasp/client/auth';
import { useState } from 'react';
import { 
  LayoutDashboard, 
  FileText, 
  ShoppingCart, 
  CheckCircle, 
  Settings,
  LogOut,
  User,
  Building2,
  Users,
  Menu,
  X,
  DollarSign,
} from 'lucide-react';

export default function NavBar() {
  const navigate = useNavigate();
  const location = useLocation();
  const { data: user } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [adminDropdownOpen, setAdminDropdownOpen] = useState(false);
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  if (!user) {
    return null;
  }

  const isAdmin = user.isAdmin || user.role === 'ADMIN';

  const navItems = [
    { 
      name: 'Dashboard', 
      path: '/dashboard', 
      icon: LayoutDashboard 
    },
    { 
      name: 'Invoices', 
      path: '/invoices', 
      icon: FileText 
    },
    { 
      name: 'Purchase Orders', 
      path: '/purchase-orders', 
      icon: ShoppingCart 
    },
    { 
      name: 'Approvals', 
      path: '/approvals', 
      icon: CheckCircle 
    },
  ];

  const isActive = (path: string) => {
    if (path === '/dashboard') {
      return location.pathname === '/dashboard' || location.pathname === '/admin';
    }
    return location.pathname === path || location.pathname.startsWith(path + '/');
  };

  return (
    <nav className="border-b bg-white sticky top-0 z-50 shadow-sm">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <div 
            className="flex items-center gap-2 cursor-pointer"
            onClick={() => navigate('/dashboard')}
          >
            <Building2 className="h-7 w-7 text-blue-600" />
            <h1 className="text-lg font-bold hidden sm:block">
              <span className="text-blue-600">Invoice</span>
              <span className="text-gray-900">Flow</span>
            </h1>
          </div>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <button
                  key={item.path}
                  onClick={() => navigate(item.path)}
                  className={`
                    flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors
                    ${active 
                      ? 'bg-blue-600 text-white' 
                      : 'text-gray-700 hover:bg-gray-100'
                    }
                  `}
                >
                  <Icon className="h-4 w-4" />
                  {item.name}
                </button>
              );
            })}

            {/* Admin Dropdown - Click Based */}
            {isAdmin && (
              <div className="relative">
                <button 
                  onClick={() => {
                    setAdminDropdownOpen(!adminDropdownOpen);
                    setUserDropdownOpen(false);
                  }}
                  className="flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100 transition-colors"
                >
                  <Settings className="h-4 w-4" />
                  Admin
                </button>
                {adminDropdownOpen && (
                  <>
                    <div 
                      className="fixed inset-0 z-10" 
                      onClick={() => setAdminDropdownOpen(false)}
                    ></div>
                    <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border z-20">
                      <button
                        onClick={() => {
                          navigate('/admin/users');
                          setAdminDropdownOpen(false);
                        }}
                        className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        <Users className="h-4 w-4" />
                        Manage Users
                      </button>
                      <button
                        onClick={() => {
                          navigate('/admin/configuration');
                          setAdminDropdownOpen(false);
                        }}
                        className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        <Settings className="h-4 w-4" />
                        Configuration
                      </button>
                    </div>
                  </>
                )}
              </div>
            )}
          </div>

          {/* User Menu */}
          <div className="flex items-center gap-2">
            {/* Mobile menu button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 rounded-md text-gray-700 hover:bg-gray-100"
            >
              {mobileMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>

            {/* Desktop User Dropdown */}
            <div className="hidden md:block relative">
              <button 
                onClick={() => {
                  setUserDropdownOpen(!userDropdownOpen);
                  setAdminDropdownOpen(false);
                }}
                className="flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100"
              >
                <User className="h-4 w-4" />
                <span className="hidden lg:inline max-w-[150px] truncate">
                  {user.username || user.email}
                </span>
              </button>
              {userDropdownOpen && (
                <>
                  <div 
                    className="fixed inset-0 z-10" 
                    onClick={() => setUserDropdownOpen(false)}
                  ></div>
                  <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border z-20">
                    <button
                      onClick={() => {
                        navigate('/account');
                        setUserDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      <User className="h-4 w-4" />
                      Account Settings
                    </button>
                    <button
                      onClick={() => {
                        navigate('/pricing');
                        setUserDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2 px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      <DollarSign className="h-4 w-4" />
                      Pricing
                    </button>
                    <div className="border-t"></div>
                    <button
                      onClick={() => {
                        handleLogout();
                        setUserDropdownOpen(false);
                      }}
                      className="w-full flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                    >
                      <LogOut className="h-4 w-4" />
                      Logout
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden border-t bg-white">
          <div className="px-2 pt-2 pb-3 space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <button
                  key={item.path}
                  onClick={() => {
                    navigate(item.path);
                    setMobileMenuOpen(false);
                  }}
                  className={`
                    w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium
                    ${active 
                      ? 'bg-blue-600 text-white' 
                      : 'text-gray-700 hover:bg-gray-100'
                    }
                  `}
                >
                  <Icon className="h-4 w-4" />
                  {item.name}
                </button>
              );
            })}

            {/* Admin Section */}
            {isAdmin && (
              <>
                <div className="border-t my-2"></div>
                <div className="px-3 py-2 text-xs font-semibold text-gray-500 uppercase">
                  Admin
                </div>
                <button
                  onClick={() => {
                    navigate('/admin/users');
                    setMobileMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100"
                >
                  <Users className="h-4 w-4" />
                  Manage Users
                </button>
                <button
                  onClick={() => {
                    navigate('/admin/configuration');
                    setMobileMenuOpen(false);
                  }}
                  className="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100"
                >
                  <Settings className="h-4 w-4" />
                  Configuration
                </button>
              </>
            )}

            {/* User Section */}
            <div className="border-t my-2"></div>
            <button
              onClick={() => {
                navigate('/account');
                setMobileMenuOpen(false);
              }}
              className="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100"
            >
              <User className="h-4 w-4" />
              Account Settings
            </button>
            <button
              onClick={() => {
                navigate('/pricing');
                setMobileMenuOpen(false);
              }}
              className="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100"
            >
              <DollarSign className="h-4 w-4" />
              Pricing
            </button>
            <button
              onClick={() => {
                handleLogout();
                setMobileMenuOpen(false);
              }}
              className="w-full flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium text-red-600 hover:bg-gray-100"
            >
              <LogOut className="h-4 w-4" />
              Logout
            </button>
          </div>
        </div>
      )}
    </nav>
  );
}

// Export type for compatibility
export type NavigationItem = {
  name: string;
  to: string;
};
