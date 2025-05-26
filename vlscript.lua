local vlscript = {}

function vlscript.tokenize(words)
    local tokens = {}
    for word in string.gmatch(words, "%S+") do tokens[#tokens + 1] = word end
    return tokens
end

function vlscript.buildAST(tokens)
    local ast = {}

    local function walk(tokens)
        local token = table.remove(tokens, 1)
        if not token then return nil end

        if token == "let" then
            local name = walk(tokens)
            local value = walk(tokens)
            return { type = "let", name = name, value = value }
        elseif token == "define" then
            local name = walk(tokens)
            local bodyTokens = walk(tokens)
            return { type = "define", name = name, body = bodyTokens }
        elseif token == "if" then
            local condition = {
                walk(tokens),
                walk(tokens),
                walk(tokens),
            }
            local body = walk(tokens)
            return { type = "if", condition = condition, body = body }
        elseif token == "add" then
            local destVar = walk(tokens)
            local left = walk(tokens)
            local right = walk(tokens)
            return { type = "add", destVar = destVar, left = left, right = right }
        elseif token == "sub" then
            local destVar = walk(tokens)
            local left = walk(tokens)
            local right = walk(tokens)
            return { type = "sub", destVar = destVar, left = left, right = right }
        elseif token == "halt" then
            return { type = "halt" }
        elseif token == "call" then
            local destCall = walk(tokens)
            return { type = "call", destCall = destCall }
        elseif token == "jump" then
            local destLocation = walk(tokens)
            return { type = "jump", destLocation = destLocation }
        elseif token == "{" then
            local body = {}
            while tokens[1] and tokens[1] ~= "}" do
                local stmt = walk(tokens)
                if stmt then table.insert(body, stmt) end
            end
            table.remove(tokens, 1)
            return body
        else
            return token
        end
    end

    local function walkBody(section, body)
        ast[section] = {}
        for _, node in ipairs(body) do
            table.insert(ast[section], node)
        end
    end

    ast.main = {}

    while #tokens > 0 do
        local node = walk(tokens)
        if node then table.insert(ast.main, node) end
    end

    return ast
end

function vlscript.compile(ast)
    local bytecode = {}
    local labels = {}

    local function parseBlock(astBlock)
        for _, block in ipairs(astBlock) do
            if block.type == "define" then
                labels[block.name] = #bytecode
                bytecode[#bytecode + 1] = { "PUSHENV" }
                parseBlock(block.body)
                bytecode[#bytecode + 1] = { "POPENV" }
            elseif block.type == "if" then
                local cond = block.condition
                local labelElse = "endif_" .. tostring(#bytecode + 1)

                local numLeft = tonumber(cond[2])
                local numRight = tonumber(cond[3])
                if numLeft then
                    bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", numLeft }
                else
                    bytecode[#bytecode + 1] = { "PUSH_VARIABLE", cond[2] }
                end
                if numRight then
                    bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", numRight }
                else
                    bytecode[#bytecode + 1] = { "PUSH_VARIABLE", cond[3] }
                end

                bytecode[#bytecode + 1] = { "CMP" }

                bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", labelElse }
                if cond[1] == "=" then
                    bytecode[#bytecode + 1] = { "JUMP_IF_NONEQUAL" }
                elseif cond[1] == "!=" then
                    bytecode[#bytecode + 1] = { "JUMP_IF_EQUAL" }
                end

                bytecode[#bytecode + 1] = { "PUSHENV" }

                parseBlock(block.body)

                bytecode[#bytecode + 1] = { "POPENV" }

                labels[labelElse] = #bytecode
            elseif block.type == "sub" then
                local leftNum = tonumber(block.left)
                local rightNum = tonumber(block.right)
                if rightNum then
                    bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", rightNum }
                else
                    bytecode[#bytecode + 1] = { "PUSH_VARIABLE", block.right }
                end
                if leftNum then
                    bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", leftNum }
                else
                    bytecode[#bytecode + 1] = { "PUSH_VARIABLE", block.left }
                end
                bytecode[#bytecode + 1] = { "SUB" }
                bytecode[#bytecode + 1] = { "SET", block.destVar }
            elseif block.type == "let" then
                bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", tonumber(block.value) }
                bytecode[#bytecode + 1] = { "SET", block.name }
            elseif block.type == "jump" then
                bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", labels[block.destLocation] }
                bytecode[#bytecode + 1] = { "JUMP" }
            elseif block.type == "call" then
                bytecode[#bytecode + 1] = { "PUSH_IMMEDIATE", block.destCall }
                bytecode[#bytecode + 1] = { "CALL" }
            elseif block.type == "halt" then
                bytecode[#bytecode + 1] = { "HALT" }
            end
        end
    end

    parseBlock(ast.main)

    local refinedBytecode = {}
    for _,byte in ipairs(bytecode) do
        if byte[1] ~= "PUSH_IMMEDIATE" then
            refinedBytecode[#refinedBytecode+1] = byte
        else
            if type(byte[2]) == "string" then
                refinedBytecode[#refinedBytecode+1] = {byte[1], labels[byte[2]]}
            else
                refinedBytecode[#refinedBytecode+1] = byte
            end
        end
    end

    return refinedBytecode
end

return vlscript
