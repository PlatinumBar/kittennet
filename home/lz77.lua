---@diagnostic disable-next-line:missing-fields
m = {
  --[[@as kt_serialization]]
  serializer = _G.modules.sr,
}
---@diagnostic disable-line:inject-field

function m.zip(input, wnd, la)
  wnd = wnd or 2048
  la = la or 32
  local out = {}
  local n = #input
  local pos = 1
  while pos <= n do
    local best_off, best_len = 0, 0
    local max_search = math.min(wnd, pos - 1)
    for off = 1, max_search do
      local start = pos - off
      local len = 0
      while len < la and pos + len <= n and input:sub(start + len, start + len) == input:sub(pos + len, pos + len) do
        len = len + 1
      end
      if len > best_len then
        best_len = len
        best_off = off
        if best_len == la then break end
      end
    end
    local nextchar = input:sub(pos + best_len, pos + best_len)
    out[#out + 1] = { best_off, best_len, nextchar }
    pos = pos + best_len + (nextchar ~= '' and 1 or 0)
  end
  return m.serializer.serialize(out)
end

function m.deflate(codesstr)
  local codes = m.serializer.deserialize(codesstr)
  local t = {}
  for _, c in ipairs(codes) do
    local off, len, ch = c[1], c[2], c[3]
    if off == 0 then
      if ch ~= '' then t[#t + 1] = ch end
    else
      local start = #t - off + 1
      for i = 1, len do
        t[#t + 1] = t[start + i - 1]
      end
      if ch ~= '' then t[#t + 1] = ch end
    end
  end
  return table.concat(t)
end
