class FindingAidsController < ApplicationController
  def status
    @finding_aid.job_status
  end

  private
  
  def load_finding_aid
    @finding_aid = FindingAid.find(params[:id])
  end
end
