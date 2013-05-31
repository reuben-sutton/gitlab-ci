module API
  # Issues API
  class Builds < Grape::API
    resource :builds do
      # Register a build by runner
      #
      # Parameters:
      #   token (required) - The uniq token of runner
      #
      # Example Request:
      #   POST /builds/register
      post "register" do
        required_attributes! [:token]

        ActiveRecord::Base.transaction do
          build = Build.pending.order('created_at ASC').first
          not_found! and return unless build

          build.run!
          present build, with: Entities::Build
        end
      end

      # Update an existing build
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   state (optional) - The state of a build
      #   output (optional) - The trace of a build
      # Example Request:
      #   PUT /builds/:id
      put ":id" do
        build = Build.find(params[:id])
        build.update_attributes trace: params[:trace]

        case params[:state].to_s
        when 'success'
          build.success
        when 'failed'
          build.drop
        end
      end
    end
  end
end