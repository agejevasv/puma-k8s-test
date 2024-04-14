# frozen_string_literal: true

class TestsController < ApplicationController
  def instant
    render json: { timestamp: Time.now.to_i }
  end

  def blocking
    sleep 0.05
    render json: { timestamp: Time.now.to_i }
  end
end
