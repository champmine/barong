# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    user_uid { FactoryBot.create(:user).uid }
    user_ip { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    topic { %w[session password otp].sample }
    action { %w[otp::enable login logout].sample }
    result { %w[succeed failed].sample }
    data { {data: Faker::Lorem.sentence(3, true, 4)}.to_json }
  end
end
