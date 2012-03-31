module PagesHelper
  def humanize_time(secs)
    [60,60,24].map{ |count|
      if secs > 0
        secs, n = secs.divmod(count)
        if count == 24 and n == 0
          nil
        else
          "#{'%02d' % n.to_i}" 
        end
      else
        "00" unless count == 24
      end
    }.compact.reverse.join(':')
  end
end
