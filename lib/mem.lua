local class = require('middleclass')

local _m = {}

-- the conceptual layout of Mem: 

-- Like a hierarchy structure, each level will have a name like
-- "track", "step" etc. (which are stored in Mem.levels). Each level
-- will have fixed number of nodes, called order of this level (which
-- are stored in Mem.level_orders). Then nodes of the lowest level
-- will have a fixed number of memory cells. The number is stored in
-- Mem.unit_size
--
-- Because lua count from 1, nodes in a level will be numbered from 1
-- to n where n is the order of the given level. We will also have a
-- 0th node as a place to store meta data for this level. Hence the
-- total number of the nodes in a level is n + 1.

local Mem = class('Mem')

function Mem:initialize(arg)
  assert(#arg == 3,
	 "Mem init error: levels or level_orders or unit_size not provided")

  self.levels = arg[1]
  self.level_orders = arg[2]
  self.unit_size = arg[3]

  assert(#self.levels == #self.level_orders,
	 "Mem init error: different length of levels and level_orders")

  self.level_num = #self.levels

  if arg.enable_undo then
    self.enable_undo = true
  else
    self.enable_undo = false
  end

  self._content = {}

  if self.enable_undo then
    self._undo_content = {}
  end

  self.total_size = self.unit_size
  self.level_sizes = {}
  for i = #self.levels, 1, -1 do
    self.level_sizes[i] = self.total_size
    local order = self.level_orders[i]
    self.total_size = self.total_size * (order + 1)
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
    local old_v = self._content[k]
    self._undo_content[k] = old_v
  end

  self._content[k] = v
end

function Mem:clear_all()
  if self.enable_undo then
    self._undo_content = self._content
  end
  self._content = {}
end

function Mem:clear(arg)
  if not arg then
    self:clear_all()
    return
  end

  
end

function Mem:get_addr(arg)
  local idxs = {}
  if #arg > 0 then
    for i = 1, #arg do
      if i > self.level_num then
	break
      end
      idxs[i] = arg[i]
    end
  else
    for i, level_name in ipairs(self.levels) do
      idx = arg[level_name]
      if not idx then
	break
      end
      idxs[i] = idx
    end
  end

  -- TODO
  local level_orders_in_unit = {}
  local addr = 1
  for i, idx in ipairs(idxs) do
    addr = addr + idx * self.level_sizes[i]
  end
  offset = arg['offset'] or 0

  return addr + offset
end

_m.Mem = Mem

return _m
