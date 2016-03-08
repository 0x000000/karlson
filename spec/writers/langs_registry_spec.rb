require 'spec_helper'

module Karlson::Writers
  describe LangsRegistry do
    before { LangsRegistry.clear }

    context 'when LangsRegistry does not contain any langs' do
      it { expect(LangsRegistry.available_langs).to eq({}) }
      it { expect(LangsRegistry.requested_langs).to eq({}) }
      it { expect(LangsRegistry.template_langs).to eq({}) }
    end

    pending '#request_compilation'
    pending '#register_language'
    pending '#register_template'
    pending '#find_template'
    pending '#load_templates'
    pending '#write_all'
  end
end
