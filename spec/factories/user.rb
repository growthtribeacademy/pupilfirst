FactoryBot.define do
  factory :user, aliases: %w[actor recipient] do
    email { Faker::Internet.email(name: name) }
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    school { School.find_by(name: 'test') || create(:school, :current) }
    title { Faker::Lorem.words(number: 3).join(' ') }
    time_zone { ENV['SPEC_USER_TIME_ZONE'] || 'Asia/Kolkata' }
    external_id { 'c2896708-78c1-40f1-9f17-99f132335b47' }

    trait :with_password do
      password { Faker::Internet.password(min_length: 8, max_length: 16) }
      password_confirmation { |user| user.password }
    end
  end
end
