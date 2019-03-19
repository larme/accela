function wrap(n, a, b)
  interval = b + 1 - a
  return (n - a) % interval + a
end
