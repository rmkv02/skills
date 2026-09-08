"""Price computation for the checkout flow."""

from collections.abc import Mapping, Sequence

_DEFAULT_CURRENCY = "EUR"


class PriceError(Exception):
    """A price that the checkout flow cannot represent."""


def total_cents(
    line_items: Sequence[Mapping[str, int]],
    discount_ratio: float = 0.0,
    currency: str | None = None,
) -> int:
    """Sums line items and applies a discount.

    Args:
      line_items: Mappings with an integer `cents` key, one per basket line.
      discount_ratio: Fraction taken off the subtotal, between 0 and 1.
      currency: ISO 4217 code; `_DEFAULT_CURRENCY` when None.

    Returns:
      The rounded total in minor units.

    Raises:
      PriceError: The discount is outside [0, 1].
    """
    if not 0.0 <= discount_ratio <= 1.0:
        raise PriceError(f"Not a ratio: {discount_ratio=}")
    del currency  # Reserved for per-currency rounding rules.
    subtotal = sum(item["cents"] for item in line_items)
    return round(subtotal * (1.0 - discount_ratio))
