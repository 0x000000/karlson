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
  end

  describe BaseRender do
    let(:root_dir) { File.expand_path(File.join(File.expand_path(__FILE__), '..', '..', '..')) }
    subject { TestFooBarLang::FooBaz.new }

    it do
      expect(LangsRegistry.template_langs).to eq({'test_foo_bar_lang' => [
        {
          name:       'foo_baz',
          find_query: "#{root_dir}/lib/karlson/writers/test_foo_bar_lang/foo_baz.*.erb",
          path:       nil
        }
      ]})
    end

    context 'for child instances' do
      describe '#initialize' do
        let(:expected_path) { "#{root_dir}/lib/karlson/writers/test_foo_bar_lang/foo_baz.test.erb" }

        before { LangsRegistry.template_langs['test_foo_bar_lang'][0][:path] = expected_path }

        it 'assigns options and template path by default' do
          expect(subject.options).to eq({erb: '%<>-'})
          expect(subject.template_path).to eq expected_path
        end
      end

      describe '#render' do
        let(:template_path) { File.join(File.dirname(__FILE__), 'base_render_test_template.txt.erb') }

        before { LangsRegistry.template_langs['test_foo_bar_lang'][0][:path] = template_path }

        it 'renders template with binding to the string' do
          expect(subject.render).to eq "Hello, 777!\n"
        end
      end
    end
  end

end
