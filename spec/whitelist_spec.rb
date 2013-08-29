require 'rspec'
require 'whitelist'


describe 'Whitelist' do
  context 'valid configurations' do

    let(:good_guys){ %w[good@example.com a@good.com b@good.com] }
    let(:bad_guys ){ %w[ bad@example.com a@bad.com ] }
    let(:config_obj){ %w[ good@example.com *good.com]}
    let(:config_proc){ ->(){ return config_obj} }
    let(:whitelist_obj ){ Whitelist::List.new(config_obj)}
    let(:whitelist_proc) { Whitelist::List.new(config_proc) }
    let(:new_guy) { "a@new.com"}
    let(:new_config){ %w{ "a@new.com"}}

    shared_examples_for 'whitelist checker' do
      it 'allows authorized' do
        good_guys.each do |gg|
          expect(list.check(gg)).to equal(gg)
        end
      end

      it 'does not allow unauthorized' do
        bad_guys.each do |bad|
          expect(list.check(bad)).to equal(false)
        end
      end
    end

    context 'configuration with object' do
      it_behaves_like 'whitelist checker' do
        let(:list){ whitelist_obj }
      end
    end

    context 'configuration with proc' do
      it_behaves_like 'whitelist checker' do
        let(:list){ whitelist_proc }
      end
    end

  end
end