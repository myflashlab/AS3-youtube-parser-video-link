package com.doitflash.remote.youtube
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import air.net.URLMonitor;
	import flash.events.StatusEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	
	/**
	 * Using this class will help you parse standard YouTube urls to find out different availble video formats and qualities.
	 * if you want to simply support YouTube play on your apps, I suggest you to use the official YouTube API availble at:
	 * <a href="https://developers.google.com/youtube/">https://developers.google.com/youtube/</a>
	 * 
	 * <p>in rare cases like needing to play videos over texture when building Augmented Reality apps, you would need to
	 * download the video file first and that's when this class will be helpful</p>
	 * 
	 * <p>This library is mainly based on the following PHP lib <a href="https://github.com/jeckman/YouTube-Downloader">
	 * https://github.com/jeckman/YouTube-Downloader</a></p>
	 *
	 * <p><b>NOTICE: </b>I cannot give any gurantee that this class would always work! because YouTube changes all the time
	 * and the way to parse the information may change from time to time! This is an open source project, feel free to change it
	 * any way you like to make it work again! :D All I can say is that it is working as today that I have built it! Nov 10, 2014</p>
	 * 
	 * @example use the lib like this: 
	 * <listing version="3.0">
	 *	import com.doitflash.remote.youtube.YouTubeLinkParser;
	 *	import com.doitflash.remote.youtube.YouTubeLinkParserEvent;
	 *	import com.doitflash.remote.youtube.VideoType;
	 *	import com.doitflash.remote.youtube.VideoQuality;
	 *	
	 *	var _ytParser:YouTubeLinkParser = new YouTubeLinkParser();
	 *	_ytParser.addEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
	 *	_ytParser.addEventListener(YouTubeLinkParserEvent.ERROR, onError);
	 *	_ytParser.parse("https://www.youtube.com/watch?v=QowwaefoCec");
	 *	
	 *	function onError(e:YouTubeLinkParserEvent):void
	 *	{
	 *		// removing listeners just for clean cosing reasons!
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.ERROR, onError);
	 * 		
	 *		trace("Error: " + e.param.msg);
	 *	}
	 *	
	 *	function onComplete(e:YouTubeLinkParserEvent):void
	 *	{
	 *		// removing listeners just for clean coding reasons!
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.COMPLETE, onComplete);
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.ERROR, onError);
	 *		
	 *		trace("youTube parse completed...");
	 *		trace("video thumb: " + _ytParser.thumb);
	 *		trace("video title: " + _ytParser.title);
	 *		trace("possible found videos: " + _ytParser.videoFormats.length);
	 *		
	 *		trace("you can only access youtube public videos... no age restriction for example!");
	 *		trace("some video formats may be null so you should check their availablily...");
	 *		trace("to make your job easier, I built another method called getHeaders() which will load video headers for you! 
	 *		you can know the video size using these header information :) ")
	 *		
	 *		// let's find the VideoType.VIDEO_MP4 video format in VideoQuality.MEDIUM for this video
	 *		// NOTICE: you should find your own way of selecting a video format! as different videos may not have all formats or qualities available!
	 *		
	 *		var chosenVideo:String;
	 *		for (var i:int = 0; i &lt; _ytParser.videoFormats.length; i++) 
	 *		{
	 *			var currVideoData:Object = _ytParser.videoFormats[i];
	 *			if (currVideoData.mimeType.indexOf(VideoType.VIDEO_MP4) &gt; -1 &amp;&amp; currVideoData.quality == VideoQuality.MEDIUM)
	 *			{
	 *				chosenVideo = currVideoData.url;
	 *				break;
	 *			}
	 *		}
	 *		
	 *		_ytParser.addEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	 *		_ytParser.addEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
	 *		_ytParser.getHeaders(chosenVideo);
	 *	}
	 *	
	 *	function onHeadersError(e:YouTubeLinkParserEvent):void
	 *	{
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
	 *		
	 *		trace("Error: " + e.param.msg)
	 *	}
	 *	
	 *	function onHeadersReceived(event:YouTubeLinkParserEvent):void
	 *	{
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, onHeadersReceived);
	 *		_ytParser.removeEventListener(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, onHeadersError);
	 *		
	 *		var lng:int = event.param.headers.length;
	 *		var i:int;
	 *		var currHeader:*;
	 *		
	 *		for (i = 0; i &lt; lng; i++ )
	 *		{
	 *			currHeader = event.param.headers[i];
	 *			trace(currHeader.name + " = " + currHeader.value);
	 *		}
	 *		
	 *		// ok, we are happy! now let's download this video, like any other file you would download:
	 *		download(event.param.url);
	 *	}
	 * </listing>
	 * 
	 * @author Hadi Tavakoli - 11/6/2014 6:14 PM
	 */
	public class YouTubeLinkParser extends EventDispatcher
	{
		private static const USER_AGENT:String = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0.1)";
		private var _thumbLink:String;
		private var _videoTitle:String;
		private var _videoFormats:Array;
		
		public function YouTubeLinkParser():void
		{
			
		}
		
// -------------------------------------------------------------------------------------- functions

		private function onHttpResponse(e:HTTPStatusEvent):void
		{
		
		}
		
		private function onRawDataReceived(e:Event):void
		{
			var i:int;
			var vars:URLVariables;
			var obj:Object;
			var loader:URLLoader = e.target as URLLoader;
			
			// remove listeners for this request
			loader.removeEventListener(Event.COMPLETE, onRawDataReceived);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onFailure);
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpResponse);
			
			var videoVars:URLVariables = loader.data;
			_videoFormats = [];
			var player_response:Object = JSON.parse(videoVars.player_response);
			var formats:Array = player_response.streamingData.formats;
			var adaptiveFormats:Array = player_response.streamingData.adaptiveFormats;
			
			for (i = 0; i < formats.length; i++)
			{
				obj = formats[i];
				_videoFormats.push(obj);
			}
			
			for (i = 0; i < adaptiveFormats.length; i++)
			{
				obj = adaptiveFormats[i];
				_videoFormats.push(obj);
			}
			
			_videoTitle = player_response.videoDetails.title;
			_thumbLink = player_response.videoDetails.thumbnail.thumbnails[0].url;
			
			dispatchEvent(new YouTubeLinkParserEvent(YouTubeLinkParserEvent.COMPLETE, _videoFormats));
		}
		
		private function onFailure(e:IOErrorEvent):void
		{
			var loader:URLLoader = e.target as URLLoader;
			
			// remove listeners for this request
			loader.removeEventListener(Event.COMPLETE, onRawDataReceived);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onFailure);
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpResponse);
			
			dispatchEvent(new YouTubeLinkParserEvent(YouTubeLinkParserEvent.ERROR, {msg:"could not connect to server!"} ));
		}
		
		private function extractYoutubeId($link:String):String
		{
			var id:String;
			
			var pattern:RegExp = /v=/i;
			if (!pattern.test($link)) return null;
			id = $link.substr($link.search(pattern) + 2, 11);
			if (id.indexOf("&") > -1) return null;
			
			return id;
		}
		
		

// -------------------------------------------------------------------------------------- Methods

		/**
		 * Pass in a standard youtube link to start parsing the link. watch out for the listeners to see the results.
		 * 
		 * @param	$youtubeUrl
		 */
		public function parse($youtubeUrl:String):void
		{
			var videoId:String = extractYoutubeId($youtubeUrl);
			
			if (!videoId)
			{
				dispatchEvent(new YouTubeLinkParserEvent(YouTubeLinkParserEvent.ERROR, {msg:"invalid link!"} ));
			}
			
			var vidInfo:String = 'https://www.youtube.com/get_video_info?&video_id=' + videoId + '&asv=3&el=detailpage&hl=en_US';
			
			// setup the request method to connect to server
			var request:URLRequest = new URLRequest(vidInfo);
			request.userAgent = USER_AGENT;
			request.method = URLRequestMethod.GET;
			
			// add listeners and send out the information
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpResponse);
			loader.addEventListener(Event.COMPLETE, onRawDataReceived);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onFailure);
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.load(request);
		}
		
		/**
		 * Use this method to check if this video file is available for download or not.
		 * add the following listeners to manage it:
		 * 
		 * @param	$url	video url retrived from this library
		 */
		public function getHeaders($url:String):void
		{
			var request:URLRequest = new URLRequest($url);
			request.userAgent = USER_AGENT;
			request.method = URLRequestMethod.HEAD;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttp); 
			loader.addEventListener(IOErrorEvent.IO_ERROR, onFailure);
			loader.load(request);
			
			function onFailure(e:IOErrorEvent):void
			{
				dispatchEvent(new YouTubeLinkParserEvent(YouTubeLinkParserEvent.VIDEO_HEADER_ERROR, {msg:"connection problem or video is not available. try another video format!"} ));
			}
			
			function onHttp(event:HTTPStatusEvent):void
			{
				dispatchEvent(new YouTubeLinkParserEvent(YouTubeLinkParserEvent.VIDEO_HEADER_RECEIVED, { headers:event.responseHeaders, url:$url } ));
			}
		}

// -------------------------------------------------------------------------------------- properties

		public function get videoFormats():Array
		{
			return _videoFormats;
		}
		
		public function get thumb():String
		{
			return _thumbLink;
		}
		
		public function get title():String
		{
			return _videoTitle;
		}

	}
}