module Ar
  class RolesController < ApplicationController
    before_action :set_role, only: [:show, :edit, :update, :remove]

    # GET /roles
    def index
      @roles = role_finder.all
      respond_with(@roles)
    end

    # GET /roles/1
    def show
      respond_with(@role)
    end

    # GET /roles/new
    def new
      @role = Ar::Entities::Role.new
      all_resources
    end

    # GET /roles/1/edit
    def edit
      all_resources
    end

    # POST /roles
    def create
      role_creator.create({role: role_params}, {
        success: -> (role) {
          redirect_to role_path(role.id), notice: I18n.t('flash.actions.create_role.notice')
        },
        fail: -> (error) {
          @role = Ar::Entities::Role.new(role_params)
          @error = error
          all_resources
          render :new
        }
      })
    end

    # PATCH/PUT /roles/1
    def update
      role_updater.update({role: role_params}, {
        success: -> (role) {
          redirect_to role_path(role.id), notice: I18n.t('flash.actions.update_role.notice')
        },
        fail: -> (error) {
          @role = Ar::Entities::Role.new(role_params)
          @error = error
          all_resources
          render :edit
        }
      })
    end

    # DELETE /roles/1
    def remove
      role_remover.remove({role: @role}, {
        success: -> (role) {
          redirect_to roles_path, notice: I18n.t('flash.actions.remove_role.notice')
        },
        fail: -> (error) {
          redirect_to roles_path, notice: I18n.t('flash.actions.remove_role.alert')
        }
      })

    end

    private

    def role_creator
      @role_creator ||= Ar::Services::Roles::RoleManagerCreator.new
    end

    def role_updater
      @role_updater ||= Ar::Services::Roles::RoleManagerUpdater.new
    end

    def role_remover
      @role_remover ||= Ar::Services::Roles::RoleManagerRemover.new
    end

    def role_finder
      @role_finder ||= Ar::Repositories::Roles::Finder.new
    end

    def resource_finder
      @resource_finder ||= Ar::Repositories::Resources::Finder.new
    end

    def all_resources
      @resources = resource_finder.all
    end

    def set_role
      @role = role_finder.find(params[:id])
    end

    def role_params
      params.require(:role).
        permit(:id, :name, :description, action_ids: [])
    end

  end
end
