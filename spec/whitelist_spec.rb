require 'rspec'
require 'whitelist'

require 'psych'


describe 'Whitelist' do
  let(:default_config){ ["*@yamladmin.com", "yaml@yaml.com"] }
  let(:config_obj){ %w[ good@example.com *good.com]}
  let(:config_proc){ ->(){ return config_obj} }
  let(:good_list){ %w[good@example.com a@good.com b@good.com] }
  let(:bad_list ){ %w[ bad@example.com a@bad.com ] }

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


  context 'valid configurations' do
    let(:whitelist_obj ){ Whitelist::List.new(config_obj)}
    let(:whitelist_proc) { Whitelist::List.new(config_proc) }

    let(:new_guy) { "a@new.com"}
    let(:new_config){ %w{ "a@new.com"}}



    context 'configuration with object' do
      it_behaves_like 'whitelist checker' do
        let(:list){ whitelist_obj }
        let(:good_guys){ good_list }
        let(:bad_guys){ bad_list }
      end
    end

    context 'configuration with proc' do
      it_behaves_like 'whitelist checker' do
        let(:list){ whitelist_proc }
        let(:good_guys){ good_list }
        let(:bad_guys){ bad_list }
      end
    end
  end

  context 'changing object updates validation' do
    let!(:init_obj){ config_obj }
    let(:init_list){ Whitelist::List.new(init_obj)}
    let(:new_checkee){ 'me@myadmin.com'}

    it_behaves_like 'whitelist checker' do
      let(:list){ init_list }
      let(:good_guys){ good_list }
      let(:bad_guys){ bad_list }
    end

    it 'updates to new object' do
      expect(init_list.check 'me@myadmin.com').to be(false)
      init_obj << new_checkee
      expect(init_list.check new_checkee).to be(new_checkee)
      init_obj.delete(new_checkee)
      expect(init_list.check 'me@myadmin.com').to be(false)
    end

  end

  context 'valid yaml configurations' do


    let(:config_proc){ ->(){ Psych.load_file(File.join(File.dirname(__FILE__), 'config.yml')) } }
    let(:whitelist_yaml) { Whitelist::List.new(config_proc) }
    let(:good_yaml_list){ %w[yaml@yaml.com a@yamladmin.com b@yamladmin.com] }
    let(:bad_yaml_list ){ %w[ bad@yaml.com a@bad.com ] }

    #let(:new_guy) { "a@new.com"}
    #let(:new_config){ %w{ "a@new.com"}}



    context 'configuration with yaml proc' do
      it_behaves_like 'whitelist checker' do
        let(:list){ whitelist_yaml }
        let(:good_guys){ good_yaml_list }
        let(:bad_guys){ bad_yaml_list }
      end
    end


    context 'changing yaml file updates validation' do
      let(:yaml_file){ File.join(File.dirname(__FILE__), 'config.yml')}

      let(:yaml_obj) { Psych.load_file(yaml_file) }
      let(:config_proc){ ->(){ Psych.load_file(yaml_file) } }
      let(:whitelist_yaml) { Whitelist::List.new(config_proc) }



      context 'changing yaml file' do

        before(:each) do
          yaml = Psych.dump(default_config)
          File.open(yaml_file, "w"){|f| f.write yaml}
        end

        after(:each) do
          yaml = Psych.dump(default_config)
          File.open(yaml_file, "w"){|f| f.write yaml}
        end

        let(:new_good_list){ ['a@newyaml.com', 'b@newyaml.com']}

        it 'updates the whitelist' do
          good_yaml_list.each do |gg|
            expect(whitelist_yaml.check(gg)).to equal(gg)
          end
          bad_yaml_list.each do |gg|
            expect(whitelist_yaml.check(gg)).to equal(false)
          end

          new_yaml_str = Psych.dump(new_good_list)
          File.open(yaml_file,"w"){|f| f.write new_yaml_str}

          good_yaml_list.each do |gg|
            expect(whitelist_yaml.check(gg)).to equal(false)
          end
          bad_yaml_list.each do |gg|
            expect(whitelist_yaml.check(gg)).to equal(false)
          end

        end
      end
    end

  end


  context 'invalid configuration' do
    let(:invalid_hash){ {:good => good_list, :bad => bad_list} }

    shared_examples_for 'invalid config obj' do
      it 'warns that it was the wrong obj' do
        expect(error_obj).to receive(:warn).once.with(WhitelistError.not_array_msg(config_obj))
        expect(error_obj).to receive(:warn).once.with(WhitelistError.trying_again_msg)
        expect{ Whitelist::List.new(config_obj)}.to raise_error
      end
    end

    it_behaves_like "invalid config obj" do
      let(:error_obj) { WhitelistError}
      let(:config_obj){ invalid_hash }
    end

    context 'initialization (no prior config object)' do
      it 'is wrong object' do
        expect{Whitelist::List.new(invalid_hash)}.to raise_error(WhitelistError::NoConfigAvailable)
      end

      it 'is nil' do
        expect{Whitelist::List.new(nil)}.to raise_error(WhitelistError::NoConfigAvailable)
      end
    end

    context 'initialized with valid config file, but config changed to invalid form' do
      before(:each) do
        yaml = Psych.dump(default_config)
        File.open(yaml_file, "w"){|f| f.write yaml}
      end

      after(:each) do
        yaml = Psych.dump(default_config)
        File.open(yaml_file, "w"){|f| f.write yaml}
      end

      let(:yaml_file){ File.join(File.dirname(__FILE__), 'config.yml')}
      let(:config_proc){ ->(){ Psych.load_file(yaml_file) } }
      let(:whitelist_yaml) { Whitelist::List.new(config_proc) }
      let(:good_yaml_list){ %w[yaml@yaml.com a@yamladmin.com b@yamladmin.com] }
      let(:bad_yaml_list ){ %w[ bad@yaml.com a@bad.com ] }

      it 'uses previous valid config when invalid config used' do

        good_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(gg)
        end

        bad_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(false)
        end

        bad_yaml_str = "---\nyaml@yaml.com\n*@yamladmin.com"
        File.open(yaml_file,"w"){|f| f.write bad_yaml_str}
        bad_yaml = Psych.load(bad_yaml_str)

        expect(WhitelistError).to receive(:warn).at_least(2).times

        good_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(gg)
        end

        bad_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(false)
        end
      end

      it 'uses previous valid config when config file deleted' do

        good_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(gg)
        end

        bad_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(false)
        end

        File.delete(yaml_file)

        expect(WhitelistError).to receive(:warn).at_least(2).times

        good_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(gg)
        end

        bad_yaml_list.each do |gg|
          expect(whitelist_yaml.check(gg)).to equal(false)
        end

      end
    end
  end
end