require 'xcodeproj'

project_file = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_file)
project.main_group["Runner"].files.each do |file|
  if file.path.match(/^GoogleService-Info.plist/)
    file.remove_from_project
  end
end

project.save(project_file)