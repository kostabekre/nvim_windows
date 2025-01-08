return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require('lspconfig')
            local cmp_nvim_lsp = require('cmp_nvim_lsp')

            local capabilities = cmp_nvim_lsp.default_capabilities()

            lspconfig.gdscript.setup {
                capabilities = capabilities,
                filetypes = { "gdscript" }
            }

            lspconfig.lua_ls.setup {
                capabilities = capabilities,
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                            return
                        end
                    end

                    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT'
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                -- Depending on the usage, you might want to add additional paths here.
                                "${3rd}/luv/library"
                                -- "${3rd}/busted/library",
                            }
                            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                            -- library = vim.api.nvim_get_runtime_file("", true)
                        }
                    })
                end,
                settings = {
                    Lua = {}
                }
            }

            local util = require 'lspconfig.util'
            local csharp_ls_extended = require 'csharpls_extended'


            if vim.fn.has('unix') == 1 then
                lspconfig.csharp_ls.setup {
                    cmd = { 'csharp-ls' },
                    capabilities = capabilities,
                    handlers = {
                        ["textDocument/definition"] = csharp_ls_extended.handler,
                        ["textDocument/typeDefinition"] = csharp_ls_extended.handler,
                    },
                    root_dir = function(fname)
                        return util.root_pattern '*.sln' (fname) or util.root_pattern '*.csproj' (fname)
                    end,
                    filetypes = { 'cs' },
                    init_options = {
                        AutomaticWorkspaceInit = true,
                    },
                }
            else

            end
        end
    }
}
