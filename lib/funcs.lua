-- functions are objects
-- funcs with fix argument number (arg_num >= 0) can be used as opcode
-- opcode_only for opcode_only functions

-- set mem-type(reg/ram) level 1 level 2 offset

local class = require('middleclass')

local _m = {}

local funcs_table = {}
local opcodes_table = {}

local max_func_id = 0

local Func = class('Func')

function Func:initialize(arg)
  if #arg ~= 2 then
    error("Func init error: no name or arg_num!")
  end

  self.name = arg[1]
  self.arg_num = arg[2]

  self.id = arg.id
  if not self.id then
    self.id = max_func_id + 1
    max_func_id = self.id
  end

  if arg.opcode_only and self.arg_num < 0 then
    error("Func init error: arg_num < 0 cannot coexist with opcode_only=true")
  end

  if not arg.opcode_only then
    funcs_table[self.name] = self
    funcs_table[self.id] = self
  end

  if self.arg_num >= 0 then
    opcodes_table[self.name] = self
    opcodes_table[self.id] = self
  end

  return self
end

_m.funcs_table = funcs_table
_m.opcodes_table = opcodes_table
_m.Func = Func
return _m
