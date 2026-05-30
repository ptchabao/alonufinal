import 'package:alonu_app/presentation/pages/tv_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseYoutubeFeed extracts real titles and video ids from RSS', () {
    const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns:yt="http://www.youtube.com/xml/schemas/2015"
      xmlns:media="http://search.yahoo.com/mrss/">
  <entry>
    <yt:videoId>abcdefghijk</yt:videoId>
    <media:title><![CDATA[Émission du matin]]></media:title>
  </entry>
  <entry>
    <yt:videoId>klmnopqrstu</yt:videoId>
    <media:title><![CDATA[Atelier local]]></media:title>
  </entry>
</feed>
''';

    final videos = parseYoutubeFeed(xml);

    expect(videos.length, 2);
    expect(videos[0].id, 'abcdefghijk');
    expect(videos[0].title, 'Émission du matin');
    expect(videos[1].id, 'klmnopqrstu');
    expect(videos[1].title, 'Atelier local');
    expect(videos[0].thumbnailUrl, contains('abcdefghijk'));
  });
}
