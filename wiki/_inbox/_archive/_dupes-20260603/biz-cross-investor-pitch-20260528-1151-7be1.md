---
task_id: ec3548e7
title: [横断] 投資家向けピッチ1分版
model: qwen3.6:latest
completed: 2026-05-28 12:21:12
---

[
  {
    "type": "run_python_code",
    "code": "import math\n\n# Assumed assumptions (can be adjusted)\nannual_fixed_cost = 12_000_000  # JPY\ntotal_fund = 3_000_000_000  # JPY\n\nfor scenario in ['single', 'portfolio']:\n    total_revenue = 0\n    total_capex = 0\n    monthly = []\n    remaining_cap = total_fund\n    cum_profit = 0\n    \n    if scenario == 'single':\n        base_rev = [0]*4 + [20_000_000]*4 + [30_000_000]*4\n        base_exp = [annual_fixed_cost/12]*12\n        capex = total_fund * 0.6\n    else:\n        base_rev = [5_000_000]*4 + [10_000_000]*4 + [15_000_000]*4\n        base_exp = [annual_fixed_cost * 3 / 12]*12 # Triple fixed cost\n        capex = total_fund * 0.4  # Diversified, less per-project capex\n\n    for m in range(12):\n        r = base_rev[m]\n        e = base_exp[m]\n        profit = r - e\n        \n        if m == 0:\n            remaining_cap -= capex\n        \n        cum_profit += profit\n        remaining_cap += profit\n        monthly.append({'rev': r, 'exp': e, 'cum': cum_profit, 'cap': remaining_cap})\n        \n    print(f'--- {scenario} ---')\n    print(f\"Month 6 Cum Profit: {monthly[5]['cum']:>12,} | Cap: {monthly[5]['cap']:>12,}\")\n    print(f\"Month 12 Cum Profit: {monthly[11]['cum']:>12,} | Cap: {monthly[11]['cap']:>12,}\")"
  }
]