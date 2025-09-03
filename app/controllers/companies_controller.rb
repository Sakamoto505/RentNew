
    class CompaniesController < ApplicationController
      before_action :authenticate_user!, except: [:company_names, :show]

      def show_profile
        Rails.logger.info "=== SHOW_PROFILE CALLED ==="
        Rails.logger.info "User ID: #{current_user.id}"
        Rails.logger.info "Company logos count: #{current_user.company_logos.count}"
        Rails.logger.info "=========================="

        render json: {
          id: current_user.id,
          email: current_user.email,
          role: current_user.role,
          address: current_user.address,
          phone_1: phone_with_label_check(current_user.phone_1),
          phone_2: phone_with_label_check(current_user.phone_2),
          website: current_user.website,
          about: current_user.about,
          company_name: current_user.company_name,
          company_avatar_url: current_user.company_avatar&.url,
          phone: current_user.phone,
          telegram: current_user.telegram,
          whatsapp: current_user.whatsapp,
          instagram: current_user.instagram,
          region: current_user.region,
          is_partner_verified: current_user.is_partner_verified || false,
          is_phone_verified: current_user.is_phone_verified || false,
          logo_urls: current_user.company_logos.order(:position).map do |logo|
            url = logo.image_url
            Rails.logger.info "=== COMPANY LOGO URL DEBUG ==="
            Rails.logger.info "Logo ID: #{logo.id}"
            Rails.logger.info "Generated URL: #{url}"
            Rails.logger.info "Image data: #{logo.image_data}"
            Rails.logger.info "Raw Shrine URL: #{logo.image&.url}"
            Rails.logger.info "================================"
            {
              id: logo.id,
              url: url,
              raw_url: logo.image&.url,
              position: logo.position,
              debug_data: logo.image_data
            }
          end,
          created_at: current_user.created_at,
          created_date: current_user.created_at.strftime('%d/%m/%Y')
        }
      end

      def show
        user = User.includes(:company_logos, cars: :car_images).find_by(company_name: params[:company_name])

        return render json: { error: 'Компания не найдена' }, status: :not_found unless user

        render json: {
          id: user.id,
          email: user.email,
          role: user.role,
          company_name: user.company_name,
          address: user.address,
          phone_1: phone_with_label_check(user.phone_1),
          phone_2: phone_with_label_check(user.phone_2),
          phone: user.phone,
          telegram: user.telegram,
          whatsapp: user.whatsapp,
          instagram: user.instagram,
          website: user.website,
          about: user.about,
          region: user.region,
          company_avatar_url: user.company_avatar&.url,
          is_partner_verified: user.is_partner_verified || false,
          is_phone_verified: user.is_phone_verified || false,
          logo_urls: user.company_logos.order(:position).map do |logo|
            {
              id: logo.id,
              url: logo.image_url,
              position: logo.position
            }
          end,
          created_at: user.created_at,
          created_date: user.created_at.strftime('%d/%m/%Y'),
          cars: user.cars.map do |car|
            {
              id: car.id,
              title: car.title,
              slug: car.slug,
              location: car.location,
              price: car.price,
              fuel_type: car.fuel_type,
              transmission: car.transmission,
              engine_capacity: car.engine_capacity,
              horsepower: car.horsepower,
              year: car.year,
              drive: car.drive,
              category: car.category,
              is_calendar: car.is_calendar,
              custom_fields: (car.custom_fields || {}).map { |k, v| { key: k, value: v } },
              car_images: car.car_images.order(:position).map do |img|
                {
                  id: img.id,
                  url: img.image_url,
                  position: img.position
                }
              end
            }
          end
        }
      end

      def company_names
        companies = User.where(role: [:client, :company])
                       .where.not(company_name: [nil, ""])
                       .select(:id, :company_name, :company_avatar_data, :updated_at)
                       .order(:company_name)

        render json: {
          companies: companies.map do |company|
            {
              id: company.id,
              company_name: company.company_name,
              company_avatar_url: company.company_avatar&.url,
              updated_at: company.updated_at
            }
          end
        }
      end

      def update_profile
        if params[:logo_positions].present?
          logo_positions = JSON.parse(params[:logo_positions])
          new_files = params[:company_logos] || []
          new_file_index = 0

          total_count = current_user.company_logos.count + new_files.size
          if total_count > 12
            return render json: { error: "Можно загрузить не более 12 изображений" }, status: :unprocessable_entity
          end

          logo_positions.each do |entry|
            if entry["id"].present?
              logo = current_user.company_logos.find_by(id: entry["id"])
              logo&.update(position: entry["position"])
            else
              # Создаём новый логотип
              file = new_files[new_file_index]
              new_file_index += 1

              current_user.company_logos.create!(
                image: file,
                position: entry["position"]
              )
            end
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
                      :about, :region, :company_avatar,
                      :address, phone_1: [:number, :label],
                      phone_2: [:number, :label]
        )
      end

      def phone_with_label_check(phone_data)
        return nil if phone_data.blank?
        phone_data
      end

      def serialize_profile(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          company_name: user.company_name,
          phone_1: phone_with_label_check(user.phone_1),
          phone_2: phone_with_label_check(user.phone_2),
          whatsapp: user.whatsapp,
          telegram: user.telegram,
          instagram: user.instagram,
          region: user.region,
          website: user.website,
          about: user.about,
          company_avatar_url: user.company_avatar&.url,
          address: user.address,
          is_partner_verified: user.is_partner_verified || false,
          is_phone_verified: user.is_phone_verified || false,
          logo_urls: user.company_logos.order(:position).map do |logo|
            url = logo.image_url
            Rails.logger.info "=== SERIALIZE LOGO URL DEBUG ==="
            Rails.logger.info "Logo ID: #{logo.id}"
            Rails.logger.info "Generated URL: #{url}"
            Rails.logger.info "================================="
            {
              id: logo.id,
              url: url,
              position: logo.position
            }
          end,
          created_at: user.created_at,
          created_date: user.created_at.strftime('%d/%m/%Y')
        }
      end

    end
