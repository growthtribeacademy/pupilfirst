require 'rails_helper'

feature "Level progression check", js: true do
  include UserSpecHelper
  include SubmissionsHelper
  include NotificationHelper

  let(:course) { create :course, :unlimited }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:team) { create :startup, level: level_1 }
  let(:student) { team.founders.first }
  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }
  let(:target_group_l3) { create :target_group, level: level_3 }
  let!(:target_l1) { create :target, :with_markdown, target_group: target_group_l1  }
  let!(:target_l2_1) { create :target, :with_markdown, target_group: target_group_l2 }
  let!(:target_l2_2) { create :target, :with_markdown, target_group: target_group_l2 }
  let!(:target_l3) { create :target, :with_markdown, target_group: target_group_l3 }

  def complete_target(target)
    sign_in_user student.user, referrer: target_path(target)
    click_button 'Mark As Complete'
    dismiss_notification
  end


  it "perform student level up" do
    Flipper.enable_actor :auto_level_up, course

    complete_target(target_l1)
    expect(student.reload.level.number).to eq(2)
  end

  it "does not perform student level up if feature is disabled" do
    Flipper.disable_actor :auto_level_up, course

    complete_target(target_l1)
    expect(student.reload.level.number).to eq(1)
  end

  it "does not perform student level up if this is the last level" do
    Flipper.enable_actor :auto_level_up, course

    complete_target(target_l1)
    complete_target(target_l2_1)
    complete_target(target_l2_2)

    complete_target(target_l3)
    expect(student.reload.level.number).to eq(3)
  end

  it "perform student level up only after all targets are completed" do
    Flipper.enable_actor :auto_level_up, course

    complete_target(target_l1)

    complete_target(target_l2_1)
    expect(student.reload.level.number).to eq(2)

    complete_target(target_l2_2)
    expect(student.reload.level.number).to eq(3)
  end

  context "skip is course progression behavior is not unlimited" do
    let(:course) { create :course, :strict }

    it "does nothing" do
      Flipper.enable_actor :auto_level_up, course

      complete_target(target_l1)
      expect(student.reload.level.number).to eq(1)
    end
  end
end