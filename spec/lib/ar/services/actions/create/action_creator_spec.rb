require 'spec_helper'

describe Ar::Services::Actions::Create::ActionCreator, type: :service, fast: true do

  let(:action_entity_class) { Ar::Entities::Action }
  let(:action)              { double }
  let(:resource)            { double id: 1 }
  let(:actions_names)       { ['index', 'new'] }
  let(:params)              { {resource: resource, actions_names: actions_names} }

  let(:actions_created) { subject.create_many(params) }
  let(:validator_class) { Ar::Validators::ActionValidator }
  let(:validator)       { instance_double validator_class }

  before do
    allow(validator_class).to receive(:new).with(action).and_return(validator)
    allow(action_entity_class).to receive(:new).and_return(action)
  end

  describe 'creating a new action' do

    context 'when resource is invalid' do
      let(:errors) { instance_double('ActiveModel::Errors') }

      before do
        allow(validator).to receive(:valid?).and_return false
        allow(validator).to receive(:errors).and_return(errors)
        allow(errors).to receive(:messages)
      end

      it 'should raise a Ar::Exceptions::RecordInvalid with :errors of ActiveModel::Errors' do
        expect { actions_created }.to raise_error { |error|
          expect(error).to be_a Ar::Exceptions::RecordInvalid
          expect(error.errors).not_to be_nil
        }
      end

    end

    context 'when resource is valid' do
      let(:creator_repo_class) { Ar::Repositories::Actions::Creator }
      let(:creator_repo)       { instance_double creator_repo_class }

      before do
        allow(validator).to receive(:valid?).and_return true
        allow(creator_repo_class).to receive(:new).and_return(creator_repo)
        allow(creator_repo).to receive(:create).with(action)
        actions_created
      end

      it 'creator repository should call :new' do
        expect(creator_repo_class).to have_received(:new).once
      end

      it 'creator_repo should call create method with action as parameter' do
        expect(creator_repo).to have_received(:create).with(action).twice
      end

      context 'when build an instance of action' do

        it 'entity action should call new method' do
          expect(action_entity_class).to have_received(:new).with({resource: resource, name: 'index'}).once
          expect(action_entity_class).to have_received(:new).with({resource: resource, name: 'new'}).once
        end

      end

    end

  end

end
