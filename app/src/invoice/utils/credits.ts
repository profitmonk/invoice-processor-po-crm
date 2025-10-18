export async function checkAndDeductCredit(userId: string, entities: any): Promise<boolean> {
  const user = await entities.User.findUnique({
    where: { id: userId },
    select: { credits: true },
  });

  if (!user || user.credits <= 0) {
    return false;
  }

  // Deduct one credit
  await entities.User.update({
    where: { id: userId },
    data: { credits: user.credits - 1 },
  });

  return true;
}

export async function addCredits(userId: string, amount: number, entities: any): Promise<void> {
  await entities.User.update({
    where: { id: userId },
    data: {
      credits: {
        increment: amount,
      },
    },
  });
}
