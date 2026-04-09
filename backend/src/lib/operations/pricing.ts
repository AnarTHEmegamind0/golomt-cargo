import type { CargoPricingMethod } from "~/db/schema/constants/cargo";
import { PRICING_RULES } from "~/lib/constants/pricing";

export const calculateCargoPricing = (input: {
  weightGrams: number;
  heightCm: number;
  widthCm: number;
  lengthCm: number;
  isFragile: boolean;
  overrideFeeMnt?: number | null;
}) => {
  const weightKg = input.weightGrams / 1000;
  const volumeCbm = (input.heightCm * input.widthCm * input.lengthCm) / 1_000_000;
  const weightBasedFeeMnt = Math.ceil(weightKg * PRICING_RULES.weightRatePerKgMnt);
  const rate = input.isFragile
    ? PRICING_RULES.fragileVolumeRatePerCbmMnt
    : PRICING_RULES.volumeRatePerCbmMnt;
  const volumeBasedFeeMnt = Math.ceil(volumeCbm * rate);
  const calculatedFeeMnt = Math.max(
    PRICING_RULES.minimumFeeMnt,
    weightBasedFeeMnt,
    volumeBasedFeeMnt
  );

  let method: CargoPricingMethod = "WEIGHT";
  if (volumeBasedFeeMnt > weightBasedFeeMnt) {
    method = input.isFragile ? "FRAGILE_VOLUME" : "VOLUME";
  }

  return {
    weightKg,
    volumeCbm,
    weightBasedFeeMnt,
    volumeBasedFeeMnt,
    calculatedFeeMnt,
    finalFeeMnt: input.overrideFeeMnt ?? calculatedFeeMnt,
    method,
  };
};
