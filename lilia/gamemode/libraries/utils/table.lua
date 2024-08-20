--- Helper library for generating bars.
-- @class table

--- Sums all numerical values in a table.
-- @realm client
-- @tab tbl The table containing numerical values to sum
-- @return number The sum of all numerical values
function table.Sum(tbl)
    local sum = 0
    for _, v in pairs(tbl) do
        if isnumber(v) then
            sum = sum + v
        elseif istable(v) then
            sum = sum + lia.util.TableSum(v)
        end
    end
    return sum
end


--- Creates a lookup table from a list of values.
-- @realm client
-- @tab tbl The list of values to create a lookup table from
-- @return table A lookup table where the keys are the values from the input list
function table.Lookupify(tbl)
    local lookup = {}
    for _, v in pairs(tbl) do
        lookup[v] = true
    end
    return lookup
end