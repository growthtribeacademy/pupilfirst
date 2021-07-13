class Segment
  def initialize(segment_write_key = ENV['SEGMENT_WRITE_KEY'])
    @segment_write_key = segment_write_key
  end

  def setup_segment_head
    return if segment_write_key.blank?

    <<-HTML
      (function () {
        var analytics = window.analytics = window.analytics || [];
        if (analytics.initialize) return;
        if (analytics.invoked) {
          if (window.console && console.error) {
            console.error('Segment snippet included twice.');
          }
          return;
        }
        analytics.invoked = true;
        analytics.methods = [
          'trackSubmit',
          'trackClick',
          'trackLink',
          'trackForm',
          'pageview',
          'identify',
          'reset',
          'group',
          'track',
          'ready',
          'alias',
          'debug',
          'page',
          'once',
          'off',
          'on',
          'addSourceMiddleware',
          'addIntegrationMiddleware',
          'setAnonymousId',
          'addDestinationMiddleware'
        ];
        analytics.factory = function (method) {
          return function () {
            var args = Array.prototype.slice.call(arguments);
            args.unshift(method);
            analytics.push(args);
            return analytics;
          };
        };
        for (var i = 0; i < analytics.methods.length; i++) {
          var key = analytics.methods[i];
          analytics[key] = analytics.factory(key);
        }
        analytics.load = function (key, options) {
          var script = document.createElement('script');
          script.type = 'text/javascript';
          script.async = true;
          script.src = 'https://cdn.segment.com/analytics.js/v1/'
            + key + '/analytics.min.js';
          var first = document.getElementsByTagName('script')[0];
          first.parentNode.insertBefore(script, first);
          analytics._loadOptions = options;
        };
        analytics._writeKey = '#{segment_write_key}';
        analytics.SNIPPET_VERSION = '4.13.2';
        analytics.load('#{segment_write_key}');
        analytics.page();
      })();
    HTML
  end

  private
  attr_reader :segment_write_key
end
