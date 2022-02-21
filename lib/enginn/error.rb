# frozen_string_literal: true

module Enginn
  class Error < StandardError; end

  # Map Enginn errors to Faraday's while keeping Enginn::Error inheriting from
  # StandardError.
  class HTTPError < Faraday::Error; end
  class ClientError < HTTPError; end
  class ServerError < HTTPError; end
  class BadRequestError < ClientError; end
  class UnauthorizedError < ClientError; end
  class ForbiddenError < ClientError; end
  class ResourceNotFound < ClientError; end
  class ProxyAuthError < ClientError; end
  class ConflictError < ClientError; end
  class UnprocessableEntityError < ClientError; end
  class NilStatusError < ServerError; end

  # Override the Faraday::Response::RaiseError middleware to raise Enginn
  # errors instead of Faraday's
  # (see https://github.com/lostisland/faraday -> lib/faraday/error.rb)
  #
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  class RaiseError < Faraday::Response::RaiseError
    def on_complete(env)
      case env[:status]
      when 400
        raise Enginn::BadRequestError, response_values(env)
      when 401
        raise Enginn::UnauthorizedError, response_values(env)
      when 403
        raise Enginn::ForbiddenError, response_values(env)
      when 404
        raise Enginn::ResourceNotFound, response_values(env)
      when 407
        # mimic the behavior that we get with proxy requests with HTTPS
        msg = %(407 "Proxy Authentication Required")
        raise Enginn::ProxyAuthError.new(msg, response_values(env))
      when 409
        raise Enginn::ConflictError, response_values(env)
      when 422
        raise Enginn::UnprocessableEntityError, response_values(env)
      when ClientErrorStatuses
        raise Enginn::ClientError, response_values(env)
      when ServerErrorStatuses
        raise Enginn::ServerError, response_values(env)
      when nil
        raise Enginn::NilStatusError, response_values(env)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  Faraday::Response.register_middleware(enginn_raise_error: Enginn::RaiseError)
end
