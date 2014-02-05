module SidekiqStatuses
  JOB_STATUSES = ['waiting', 'working', 'failed', 'complete']

  def waiting?(jid, q_jids)
    q_jids.include? jid
  end

  def working?(jid)
    Sidekiq::Workers.new.map{ |name, work| work['payload']['jid'] }.include? jid
  end

  def complete?(jid)
    !waiting?(jid) && !working?(jid) && !failed?(jid)
  end

  def failed?(jid)
    Sidekiq::RetrySet.new.map(&:jid).include? jid
  end

  def status(jid, q_jids)
    return JOB_STATUSES[0] if waiting?(jid, q_jids)
    return JOB_STATUSES[1] if working?(jid)
    return JOB_STATUSES[2] if failed?(jid)
    return JOB_STATUSES[3]
  end

  def statuses(jids)
    return jids.map{|j| 'complete' }
    q_jids = Sidekiq::Queue.new.map(&:jid)
    jids.map{ |jid| status(jid, q_jids) }
  end
end
