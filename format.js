const format = str => {
  const regex = /\s/g;
  return str.replace(regex, "")
}

const string = `if (value != current_value) {
  if (current_value == original_value) {
    if (original_value != 0 and value == 0) {
      gas_refunds += 4800
    }
  } else {
    if (original_value != 0) {
      if (current_value == 0) {
        gas_refunds -= 4800
      } else if (value == 0) {
        gas_refunds += 4800
      }
    } if (value == original_value) {
      if (original_value == 0) {
        if (key is warm) {
          gas_refunds += 20000 - 100
        } else {
          gas_refunds += 19900
        }
      } else {
        if (key is warm) {
          gas_refunds += 5000 - 2100 - 100
        } else {
          gas_refunds += 4900
        }
      }
    }
  }
}`;

console.log(format(string));