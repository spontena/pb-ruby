require 'pandorabots/version'
require 'net/https'
require 'json'

module Pandorabots
  class API
    class << self
      BASE_URL = 'https://aiaas.pandorabots.com'
      FILE_KIND = {
        aiml: 'file', set: 'set', map: 'map', substitution: 'substitution',
        properties: 'properties', pdefaults: 'pdefaults'
      }

      def create_bot(app_id, botname, user_key:)
        request_uri = "/bot/#{app_id}/#{botname}?user_key=#{user_key}"
        put = Net::HTTP::Put.new(URI.escape(request_uri))
        response = https.request(put)
        succeed_creation?(response)
      end

      def delete_bot(app_id, botname, user_key:)
        request_uri = "/bot/#{app_id}/#{botname}?user_key=#{user_key}"
        delete = Net::HTTP::Delete.new(URI.escape(request_uri))
        response = https.request(delete)
        succeed_deletion?(response)
      end

      def upload_file(app_id, botname, file,
                      file_kind: '', filename: '', user_key:)
        file_kind = file_kind(file) if file_kind.empty?
        filename = filename(file) if filename.empty?
        request_uri = upload_file_uri(app_id, botname, file_kind,
                                      filename, user_key)
        put = Net::HTTP::Put.new(URI.escape(request_uri))
        put.body = file.read
        response = https.request(put)
        succeed_upload?(response)
      end

      def compile_bot(app_id, botname, user_key:)
        request_uri = "/bot/#{app_id}/#{botname}/verify?user_key=#{user_key}"
        get = Net::HTTP::Get.new(URI.escape(request_uri))
        response = https.request(get)
        succeed_compilation?(response)
      end

      def talk(app_id, botname, input, client_name, sessionid: '', reset: false,
               trace: false, recent: false, user_key:)
        request_uri = "/talk/#{app_id}/#{botname}?input=#{input}&client_name=#{client_name}" \
                      "&sessionid=#{sessionid}&reset=#{reset}&trace=#{trace}" \
                      "&user_key=#{user_key}"
        post = Net::HTTP::Post.new(URI.escape(request_uri))
        response = https.request(post)
        TalkResult.new(response.body) if succeed_talk?(response)
      end

      private

      def https
        uri = URI(BASE_URL)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https
      end

      def filename(file)
        File.basename(file, '.*')
      end

      def file_kind(file)
        extname = File.extname(file).delete('.')
        FILE_KIND[extname.to_sym]
      end

      def upload_file_uri(app_id, botname, file_kind, filename, user_key)
        request_uri = "/bot/#{app_id}/#{botname}/#{file_kind}"
        request_uri << "/#{filename}" if need_filename?(file_kind)
        request_uri << "?user_key=#{user_key}"
      end

      def need_filename?(file_kind)
        not ['properties', 'pdefaults'].include?(file_kind)
      end

      def succeed_creation?(response)
        case response.code
        when '200' then true
        when '400' then raise_error_400(response.body)
        when '401' then raise AuthorizationError, response.body
        when '409' then raise BotExistsError, response.body
        else raise Error, response.body
        end
      end

      def succeed_deletion?(response)
        case response.code
        when '200' then true
        when '400' then raise_error_400(response.body)
        when '401' then raise AuthorizationError, response.body
        else raise Error, response.body
        end
      end

      def succeed_upload?(response)
        case response.code
        when '200' then true
        when '400' then raise_error_400(response.body)
        when '401' then raise AuthorizationError, response.body
        else raise Error, response.body
        end
      end

      def succeed_compilation?(response)
        case response.code
        when '200' then true
        when '400' then raise_error_400(response.body)
        when '401' then raise AuthorizationError, response.body
        else raise Error, response.body
        end
      end

      def succeed_talk?(response)
        case response.code
        when '200' then true
        when '400' then raise_error_400(response.body)
        when '401' then raise AuthorizationError, response.body
        else raise Error, response.body
        end
      end

      def raise_error_400(body)
        json = JSON.parse(body)
        case json['message']
        when 'Invalid botname' then raise InvalidBotnameError, body
        when 'precondition failed' then raise PreconditionError, body
        when 'Compile errors encountered' then raise CompilationError, body
        else raise Error, body
        end
      end
    end

    class TalkResult
      attr_reader :response, :sessionid, :trace

      def initialize(json_str)
        json = JSON.parse(json_str)
        @response = json['responses'] unless json['responses'].nil?
        @sessionid = json['sessionid'] unless json['sessionid'].nil?
        @trace = json['trace'] unless json['trace'].nil?
      end
    end

    class Error < StandardError; end
    class AuthorizationError < Error; end
    class BotExistsError < Error; end
    class CompilationError < Error; end
    class InvalidBotnameError < Error; end
    class MalformedRequestError < Error; end
    class PreconditionError < Error; end
  end
end
