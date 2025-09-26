# frozen_string_literal: true

class AssetMailer < InactionSpammer::Base
  self.mailer_name = "asset_mailer"

  def welcome
    mail
  end
end
