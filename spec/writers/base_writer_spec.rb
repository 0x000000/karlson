require 'spec_helper'

module Karlson::Writers
  module TestFooBarLang
    class FooBaz < Karlson::Writers::BaseRender
      def var_1
        'Hello'
      end

      def var_2
        777
      end
    end

    class Writer < Karlson::Writers::BaseWriter
      def write!
        super({
                'enums'     => {
                  'file_name' => FooBaz
                },
                'packs'     => {
                  nothing_here: {}
                },
                'libs'      => nil,
                '.metadata' => FooBaz
              })
      end
    end
  end

  module OtherTestLang
    class BrokenWriter < Karlson::Writers::BaseWriter
      def write!
        super
      end
    end
  end

  describe BaseWriter do
    let(:options) { {} }
    subject { BaseWriter.new options }

    it do
      expect(LangsRegistry.available_langs['test_foo_bar_lang']).to eq(TestFooBarLang::Writer)
      expect(LangsRegistry.available_langs['other_test_lang']).to eq(OtherTestLang::BrokenWriter)
    end

    describe '.initialize' do
      let(:options) { {foo: 1} }

      it 'sets options' do
        expect(subject.options).to eq options
      end
    end

    it { expect { OtherTestLang::BrokenWriter.new.write! }.to raise_error ArgumentError }

    describe '.write!' do
      let(:template_path) { File.join(File.dirname(__FILE__), 'base_render_test_template.txt.erb') }

      let(:command_count) { 6 } # create 2 files + 4 dirs
      let(:goto_instructions_count) { 2 } # enter dir + exit dir

      subject { TestFooBarLang::Writer.new }

      before { LangsRegistry.template_langs['test_foo_bar_lang'][0][:path] = template_path }
      before { subject.write! }

      it 'registers commands' do
        expect(subject.commands.size).to eq(command_count + 3 * goto_instructions_count)                           # unix-like pseudocode (with full paths for readability)
                                                                                                                   # ________________
                                                                                                                   #
        expect(subject.commands[0 ]).to eq [:create_dir, 'enums']                                                  # mkdir ./enums
        expect(subject.commands[1 ]).to eq [:goto_dir, 'enums']                                                    # cd ./enums
        expect(subject.commands[2 ]).to eq [:create_file, 'file_name', Karlson::Writers::TestFooBarLang::FooBaz]   # touch ./enums/file_name
        expect(subject.commands[3 ]).to eq [:goto_dir, :back]                                                      # cd ./enums/..
                                                                                                                   #
        expect(subject.commands[4 ]).to eq [:create_dir, 'packs']                                                  # mkdir ./packs
        expect(subject.commands[5 ]).to eq [:goto_dir, 'packs']                                                    # cd ./packs
        expect(subject.commands[6 ]).to eq [:create_dir, 'nothing_here']                                           # mkdir ./packs/nothing_here
        expect(subject.commands[7 ]).to eq [:goto_dir, 'nothing_here']                                             # cd ./packs/nothing_here
        expect(subject.commands[8 ]).to eq [:goto_dir, :back]                                                      # cd ./packs/nothing_here/..
        expect(subject.commands[9 ]).to eq [:goto_dir, :back]                                                      # cd ./packs/..
                                                                                                                   #
        expect(subject.commands[10]).to eq [:create_dir, 'libs']                                                   # mkdir ./libs
                                                                                                                   #
        expect(subject.commands[11]).to eq [:create_file, '.metadata', Karlson::Writers::TestFooBarLang::FooBaz]   # touch .metadata
      end
    end
  end
end
