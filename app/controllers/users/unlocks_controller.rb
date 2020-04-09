# frozen_string_literal: true

class Users::UnlocksController < Devise::UnlocksController
  # GET /resource/unlock/new
  # def new
  #   super
  # end

  # POST /resource/unlock
  # def create
  #   super
  # end

  # GET /resource/unlock?unlock_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after sending unlock password instructions
  # def after_sending_unlock_instructions_path_for(resource)
  #   super(resource)
  # end

  # The path used after unlocking the resource
  # def after_unlock_path_for(resource)
  #   super(resource)
  # end
end

<!-- <body style="background: asset-url('background.jpg')">

  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="#">Easy SMS Reservations</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">

      <% unless current_user.nil? %>
        <% unless current_user.companies.empty? %>
          <ul class="navbar-nav">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Reservations
              </a>
              <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                <% current_user.companies.each do |company| %>
                  <%= link_to company.name, company_path(company), class: "dropdown-item" %>
                <% end %>
              </div>
            </li>
          </ul>
        <% end %>
        <ul class="navbar-nav">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              Companies
            </a>
            <div class="dropdown-menu" aria-labelledby="navbarDropdown">
              <% if current_user.companies.empty? %>
                <%= link_to 'Create a new company', new_company_path, class: "dropdown-item" %>
              <% else %>
                <% current_user.companies.each do |company| %>
                  <%= link_to company.name, edit_company_path(company), class: "dropdown-item" %>
                <% end %>
                <div class="dropdown-divider"></div>
                <%= link_to 'New company', new_company_path, class: "dropdown-item" %>
              <% end %>

            </div>
          </li>
        </ul>
      <% end %>

      <ul class="navbar-nav ml-auto">
        <li class="nav-item">
          <%=
              link_to_if(current_user.nil?, "Login", sign_in_path, class: 'nav-link') do
                  link_to('Sign out',  destroy_user_session_path, :method => 'delete', class: 'nav-link')
              end
          %>
        </li>
      </ul>
    </div>
  </nav>

  <div class="container" style="padding-top: 20px;">
    <div class="col-10 offset-1">
      <%= yield %>
    </div>
  </div>
</body> -->
