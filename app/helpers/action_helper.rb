module ActionHelper
  def edition_actions(edition)
    edition.actions.reverse
  end

  def action_requester(action)
    action.requester ? (mail_to action.requester.email, action.requester.name).html_safe : 'GOV.UK Bot'
  end

  def assign_action?(action)
    action.request_type == Action::ASSIGN
  end

  def assign_to_other?(action)
    assign_action?(action) && (action.recipient.email != action.requester.email)
  end

  def action_title(action)
    requester = action_requester(action)

    if assign_action?(action)
      title = "Assign to #{mail_to action.recipient.email, action.recipient.name}"
      if assign_to_other?(action)
        title = "#{title} by #{requester}"
      end
    else
      title = "#{action.to_s} by #{requester}"
    end

    title.html_safe
  end

  def action_note?(action)
    action.comment.present? || action.is_fact_check_request?
  end

  def action_note(action)
    if action.comment.present?
      format_and_auto_link_plain_text(action.comment)
    elsif action.is_fact_check_request? && action.email_addresses.present?
      "Request sent to #{mail_to action.email_addresses}".html_safe
    end
  end

  def format_and_auto_link_plain_text(text)
    text = auto_link(escape_once(text), link: :urls, sanitize: false)
    text = auto_link_zendesk_tickets(text)
    simple_format(text, {}, :sanitize => false).html_safe
  end

  def auto_link_zendesk_tickets(text)
    text = text.gsub(/(?:zen|zendesk|zendesk ticket)(?:\s)?(?:#|\:)?(?:\s)?(\d{4,})/i) do |match|
      ticket = $1
      link_to match, "https://govuk.zendesk.com/tickets/#{ticket}"
    end

    text.html_safe
  end
end
