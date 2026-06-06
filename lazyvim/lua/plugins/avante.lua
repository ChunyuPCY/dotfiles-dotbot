return {
  "yetone/avante.nvim",
  enabled = true,
  opts = {
    -- add any opts here
    -- for example
    provider = "deepseek",
    auto_suggestions_provider = "qianwen",
    providers = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-v4-pro",
        max_tokens = 8192,
        -- 🆕 V4 新增：思考模式参数(可选)
        extra_request_body = {
          reasoning_effort = "max",
        },
      },
      qianwen = {
        __inherited_from = "openai",
        api_key_name = "DASHSCOPE_API_KEY",
        endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1",
        model = "qwen3-coder-next",
        max_tokens = 8192,
      },
    },
  },
}
