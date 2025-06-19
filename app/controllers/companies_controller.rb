
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
          phone: current_user.phone,
          telegram: current_user.telegram,
          whatsapp: current_user.whatsapp,
          instagram: current_user.instagram,
          logo_url: current_user.company_logo&.url,
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
          logo_url: user.company_logo&.url
        }
      end


      def update_profile
        if params[:company_logos].present?
          current_user.company_logos.destroy_all # если нужно перезаписать
          params[:company_logos].each_with_index do |uploaded_file, i|
            current_user.company_logos.create!(image: uploaded_file, position: i)
          end
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
          address: user.address,
          logo_urls: user.company_logos.order(:position).map(&:image_url),
          created_at: user.created_at,
          created_date: user.created_at.strftime('%d/%m/%Y')
        }
      end

    end
