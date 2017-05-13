// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:convert' show JsonEncoder;
import 'dart:ui' show Color;

import 'package:flutter/material.dart';

import 'package:logging/logging.dart' show Logger;
import 'package:url_launcher/url_launcher.dart' as url show launch;
import 'package:zoomable_image/zoomable_image.dart' show ZoomableImage;

import 'src/e1547/e1547.dart' show Post;

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatelessWidget {
  static final Logger _log = new Logger("PostPreview");

  PostPreview(this.post, {Key key}) : super(key: key);

  final Post post;

  Widget _buildScore() {
    String scoreString = post.score.toString();
    Color c;
    if (post.score > 0) {
      scoreString = '+' + scoreString;
      c = Colors.green;
    } else if (post.score < 0) {
      c = Colors.red;
    }

    return new Text(scoreString, style: new TextStyle(color: c));
  }

  Widget _buildSafetyRating() {
    const colors = const <String, Color>{
      "E": Colors.red,
      "S": Colors.green,
      "Q": Colors.yellow,
    };

    return new Text(post.rating,
        style: new TextStyle(color: colors[post.rating]));
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Column(
      children: <Widget>[
        new GestureDetector(
            onTap: () {
              _log.fine("tapped post ${post.id}");
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: (context) {
                  return new ZoomableImage(new NetworkImage(post.file_url),
                      scale: 4.0);
                },
              ));
            },
            child: new Image.network(post.sample_url, fit: BoxFit.cover)),
        new ButtonTheme.bar(
            child: new ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildScore(),
            _buildSafetyRating(),
            new IconButton(
                icon: const Icon(Icons.favorite),
                tooltip: "Add post to favorites",
                onPressed: () => _log.fine("pressed fav")),
            new IconButton(
                icon: const Icon(Icons.chat),
                tooltip: "Go to comments",
                onPressed: () => _log.fine("pressed chat")),
            new IconButton(
                icon: const Icon(Icons.open_in_browser),
                tooltip: "Open in browser",
                onPressed: () => url.launch(post.url.toString())),
            new IconButton(
                icon: const Icon(Icons.more_horiz),
                tooltip: "More options",
                onPressed: () => showDialog(
                    context: context,
                    child: new SimpleDialog(
                        title: new Text("post #${post.id}"),
                        children: <Widget>[
                          new ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: new Text("Info"),
                            onTap: () => showDialog(
                                  context: context,
                                  child: new SimpleDialog(
                                    title: new Text("post #${post.id} info"),
                                    children: <Widget>[
                                      new Text(new JsonEncoder.withIndent('  ')
                                          .convert(post.raw))
                                    ],
                                  ),
                                ),
                          )
                        ]))),
          ],
        ))
      ],
    ));
  }
}
