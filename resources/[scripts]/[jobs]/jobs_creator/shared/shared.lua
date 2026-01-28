if not JobsCreator then
  JobsCreator = {}
end

function JobsCreator.getOffDutyName(jobName)
  return "off_" .. jobName
end

function JobsCreator.getOnDutyName(jobName)
  return string.gsub(jobName, "off_", "")
end

function JobsCreator.isOffDutyName(jobName)
  return nil ~= string.find(jobName, "off_")
end
