import { useNavigate } from 'react-router-dom';
import { useAuth } from 'wasp/client/auth';
import { useEffect } from 'react';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Badge } from '../components/ui/badge';
import {
  FileText,
  ShoppingCart,
  CheckCircle,
  BarChart3,
  Building2,
  Zap,
  Users,
  TrendingUp,
  ArrowRight,
  Clock,
  DollarSign,
  Shield,
  AlertTriangle,
  FileCheck,
  Target,
} from 'lucide-react';

export default function LandingPage() {
  const navigate = useNavigate();
  const { data: user } = useAuth();

  // If logged in, redirect to dashboard
  useEffect(() => {
    if (user) {
      navigate('/dashboard');
    }
  }, [user, navigate]);

  const features = [
    {
      icon: <Zap className="h-8 w-8" />,
      title: 'AI-Powered OCR',
      description: 'Upload invoices from any vendor. AI extracts vendor, amount, date, line items, and GL codes with 99% accuracy—no manual data entry.',
      color: 'text-blue-600',
      bgColor: 'bg-blue-50',
    },
    {
      icon: <AlertTriangle className="h-8 w-8" />,
      title: 'Smart Discrepancy Detection',
      description: 'AI compares invoice amounts to PO amounts automatically. Flags price differences, quantity mismatches, and duplicates before you pay.',
      color: 'text-red-600',
      bgColor: 'bg-red-50',
    },
    {
      icon: <ShoppingCart className="h-8 w-8" />,
      title: 'Purchase Order Management',
      description: 'Create POs with multi-level approval workflows. Set thresholds by property, amount, and expense type.',
      color: 'text-green-600',
      bgColor: 'bg-green-50',
    },
    {
      icon: <FileCheck className="h-8 w-8" />,
      title: 'Duplicate Prevention',
      description: 'AI identifies duplicate invoices across your entire portfolio. Never pay the same vendor invoice twice.',
      color: 'text-purple-600',
      bgColor: 'bg-purple-50',
    },
    {
      icon: <Building2 className="h-8 w-8" />,
      title: 'Multi-Property Tracking',
      description: 'Track expenses by property, region, or asset class. Roll up to portfolio level or drill down to individual units.',
      color: 'text-orange-600',
      bgColor: 'bg-orange-50',
    },
    {
      icon: <Target className="h-8 w-8" />,
      title: 'Budget vs. Actual',
      description: 'Set budgets by property and GL code. Real-time alerts when spending approaches thresholds.',
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-50',
    },
    {
      icon: <Shield className="h-8 w-8" />,
      title: 'Audit Trail & Compliance',
      description: 'Complete approval history and document trail for every transaction. SOX and audit-ready reporting built in.',
      color: 'text-teal-600',
      bgColor: 'bg-teal-50',
    },
    {
      icon: <BarChart3 className="h-8 w-8" />,
      title: 'Real-Time Analytics',
      description: 'Dashboard shows spending by property, vendor, GL code, and category. See your true NOI instantly.',
      color: 'text-pink-600',
      bgColor: 'bg-pink-50',
    },
  ];

  const workflow = [
    {
      step: '1',
      title: 'Create Purchase Orders',
      description: 'Set approval thresholds by property, amount, and expense type. Multi-level approvals route automatically.',
      icon: <ShoppingCart className="h-6 w-6" />,
    },
    {
      step: '2',
      title: 'AI Reads Invoices',
      description: 'Upload vendor invoices—HVAC, landscaping, utilities, CapEx. AI extracts every detail with 99% accuracy.',
      icon: <Zap className="h-6 w-6" />,
    },
    {
      step: '3',
      title: 'Smart Matching & Alerts',
      description: 'AI matches invoices to POs automatically. Flags price differences, quantity mismatches, and duplicates before you pay.',
      icon: <AlertTriangle className="h-6 w-6" />,
    },
    {
      step: '4',
      title: 'Track in Real-Time',
      description: 'Dashboard shows spending by property, vendor, GL code. Finally see your true NOI instantly.',
      icon: <BarChart3 className="h-6 w-6" />,
    },
  ];

  const stats = [
    { label: 'OCR Accuracy', value: '99%' },
    { label: 'Hours Saved Weekly', value: '15+' },
    { label: 'Manual Data Entry', value: 'Zero' },
  ];

  const targetAudience = [
    '✓ Multifamily Operators (apartments, senior living, student housing)',
    '✓ Commercial Property Managers (office, coworking, flex space)',
    '✓ Retail Property Owners (shopping centers, strip malls)',
    '✓ Industrial Real Estate (warehouses, distribution centers)',
    '✓ REITs & Institutional Owners (multi-asset portfolios)',
    '✓ Property Management Firms (third-party operators)',
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="border-b sticky top-0 z-50 bg-white/80 backdrop-blur-sm">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="flex h-16 items-center justify-between">
            <div className="flex items-center gap-2">
              <Building2 className="h-8 w-8 text-blue-600" />
              <h1 className="text-2xl font-bold">
                <span className="text-blue-600">Invoice</span>
                <span className="text-gray-900">Flow</span>
              </h1>
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" onClick={() => navigate('/login')}>
                Sign In
              </Button>
              <Button onClick={() => navigate('/signup')}>
                Get Started
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-blue-50 via-white to-purple-50 py-20 lg:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-3xl text-center">
            <Badge className="mb-6 bg-blue-600 text-white px-4 py-2">
              <Zap className="h-4 w-4 mr-2" />
              AI-Powered Real Estate Operations Platform
            </Badge>
            <h1 className="text-5xl font-bold tracking-tight text-gray-900 sm:text-7xl">
              Let AI Optimize Your Spend{' '}
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">
                While You Run Your Business
              </span>
            </h1>
            <p className="mt-6 text-xl leading-8 text-gray-600">
              Complete invoice and purchase order management for real estate portfolios. 
              AI-powered OCR, automated approvals, smart PO matching, and real-time 
              tracking—all in one platform.
            </p>
            <div className="mt-10 flex items-center justify-center gap-4">
              <Button size="lg" onClick={() => navigate('/signup')} className="text-lg px-8 py-6">
                Start Free Trial
                <ArrowRight className="ml-2 h-5 w-5" />
              </Button>
              <Button size="lg" variant="outline" onClick={() => navigate('/login')} className="text-lg px-8 py-6">
                Sign In
              </Button>
            </div>
            <p className="mt-6 text-sm text-gray-500">
              No credit card required • 14-day free trial • Setup in minutes
            </p>

            {/* Stats */}
            <div className="mt-16 grid grid-cols-3 gap-8">
              {stats.map((stat, index) => (
                <div key={index}>
                  <p className="text-4xl font-bold text-blue-600">{stat.value}</p>
                  <p className="mt-2 text-sm text-gray-600">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-gray-50">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              From PO to Payment in 4 Steps
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              AI handles the heavy lifting while you focus on your properties
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {workflow.map((step, index) => (
              <div key={index} className="relative">
                <div className="flex items-center gap-4 mb-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-blue-600 text-white text-xl font-bold">
                    {step.step}
                  </div>
                  <div className="text-blue-600">{step.icon}</div>
                </div>
                <h3 className="text-lg font-semibold mb-2">{step.title}</h3>
                <p className="text-gray-600">{step.description}</p>
                {index < workflow.length - 1 && (
                  <div className="hidden lg:block absolute top-6 left-full w-full border-t-2 border-dashed border-gray-300 -ml-4"></div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-20 bg-white">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Everything You Need to Control Spending
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Built for real estate operations teams
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <Card key={index} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className={`w-16 h-16 rounded-lg ${feature.bgColor} flex items-center justify-center mb-4`}>
                    <div className={feature.color}>{feature.icon}</div>
                  </div>
                  <CardTitle className="text-lg">{feature.title}</CardTitle>
                </CardHeader>
                <CardContent>
                  <CardDescription className="text-sm">{feature.description}</CardDescription>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Who It's For */}
      <section className="py-20 bg-gray-50">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Built for Real Estate Operators
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              From 10 units to 10,000+
            </p>
          </div>

          <div className="mx-auto max-w-3xl">
            <Card>
              <CardContent className="p-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {targetAudience.map((item, index) => (
                    <p key={index} className="text-gray-700 flex items-start gap-2">
                      <span className="text-green-600 font-bold">✓</span>
                      <span>{item.replace('✓ ', '')}</span>
                    </p>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Why Choose InvoiceFlow */}
      <section className="py-20 bg-white">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center mb-16">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Why Teams Choose InvoiceFlow
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card>
              <CardHeader>
                <Clock className="h-12 w-12 text-blue-600 mb-4" />
                <CardTitle>Save Time</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Process 100+ invoices per week with AI. Your team focuses on properties, not paperwork.
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <DollarSign className="h-12 w-12 text-green-600 mb-4" />
                <CardTitle>Prevent Overpayments</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  AI catches price differences, duplicate invoices, and unauthorized charges before you pay.
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <Shield className="h-12 w-12 text-purple-600 mb-4" />
                <CardTitle>Stay Compliant</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Complete audit trails, approval workflows, and SOX-ready reporting built in.
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <TrendingUp className="h-12 w-12 text-orange-600 mb-4" />
                <CardTitle>Scale Effortlessly</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600">
                  Same platform whether you manage 10 units or 10,000. Add properties without adding headcount.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-blue-600 to-purple-600">
        <div className="mx-auto max-w-7xl px-6 lg:px-8 text-center">
          <h2 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">
            Ready to Let AI Handle Your Invoices?
          </h2>
          <p className="mt-6 text-xl text-blue-100">
            Join real estate teams processing thousands of invoices every month
          </p>
          <div className="mt-10 flex items-center justify-center gap-4">
            <Button size="lg" variant="secondary" onClick={() => navigate('/signup')} className="text-lg px-8 py-6">
              Start Your Free Trial
              <ArrowRight className="ml-2 h-5 w-5" />
            </Button>
          </div>
          <p className="mt-6 text-sm text-blue-100">
            14-day free trial • No credit card required • Cancel anytime
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <div className="flex items-center gap-2 mb-4 md:mb-0">
              <Building2 className="h-6 w-6 text-blue-400" />
              <span className="text-xl font-semibold">InvoiceFlow</span>
            </div>
            <div className="flex gap-8 text-sm text-gray-400">
              <button onClick={() => navigate('/pricing')} className="hover:text-white transition">
                Pricing
              </button>
              <button onClick={() => navigate('/login')} className="hover:text-white transition">
                Sign In
              </button>
              <button onClick={() => navigate('/signup')} className="hover:text-white transition">
                Sign Up
              </button>
            </div>
          </div>
          <div className="mt-8 border-t border-gray-800 pt-8 text-center text-sm text-gray-400">
            <p>© 2024 InvoiceFlow. Built for real estate operations teams.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
