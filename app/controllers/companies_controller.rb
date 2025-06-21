
    class CompaniesController < ApplicationController
      before_action :authenticate_user!

      def show_profile
        render json: {
          id: current_user.id,
          email: current_user.email,
          role: current_user.role,
          address: current_user.address,
          phone_1: current_user.phone_1,
          phone_2: current_user.phone_2,
          website: current_user.website,
          about: current_user.about,
          company_name: current_user.company_name,
          company_avatar_url: current_user.company_avatar&.url,
          phone: current_user.phone,
          telegram: current_user.telegram,
          whatsapp: current_user.whatsapp,
          instagram: current_user.instagram,
          logo_urls: current_user.company_logos.order(:position).map do |logo|
            {
              id: logo.id,
              url: logo.image_url,
              position: logo.position
            }
          end,
          created_at: current_user.created_at,
          created_date: current_user.created_at.strftime('%d/%m/%Y')
        }
      end

      def show
        user = User.find(params[:id])

        render json: {
          id: user.id,
          company_name: user.company_name,
          phone: user.phone,
          telegram: user.telegram,
          whatsapp: user.whatsapp,
          instagram: user.instagram,
          logo_url: user.company_logos.order(:position).map(&:image_url)
        }
      end


      def update_profile
        if params[:company_logos].present?
          current_count = current_user.company_logos.count
          new_files = params[:company_logos]

          if current_count + new_files.size > 6
            return render json: { error: "Можно загрузить не более 6 изображений" }, status: :unprocessable_entity
          end

          new_files.each_with_index do |file, i|
            position = params[:positions]&.dig(i.to_s)&.to_i || (current_user.company_logos.maximum(:position).to_i + 1)
            current_user.company_logos.create!(image: file, position: position)
          end
        end

        if params[:company_avatar].present?
          current_user.company_avatar = params[:company_avatar]
        end

        if current_user.update(profile_params)
          render json: serialize_profile(current_user)
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end




      private

      def profile_params
        params.permit(:company_name, :whatsapp, :telegram, :instagram, :website,
                      :about,
                      :address, phone_1: [:number, :label],
                      phone_2: [:number, :label]
        )
      end

      def serialize_profile(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          company_name: user.company_name,
          phone_1: user.phone_1,
          phone_2: user.phone_2,
          whatsapp: user.whatsapp,
          telegram: user.telegram,
          instagram: user.instagram,
          website: user.website,
          about: user.about,
          company_avatar_url: user.company_avatar&.url,
          address: user.address,
          logo_urls: user.company_logos.order(:position).map do |logo|
            {
              id: logo.id,
              url: logo.image_url,
              position: logo.position
            }
          end,
          created_at: user.created_at,
          created_date: user.created_at.strftime('%d/%m/%Y')
        }
      end

    end
