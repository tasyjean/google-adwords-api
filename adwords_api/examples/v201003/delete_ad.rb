#!/usr/bin/ruby
#
# Author:: api.sgomes@gmail.com (Sérgio Gomes)
#
# Copyright:: Copyright 2011, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example deletes an ad using the 'REMOVE' operator. To get ads,
# run get_all_ads.rb.
#
# Tags: AdGroupAdService.mutate

require 'rubygems'
gem 'google-adwords-api'
require 'adwords_api'

API_VERSION = :v201003

def delete_ad()
  # AdwordsApi::Api will read a config file from ENV['HOME']/adwords_api.yml
  # when called without parameters.
  adwords = AdwordsApi::Api.new
  ad_group_ad_srv = adwords.service(:AdGroupAdService, API_VERSION)

  ad_group_id = 'INSERT_AD_GROUP_ID_HERE'.to_i
  ad_id = 'INSERT_AD_ID_HERE'.to_i

  # Prepare for deleting ad.
  operation = {
    :operator => 'REMOVE',
    :operand => {
      :ad_group_id => ad_group_id,
      :ad => {
        :xsi_type => 'Ad',
        :id => ad_id
      }
    }
  }

  # Delete ad.
  response = ad_group_ad_srv.mutate([operation])
  if response and response[:value]
    ad = response[:value].first
    puts 'Ad id %d was successfully deleted.' % ad[:ad][:id]
  else
    puts 'No ads were deleted.'
  end
end

if __FILE__ == $0
  # To enable logging of SOAP requests, set the ADWORDSAPI_DEBUG environment
  # variable to 'true'. This can be done either from your operating system
  # environment or via code, as done below.
  ENV['ADWORDSAPI_DEBUG'] = 'false'

  begin
    delete_ad()

  # Connection error. Likely transitory.
  rescue Errno::ECONNRESET, SOAP::HTTPStreamError, SocketError => e
    puts 'Connection Error: %s' % e
    puts 'Source: %s' % e.backtrace.first

  # API Error.
  rescue AdwordsApi::Errors::ApiException => e
    puts 'API Exception caught.'
    puts 'Message: %s' % e.message
    puts 'Code: %d' % e.code if e.code
    puts 'Trigger: %s' % e.trigger if e.trigger
    puts 'Errors:'
    if e.errors
      e.errors.each_with_index do |error, index|
        puts ' %d. Error type is %s. Fields:' % [index + 1, error[:xsi_type]]
        error.each_pair do |field, value|
          if field != :xsi_type
            puts '     %s: %s' % [field, value]
          end
        end
      end
    end
  end
end
