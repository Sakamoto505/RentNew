
    class CompaniesController < ApplicationController
      before_action :authenticate_user!

      def show_profile
        render json: {
          id: current_user.id,
          email: current_user.email,
          role: current_user.role,
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
        current_user.company_logo = params[:company_logo] if params[:company_logo].present?

        if current_user.update(profile_params)
          render json: serialize_profile(current_user)
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.permit(:company_name, :phone, :whatsapp, :telegram, :instagram)
      end

      def serialize_profile(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          company_name: user.company_name,
          phone: user.phone,
          whatsapp: user.whatsapp,
          telegram: user.telegram,
          instagram: user.instagram,
          logo_url: user.company_logo&.url,
          created_at: user.created_at,
          created_date: user.created_at.strftime('%d/%m/%Y')
        }
      end
      end
