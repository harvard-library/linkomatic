class Digitization < ActiveRecord::Base
  belongs_to :component
  belongs_to :setting
  acts_as_list scope: :component

  NRS_SERVER = 'http://nrs.harvard.edu/'

  def settings
    component
    finding_aid = component.finding_aid
    project = finding_aid.project
    user = project.owner
    user.setting.to_h.merge(
      project.setting.to_h.merge(
        finding_aid.setting.to_h.merge(
          component.setting.to_h.merge(
            setting.to_h
          )
        )
      )
    )
  end

  def url
    NRS_SERVER + urn if urn
  end
end
