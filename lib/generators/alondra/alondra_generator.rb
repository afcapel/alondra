class AlondraGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def generate_install
    copy_file "alondra", "script/alondra"
  end
end
