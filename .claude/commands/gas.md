---
description: Gas snapshot and diff
---
Run `forge snapshot --diff .gas-snapshot` in contracts/.
Report only functions whose gas changed by more than 2%, as a table:
function, before, after, delta, likely cause.
