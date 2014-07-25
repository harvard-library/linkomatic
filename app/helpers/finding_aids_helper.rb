module FindingAidsHelper
  def finding_aid_xml(finding_aid)
    doc = finding_aid.ead
    doc.css('dao').map(&:remove)
    doc.css('daogrp').map(&:remove)
    finding_aid.components.each do |c|
      component_did = doc.at("##{c.cid} did")
      c.digitizations.each do |d|
        next unless d.urn
        component_did << render(partial: 'digitizations/show.ead.erb', locals: { digitization: d })
      end
    end
    doc
  end

  def finding_aid_xml_with_line_nums(finding_aid)
    doc = finding_aid_xml(finding_aid).to_s
    with_lines = ''
    doc.lines.each_with_index do |line, i|
      with_lines += "#{i+1} #{line}"
    end
    with_lines
  end
end
