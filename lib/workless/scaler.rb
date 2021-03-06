module Delayed
  module Workless
    module Scaler

      autoload :Heroku,      "workless/scalers/heroku"
      autoload :HerokuCedar, "workless/scalers/heroku_cedar"
      autoload :Local,       "workless/scalers/local"
      autoload :Null,        "workless/scalers/null"

      def self.included(base)
        base.send :extend, ClassMethods
        base.class_eval do
          after_destroy "self.class.scaler.down"
          after_create "self.class.scaler.up"
          after_update "self.class.scaler.down", :unless => Proc.new {|r| r.failed_at.nil? }
        end

      end

      module ClassMethods
        def scaler
          @scaler ||= if ENV.include?("HEROKU_API_KEY")
            Scaler::HerokuCedar
          else
            Scaler::Local
          end
        end

        def scaler=(scaler)
          @scaler = "Delayed::Workless::Scaler::#{scaler.to_s.camelize}".constantize
        end
      end

    end

  end
end
