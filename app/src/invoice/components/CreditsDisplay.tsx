import { Button } from '../../components/ui/button';
import { Card, CardContent } from '../../components/ui/card';
import { CreditCard, Zap } from 'lucide-react';

interface CreditsDisplayProps {
  credits: number;
  onBuyCredits: () => void;
}

export function CreditsDisplay({ credits, onBuyCredits }: CreditsDisplayProps) {
  return (
    <Card className="bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200">
      <CardContent className="p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="bg-white p-2 rounded-full">
              <Zap className="h-5 w-5 text-blue-600" />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-600">Processing Credits</p>
              <p className="text-2xl font-bold text-gray-900">{credits}</p>
            </div>
          </div>
          {credits < 5 && (
            <Button onClick={onBuyCredits} size="sm">
              <CreditCard className="h-4 w-4 mr-2" />
              Buy More
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
