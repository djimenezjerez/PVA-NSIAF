module ApplicationHelper
  ##
  # Mime-types para los archivos *.dbf
  def dbf_mime_types
    %w(application/dbase application/x-dbase application/dbf application/x-dbf zz-application/zz-winassoc-dbf)
  end

  def get_accounts(assets = false)
    accounts = assets == true ? Account.with_assets : Account.all
    accounts.map { |b| [b.name, b.id] }
  end

  def get_buildings
    Building.all.map { |b| [b.name, b.id] }
  end

  def get_materials
    status_active(Material).map { |b| [b.description, b.id] }
  end

  def get_i18n_roles
    User::ROLES.map { |r| [t(r, scope: 'users.roles'), r] }
  end

  def is_pdf?
    params['format'] == 'pdf'
  end

  def proceeding_to_json(proceeding)
    assets = proceeding.assets.each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code, state: a.get_state, auxiliary: a.auxiliary_name }
    end
    {
      #admin_name: proceeding.admin_name.titleize,
      assets: assets.to_json,
      proceeding_date: I18n.l(proceeding.created_at.to_date, format: :long),
      devolution: proceeding.is_devolution?,
      user_name: proceeding.user_name.titleize,
      user_ci: proceeding.user_ci,
      user_title: proceeding.user_title.titleize,
      user_department: proceeding.user_department.titleize,
      count: assets.count,
      entity: "#{Entity.first.code} - #{Entity.first.name}"
    }
  end

  def selected_assets_json(assets)
    { assets: assets_json(assets) }
  end

  def assets_json(assets)
    assets.each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code, barcode: a.barcode, user_name: a.user_name }
    end
  end

  def subarticles_json(subarticles)
    subarticles.each.map do |a|
      { id: a.id, description: a.description, code: a.code, barcode: a.barcode }
    end
  end

  def proceedings_json(proceedings)
    proceedings = proceedings.each_with_index.map do |p, index|
      {
        index: index + 1,
        created_at: I18n.l(p.created_at, format: :version),
        devolution: p.is_devolution?,
        user_name: p.user_name.titleize,
        user_url: user_url(p.user)
      }
    end
  end

  def submit_and_cancel(url)
    content_tag(:button, class: 'btn btn-primary') do
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + ' ' +
      t("general.btn.save")
    end + ' ' +
    link_to(url, class: 'btn btn-danger') do
      content_tag(:span, '', class: 'glyphicon glyphicon-remove') + ' ' +
      t("general.btn.cancel")
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def type_status(status)
    state = status == '0' ? 'inactive' : 'active'
    t("general.#{state}")
  end

  def title_status(type)
    state = type == '0' ? 'active' : 'deactive'
    t("general.btn.#{state}")
  end

  def img_status(status)
    status == '0' ? 'ok' : 'remove'
  end

  def get_column(model, column)
    [model.human_attribute_name(column), column]
  end

  def data_link(model)
    assignment = model.verify_assignment
    if model.status == '1'
      state = assignment ? 'cannot_disable' : 'deactivate'
    else
      state = 'activate'
    end
    klass = model.class.name
    {
      dom_id: dom_id(model),
      title: t("#{ klass.tableize }.title.modal"),
      confirm_message: t("#{ klass.tableize }.title.confirm-#{ state }", name: %w(Material Article Subarticle).include?(klass) ? model.description : model.name),
      url: eval("change_status_#{ klass.underscore }_path(model)"),
      unassigned: !assignment
    }
  end

  def data_entry_subarticle(subarticle)
    {
      id: subarticle.id,
      dom_id: dom_id(subarticle),
      title: I18n.t('subarticles.entry.first', description: subarticle.description),
      unassigned: false,
      entry: true
    }
  end

  def links_actions(user, type= '')
    link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open'), user, class: 'btn btn-default btn-xs', title: I18n.t('general.btn.show')) + ' ' +
    link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit'), [:edit, user], class: 'btn btn-primary btn-xs', title: I18n.t('general.btn.edit')) + ' ' +
    (link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(user.status)}"), '#', class: 'btn btn-warning btn-xs', data: data_link(user), title: title_status(user.status)) unless type == 'asset') + ' ' +
    (link_to(content_tag(:span, '', class: "glyphicon glyphicon-plus"), '#', class: 'btn btn-success btn-xs', data: data_entry_subarticle(user), title: I18n.t('subarticles.entry.btn')) if type == 'subarticle')
  end

  def status_active(model)
    model.where(status: '1')
  end

  def yield_or_default(section, default = "")
    content_for?(section) ? content_for(section) : default
  end

  def add_check_box(version_id)
    check_box_tag 'id', version_id
  end

  def link_request(status)
    link_to title_request(status), requests_path(status: status)
  end

  def title_request(status)
    status = status.present? ? status : 'initiation'
    t("requests.title.status.#{status}") + 's'
  end

  def get_url_request(status)
    r_referer = request.referer
    r_referer.present? && URI(r_referer).query ? (URI(r_referer).path + '?' + URI(r_referer).query) : requests_path(status: status)
  end

  def minimum_stock
    Subarticle.active.minimum_stock(1.25)
  end

  def img_pdf(type)
    if current_user.is_super_admin?
      img = "/images/#{type}.jpg"
    else
      belongs_department = current_user.department
      if belongs_department.present?
        entity = belongs_department.building.entity
        img = type == 'header' ? entity.get_header : entity.get_footer
      else
        img = ""
      end
    end
    pdf_image_tag(img, class: "image")
  end

  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(Rails.root) + '/public' + image
    tag(:img, options)
  end

  def search_asset_subarticle(model, q)
    model.where("code LIKE ? OR description LIKE ?", "%#{q}%", "%#{q}%").limit 5
  end

  # Unit for Bolivia
  def number_to_money number
    number_to_currency number,
      precision: 2,
      unit: 'Bs',
      separator: '.',
      delimiter: ',',
      format: '%u%n'
  end

  def number_with_delimiter number, precision=2
    number_with_precision number,
      precision: precision,
      separator: '.',
      delimiter: ','
  end

  def graphic_statistics(array, graphic)
    LazyHighCharts::HighChart.new(graphic) do |f|
      f.chart({ defaultSeriesType: graphic })
      if graphic == 'pie'
        f.series(
          data: get_array_graphic(array),
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            style: { fontFamily: "Helvetica Neue,Helvetica,Arial,sans-serif", fontSize: "12px" },
            format: "<b>{point.code}</b>: {point.percentage:.1f} %"
          },
        )
      else
        f.xAxis(
          categories: array.map.with_index { |f, index| index == 1 ? 'Otros' : f.code },
          labels: { style: { fontFamily: "Helvetica Neue,Helvetica,Arial,sans-serif", fontSize: "12px" } }
        )
        f.yAxis( min: 0, title: { text: 'Bs' } )
        f.legend( enabled: false )
        f.series(
          data: get_array_graphic(array),
          dataLabels: {
            enabled: true,
            rotation: -90,
            color: '#FFFFFF',
            align: 'right',
            x: 4,
            y: 10,
            style: { fontSize: '12px', fontFamily: 'Helvetica Neue,Helvetica,Arial,sans-serif' }
          }
        )
      end
      f.tooltip( pointFormat: "<b>{point.date}</b>" )
    end
  end

  def get_array_graphic(array)
    array.map.with_index { |f, index| index < 11 ? ( array_search(f, index, array) ) : nil }.compact
  end

  def array_search(f, index, array)
    index == 10 ? { code: 'Otros', name: "Otros(#{sum_array_others(array)})", y: 1 } : { code: f.code, name: "#{f.description}(#{f.total_amount}) - #{f.max_cost.to_f} Bs.", y: f.max_cost.to_f, date: (l f.created_at.to_date) }
  end

  def sum_array_others(array)
    count = array.map.count
    array.last(count - 10).inject(0) { |sum, (f, index)| sum + f.total_amount }
  end

  def title_system
    case current_user.role
    when 'super_admin' then 'Sistema de Activos Fijos y Almacenes'
    when 'admin' then 'Sistema de Activos Fijos'
    when 'admin_store' then 'Sistema de Almacenes'
    end
  end

  def color_menu
    case current_user.role
    when 'super_admin' then 'navbar-sa'
    when 'admin_store' then 'navbar-stores'
    when 'admin' then 'navbar-inverse'
    else
      ''
    end
  end

  def acronym_entity
    user = current_user.department
    if user.present?
      user = user.building
      if user.present?
        user = user.entity
        if user.present?
          "de #{user.acronym}" || ''
        else
          ""
        end
      else
        ""
      end
    else
      ""
    end
  end

  def dashboard_text
    case current_user.role
    when 'super_admin' then 'la administración del sistema'
    when 'admin' then 'los activos de su institución'
    when 'admin_store' then 'los materiales de su institución'
    end
  end

  def changeBarcode(q)
    a = q.sub! "'", "-"
    q = a.present? ? a : q
    return q
  end

  def format_date(date)
    date.present? ? (I18n.l date) : ''
  end
end
