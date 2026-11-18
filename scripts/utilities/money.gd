class_name Money
extends RefCounted
## Utilitas format Rupiah: 1250000 -> "Rp 1.250.000".


static func format(amount: int) -> String:
	var negative: bool = amount < 0
	var digits: String = str(absi(amount))
	var result: String = ""
	var count: int = 0
	for i: int in range(digits.length() - 1, -1, -1):
		result = digits[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "." + result
	return ("-Rp " if negative else "Rp ") + result


static func short(amount: int) -> String:
	if absi(amount) >= 1000000:
		return "Rp %.1fjt" % (amount / 1000000.0)
	if absi(amount) >= 1000:
		return "Rp %dk" % floori(amount / 1000.0)
	return "Rp %d" % amount
