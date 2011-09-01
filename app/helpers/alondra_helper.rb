module AlondraHelper

  def alondra_subscribe_tag(resources)
    javascript_tag do
      %Q{
        $(function(){
          #{alondra_subscribe(resources)}
        });
      }
    end
  end

  def alondra_subscribe(resources)
    resources = [resources] unless Enumerable === resources
    resources_paths = resources.collect { |r| "'#{polymorphic_path(r)}'" }.join(', ')

    "new AlondraClient('#{Alondra::Alondra.config.host}', #{Alondra::Alondra.config.port}, [#{resources_paths}]);"
  end

  def encrypted_token
    token = {:user_id => current_user.id, :valid_until => 5.minutes.from_now}.to_json
    Alondra::SessionParser.verifier.generate(token)
  end
end