class MigrateXriForAuthentications < ActiveRecord::Migration
  def self.up
    Authentication.transaction do
      xri_prefix = /^xri:\/\//
      Authentication.where(:provider => 'open_id').select {|a| a.uid =~ xri_prefix }.map do |a|
        a.update_attributes! :uid => a.uid.gsub(xri_prefix, '')
      end
    end
  end

  def self.down
  end
end
