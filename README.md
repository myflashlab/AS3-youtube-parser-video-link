## AS3-youtube-parser-video-link ##
This AS3 library can parse standard youtube links like **https://www.youtube.com/watch?v=QowwaefoCec** 
and will extract different elements of that video like available direct video addresses, video title
and video thumbnail. It works with public unrestricted video files only.

I must add that I wrote this library after being inspired by https://github.com/jeckman/YouTube-Downloader

It works on Android/iOS/Windows/Mac AIR projects.

USAGE:

```actionscript

import com.doitflash.remote.youtube.YouTubeLinkParser;
import com.doitflash.remote.youtube.YouTubeLinkParserEvent;
import com.doitflash.remote.youtube.VideoType;
import com.doitflash.remote.youtube.VideoQuality;

var _ytParser:YouTubeLinkParser = new YouTubeLinkParser();
_ytParser.addEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
_ytParser.addEventListener(YouTubeLinkParserEvent.ERROR, onError);
_ytParser.parse("https://www.youtube.com/watch?v=QowwaefoCec");

function onError(e:YouTubeLinkParserEvent):void
{
	// removing listeners just for clean cosing reasons!
	_ytParser.removeEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
	_ytParser.removeEventListener(YouTubeLinkParserEvent.ERROR, onError);
	trace("Error: " + e.param.msg);
}

function onComplete(e:YouTubeLinkParserEvent):void
{
	// removing listeners just for clean coding reasons!
	_ytParser.removeEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
	_ytParser.removeEventListener(YouTubeLinkParserEvent.ERROR, onError);
         
	trace("youTube parse completed...");
	trace("video thumb: " + _ytParser.thumb);
	trace("video title: " + _ytParser.title);
	trace("possible found videos: " + _ytParser.videoFormats.length);
	      
	trace("you can only access youtube public videos... no age restriction for example!");
	trace("some video formats may be null so you should check their availablily...");
	trace("to make your job easier, I built another method called getHeaders() which will load video headers for you! you can know the video size using these header information :) ");
	
	// let's find the VideoType.VIDEO_MP4 video format in VideoQuality.MEDIUM for this video
	// NOTICE: you should find your own way of selecting a video format! as different videos may not have all formats or qualities available!
	      
	var currVideoData:URLVariables;
	var chosenVideo:String;
	for (var i:int = 0; i < _ytParser.videoFormats.length; i++) 
	{
		currVideoData = _ytParser.videoFormats[i];
		if (currVideoData.type == VideoType.VIDEO_MP4 && currVideoData.quality == VideoQuality.MEDIUM)
		{
			chosenVideo = currVideoData.url;
			break;
		}
	}

	_ytParser.addEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	_ytParser.addEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
	_ytParser.getHeaders(chosenVideo);
}
     
function onHeadersError(e:YouTubeLinkParserEvent):void
{
	_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
         
	trace("Error: " + e.param.msg)
}
     
function onHeadersReceived(event:YouTubeLinkParserEvent):void
{
	_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
         
	var lng:int = event.param.headers.length;
	var i:int;
	var currHeader:*;
         
	for (i = 0; i < lng; i++ )
	{
		currHeader = event.param.headers[i];
		trace(currHeader.name + " = " + currHeader.value);
	}
         
	// ok, we are happy! now let's download this video, like any other file you would download:
	download(event.param.url);
}
```