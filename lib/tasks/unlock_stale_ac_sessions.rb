def expire_stale_ac_sessions
  results = ''
  AcSession.joins(:ac_session_histories).where(ac_sessions: { locked: true }, ac_session_histories: { expired: false }).each do |ac_session|
    ac_session.ac_session_histories.where(expired: false).each do |ac_session_history|
      if ac_session_history.ac_document.document_spec_xml.match('p.json') && Time.now - ac_session_history.created_at > 2.hours
        results += "#{ac_session_history.id} \n"
        # ac_session.unlock!
      end
    end
  end
  puts results
end
