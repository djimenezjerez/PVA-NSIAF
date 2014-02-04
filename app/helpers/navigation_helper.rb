module NavigationHelper
  def currently_at(tab)
    render 'layouts/main_nav', current_tab: tab
  end

  def nav_tab(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = [title, true].include?(current_tab) ? 'active' : nil
    content_tag(:li, link_to(title, url), options)
  end

  def import_models
    %w(buildings departments users accounts auxiliaries assets)
  end
end
