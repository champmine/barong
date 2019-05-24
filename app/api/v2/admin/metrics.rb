# frozen_string_literal: true

module API
  module V2
    module Admin
      # Metrics functionality
      class Metrics < Grape::API
        helpers do
          def filter_by_date(collection, from = nil, to = nil)
            collection = from ? collection.where('created_at > ?', Time.at(from.to_i)) : collection
            to ? collection.where('created_at < ?', Time.at(to.to_i)) : collection
          end
        end

        resource :metrics do
          desc 'Returns main statistic in the given time period',
          security: [{ "BearerToken": [] }],
          failure: [
            { code: 401, message: 'Invalid bearer token' }
          ]
          params do
            optional :created_from
            optional :created_to
          end
          get do
            result = {}
            signup = Activity.where("topic = 'account' AND action = 'signup' AND result = 'succeed'")
            sucessful_login = Activity.where("topic = 'session' AND action IN ('login', 'login::2fa') AND result = 'succeed'")
            failed_login = Activity.where("topic = 'session' AND action IN ('login', 'login::2fa') AND result = 'failed'")

            sucessful_login = filter_by_date(sucessful_login, params[:created_from], params[:created_to])
            failed_login = filter_by_date(failed_login, params[:created_from], params[:created_to])

            signup = filter_by_date(signup, params[:created_from], params[:created_to])

            result[:signups] = signup.group('date(created_at)').size
            result[:sucessful_logins] = sucessful_login.group('date(created_at)').size
            result[:failed_logins] = failed_login.group('date(created_at)').size

            result[:pending_applications] = Label.where({ key: 'document', value: 'pending', scope: 'private' }).count

            present result
          end
        end
      end
    end
  end
end
