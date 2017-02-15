use Mix.Config

config :avatar, app_name: :avatar

if Mix.env in [:test, :docs] do
  config :avatar, app_name: :avatar
end
