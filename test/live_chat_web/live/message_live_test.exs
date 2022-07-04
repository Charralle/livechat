defmodule LiveChatWeb.MessageLiveTest do
  use LiveChatWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LiveChat.Message

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView Chat"

    {:ok, _view, _html} = live(conn)
  end

  import Plug.HTML, only: [html_escape: 1]

  test "name can't be blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "", message: "hello"})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: ""})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "minimum message length", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: "h"})
           |> render_submit() =~ "should be at least 2 character(s)"
  end

  test "message form submitted correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#form", message: %{name: "Simon", message: "hi"})
           |> render_submit()

    assert render(view) =~ "<b>Simon:</b>"
    assert render(view) =~ "hi"
  end

  test "handle_info/2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view)
    # send :created_message event when the message is created
    Message.create_message(%{"name" => "Simon", "message" => "hello"})
    # test that the name and the message is displayed
    assert render(view) =~ "<b>Simon:</b>"
    assert render(view) =~ "hello"
  end

  test "1 guest online", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render(view) =~ "1 guest"
  end

  test "2 guests online", %{conn: conn} do
    {:ok, _view, _html} = live(conn, "/")
    {:ok, view2, _html} = live(conn, "/")

    assert render(view2) =~ "2 guests"
  end
end
