class Api::WidgetsController < ApplicationController
  before_action :authorize_with_jwt!

  WIDGETS = [
    {
      "id": 1,
      "name": "Foo",
    },
    {
      "id": 2,
      "name": "Bar",
    },
    {
      "id": 3,
      "name": "Baz",
    },
  ]

  def index
    render_success_response(message: 'Here is a list of widgets!', data: WIDGETS, status: :ok)
  end
end