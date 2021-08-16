require 'rails_helper'

RSpec.describe SegmentSnippet do
  describe "#setup_segment_head" do
    specify do
      segment = SegmentSnippet.new('MY_WRITE_KEY')

      expect(segment.setup_segment_head).to include('MY_WRITE_KEY')
    end

    specify do
      segment = SegmentSnippet.new(nil)

      expect(segment.setup_segment_head).to be_nil
    end
  end

  it do
    allow(ENV).to receive(:[]).with('SEGMENT_WRITE_KEY').and_return('MY_WRITE_KEY')
    segment = SegmentSnippet.new
    expect(segment.setup_segment_head).to include('MY_WRITE_KEY')
  end
end
