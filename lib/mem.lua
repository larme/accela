local class = require('middleclass')

local _m = {}

local Mem = class('Mem')

function Mem:initialize(arg)
  assert(#arg == 2,
	 "Mem init error: levels or level_sizes not provided")

  self.levels = arg[1]
  self.level_sizes = arg[2]

  assert(#self.levels == #self.level_sizes,
	 "Mem init error: different length of levels and level_sizes")

  if arg.enable_undo then
    self.enable_undo = true
  else
    self.enable_undo = false
  end

  self._content = {}

  if self.enable_undo then
    self._undo_content = {}
  end

  self.total_size = 1
  for i, v in ipairs(self.level_sizes) do
    self.total_size = self.total_size * (v + 1)
  end
end

function Mem:__index(k)
  assert(k <= self.total_size,
	 "Mem access error: out of bound")

  local v = self._content[k]

  if not v then
    v = 0
  end

  return v
end

function Mem:__new_index(k, v)
  assert(k <= self.total_size,
	 "Mem access error: out of bound")

  if self.enable_undo then
    old_v = self._content[k]
    self._undo_content[k] = old_v
  end

  self._content[k] = v
end

function Mem:clear()
  if self.enable_undo then
    self._undo_content = self._content
  end
  self._content = {}
end

_m.Mem = Mem

return _m
