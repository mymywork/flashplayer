package {
	import flash.display.*;
	import flash.events.*;
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import flash.system.Capabilities;

	import flash.geom.Rectangle; 

	import flash.media.Sound;
	import flash.net.URLRequest;

	import flash.text.*;
	import flash.ui.*;

	public class VideoExample extends Sprite {

		internal static var vars:Object=null;

		private var connection:NetConnection;
		private var stream:NetStream;
		private var btn_playpause:ButtonPlayPause;
		private var btn_fullscreen:ButtonFullscreen;
		private var playthumb:PlayThumb;
		private var pline:ProgressLine;
		private var vline:ProgressLine;
		private var bar_timer:Timer;
		private var soundtrans:SoundTransform;
		private var scr:Sprite;
		private var bar:Sprite;
		private var video:Video;

		private var duration:Number; 
		private var stoping:Boolean=false;
		private var fullscreen:Boolean=false;
		private var videoURL:String = "http://localhost/default.flv";

		private const SCREEN_WIDTH:Number = 480;
		private const SCREEN_HEIGHT:Number = 320;
		private const BAR_HEIGHT:Number = 30;
		private const BAR_ALPHA:Number = 0.7;

		private const VIDEO_LINE_X:Number=35;
		private const VIDEO_LINE_Y:Number=10;
		private const BETWEEN_SPACE:Number=12;
		private const VOLUME_WIDTH:Number=40;
		private const VOLUME_HEIGHT:Number=10;
		private const RIGHT_SPACE:Number=15;
		private const CRAWLER_WIDTH:Number=10;
		private const CRAWLER_HEIGHT:Number=10;
		private const VIDEO_LINE_HEIGHT:Number=10;

		private const BUTTON_PLAYPAUSE_X:Number=10;
		private const BUTTON_PLAYPAUSE_Y:Number=7;
		private const BUTTON_FULLSCREEN_Y:Number=9;

		private var tformat:TextFormat;
		private var tfield:TextField;
		private var tipbg:Sprite;

		/***************************/

		var b1:Sprite;
		var b2:Sprite;
		var b3:Sprite;
		var b4:Sprite;

		var twtimer:Timer;

		var stopmenu:ContextMenu;

		var uppersprite:Sprite;

		public function VideoExample() {

			vars = LoaderInfo(parent.loaderInfo).parameters;

			trace("zzz="+vars["src"]);

			videoURL = ( vars["vfile"] != undefined ) ? vars["vfile"] : videoURL ;

			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			//stage.showDefaultContextMenu = false; 

			stopmenu = new ContextMenu();
			var stopitem:ContextMenuItem = new ContextMenuItem("stop");
			stopmenu.customItems.push(stopitem);
			stopitem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, stopload_stream);
			this.contextMenu = stopmenu;

			soundtrans = new SoundTransform(0.7);

			scr = new Sprite();
			addChild(scr);
			scr.addEventListener(MouseEvent.MOUSE_DOWN,onPlayPauseDown);
			scr.addEventListener(MouseEvent.DOUBLE_CLICK,onFullscreenToggle)

				video = new Video(SCREEN_WIDTH,SCREEN_HEIGHT);
			video.smoothing = true;
			scr.addChild(video);

			playthumb =  new PlayThumb();
			scr.addChild(playthumb);

			bar = new Sprite();
			bar.addEventListener(MouseEvent.MOUSE_OUT,onBarMouseOut);
			bar.addEventListener(MouseEvent.MOUSE_OVER,onBarMouseOver);
			addChild(bar);

			bar_timer = new Timer(3500,1);
			bar_timer.addEventListener(TimerEvent.TIMER,onBarTimer);

			stoping = true;
			btn_playpause = new ButtonPlayPause();
			btn_playpause.buttonMode = true;
			btn_playpause.gotoAndStop(2);
			btn_playpause.addEventListener(MouseEvent.MOUSE_DOWN,onPlayPauseDown);
			bar.addChild(btn_playpause);


			fullscreen=false;
			btn_fullscreen = new ButtonFullscreen();
			btn_fullscreen.buttonMode = true;
			btn_fullscreen.gotoAndStop(1);
			btn_fullscreen.addEventListener(MouseEvent.MOUSE_DOWN,onFullscreenToggle);
			btn_fullscreen.addEventListener(MouseEvent.MOUSE_OUT,onFullscreenOut);
			btn_fullscreen.addEventListener(MouseEvent.MOUSE_OVER,onFullscreenOver);
			bar.addChild(btn_fullscreen);

			pline = new ProgressLine(bar);
			pline.event_dispatcher.addEventListener(ProgressLine.ONSEEK,onProgressSeek);
			pline.event_dispatcher.addEventListener(ProgressLine.TIPOUT,onProgressTipOut);
			pline.event_dispatcher.addEventListener(ProgressLine.TIPOVER,onProgressTipOver);


			vline = new ProgressLine(bar);
			vline.event_dispatcher.addEventListener(ProgressLine.ONSEEK,onVolumeSeek);
			vline.event_dispatcher.addEventListener(ProgressLine.TIPOUT,onVolumeTipOut);
			vline.event_dispatcher.addEventListener(ProgressLine.TIPOVER,onVolumeTipOver);
			// tips

			tformat = new TextFormat();
			tfield = new TextField();
			tipbg = new Sprite();
			tipbg.addChild(tfield);
			addChild(tipbg);

			setObjsSize(SCREEN_WIDTH,SCREEN_HEIGHT);

			trace("full x="+Capabilities.screenResolutionX+" y="+Capabilities.screenResolutionY);

			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);

			/***************************************/

		}
		private function thumbwait_init(sw,sh):void {
			var lx:Number=(sw-45)/2;
			var ly:Number=(sh-45)/2;
			b1 = new Sprite();
			b2 = new Sprite();
			b3 = new Sprite();
			b4 = new Sprite();

			b1.x=lx;
			b1.y=ly;
			b1.graphics.beginFill(0x000000);
			b1.graphics.drawRect(0,0,20,20);
			b1.graphics.endFill;

			b2.x=lx+25;
			b2.y=ly;
			b2.graphics.beginFill(0x000000);
			b2.graphics.drawRect(0,0,20,20);
			b2.graphics.endFill;

			b3.x=lx;
			b3.y=ly+25;
			b3.graphics.beginFill(0x000000);
			b3.graphics.drawRect(0,0,20,20);
			b3.graphics.endFill;

			b4.x=lx+25;
			b4.y=ly+25;
			b4.graphics.beginFill(0x000000);
			b4.graphics.drawRect(0,0,20,20);
			b4.graphics.endFill;

			addChild(b1);
			addChild(b2);
			addChild(b3);
			addChild(b4);

			b1.alpha=0.75;
			b2.alpha=0.5;
			b3.alpha=0.5;
			b4.alpha=0.5;

			twtimer = new Timer(200,0);
			twtimer.addEventListener(TimerEvent.TIMER,thumbwaitTimer);
		}
		private function thumbwait_show():void {
			twtimer.start();
			b1.visible=true;
			b2.visible=true;
			b3.visible=true;
			b4.visible=true;
		}
		private function thumbwait_hide():void {
			twtimer.stop();
			b1.visible=false;
			b2.visible=false;
			b3.visible=false;
			b4.visible=false;
		}
		private function thumbwaitTimer(e:TimerEvent):void {
			var k:Number = b1.alpha;
			b1.alpha=b3.alpha;
			b3.alpha=b4.alpha;
			b4.alpha=b2.alpha;
			b2.alpha=k;
		}

		private function stopload_stream(e:ContextMenuEvent):void {
			trace("stop");
			thumbwait_show();
			pline.reset_loader();
			stopVideo();
			stream.seek(0);
			stream.close();
		}

		private function setObjsSize(sw:Number,sh:Number):void {

			btn_playpause.x = BUTTON_PLAYPAUSE_X;
			btn_playpause.y = BUTTON_PLAYPAUSE_Y;

			btn_fullscreen.y = BUTTON_FULLSCREEN_Y;

			scr.graphics.beginFill(0xff0000);
			scr.graphics.drawRect(0,0,sw,sh);
			scr.graphics.endFill;

			video.x=0;
			video.y=0;
			video.width = sw;
			video.height = sh;

			bar.y = sh - BAR_HEIGHT;
			bar.alpha = BAR_ALPHA;
			bar.graphics.clear();
			bar.graphics.beginFill(0x000000);
			bar.graphics.drawRect(0,0,sw,BAR_HEIGHT);
			bar.graphics.endFill;


			var VIDEO_LINE_WIDTH:Number = sw - VIDEO_LINE_X - BETWEEN_SPACE - VOLUME_WIDTH - BETWEEN_SPACE - btn_fullscreen.width - RIGHT_SPACE;

			btn_fullscreen.x = VIDEO_LINE_X + VIDEO_LINE_WIDTH + BETWEEN_SPACE + VOLUME_WIDTH + BETWEEN_SPACE;

			pline.set_size(VIDEO_LINE_X,VIDEO_LINE_Y,VIDEO_LINE_WIDTH,VIDEO_LINE_HEIGHT,CRAWLER_WIDTH,CRAWLER_HEIGHT);
			vline.set_size(VIDEO_LINE_X+VIDEO_LINE_WIDTH+BETWEEN_SPACE,VIDEO_LINE_Y,VOLUME_WIDTH,VOLUME_HEIGHT,CRAWLER_WIDTH,CRAWLER_HEIGHT);

			//little fix volume in switch fullscreen/normal

			vline.seek_crawler(soundtrans.volume*100,100);

			playthumb.x = (sw-playthumb.width)/2;
			playthumb.y = (sh-playthumb.height)/2;

			thumbwait_init(sw,sh);
			thumbwait_hide();
		}

		private function time_to_str(timesec:Number):String {
			var min:Number = Math.floor(timesec/60);
			var sec:Number = timesec % 60;
			return min + ":" + ( sec < 10 ? "0" : "" ) + sec;
		}
		private function onVolumeTipOut(event:Event):void {
			trace("OnProgressTipOut");
			trace("onProgressTipOut pline x="+pline.tip_x+" y="+pline.tip_y+" xpos="+pline.tip_xpos);
			tipbg.visible = false;
		}

		private function onVolumeTipOver(event:Event):void {
			tip(vline.shifted_x_to_position_ext(100,vline.tip_xpos)+"%",vline.tip_x,vline.tip_y);
		}
		private function onProgressTipOut(event:Event):void {
			tipbg.visible = false;
		}
		private function onProgressTipOver(event:Event):void {
			trace("onProgressTipOver pline x="+pline.tip_x+" y="+pline.tip_y+" xpos="+pline.tip_xpos);
			tip(time_to_str(pline.shifted_x_to_position_ext(duration,pline.tip_xpos)),pline.tip_x,pline.tip_y);
		}

		private function tip(str:String,tx:Number,ty:Number):void {

			tformat.size = 9;
			tformat.bold = 1;
			tformat.font = "Tahoma";

			tfield.text = str;
			tfield.textColor=0x00;
			tfield.x = 0;
			tfield.y = 0;
			tfield.visible = true;
			tfield.backgroundColor = 0xff;
			tfield.selectable = false;
			tfield.type = TextFieldType.DYNAMIC;
			tfield.setTextFormat(tformat);

			tipbg.graphics.clear();
			tipbg.graphics.beginFill(0xffffff);
			tipbg.graphics.drawRect(0,0,tfield.textWidth+4,tfield.textHeight+4);
			tipbg.graphics.endFill;

			tipbg.x=tx;
			tipbg.y=ty-tfield.textHeight-10;
			tipbg.mouseChildren = false;
			tipbg.mouseEnabled = false;

			tipbg.visible = true;
		}

		private function connectStream():void {
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);


			var client:Object = new Object(); 
			client.onMetaData = onMetaData;
			stream.client = client; 

			stream.soundTransform = soundtrans;	//apply sound to streaam
			video.attachNetStream(stream);		//attach video to stream

			stream.play(videoURL);
			stream.pause();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function netStatusHandler(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Unable to locate video: " + videoURL);
					break;
				case "NetStream.Play.Stop":
					pline.stopDragging();
					pline.toend_crawler();
					stream.seek(0);
					stopVideo();
					trace("STOOOOOOOOOOOOOOOOOP!");
					break;
				case "NetStream.IndexComplete":
					trace("COMPLEEEEEEEEEEETE!");
			}
		}

		private function onFullscreenToggle(event:MouseEvent):void {
			if ( fullscreen ) {
				fullscreen = false;
				stage.displayState = StageDisplayState.NORMAL;
				setObjsSize(SCREEN_WIDTH,SCREEN_HEIGHT);
			} else {
				fullscreen = true;
				stage.displayState = StageDisplayState.FULL_SCREEN;
				setObjsSize(Capabilities.screenResolutionX,Capabilities.screenResolutionY);
			}
		}

		private function onFullscreenOut(event:MouseEvent):void {
			btn_fullscreen.gotoAndStop(1);
		}

		private function onFullscreenOver(event:MouseEvent):void {
			btn_fullscreen.gotoAndStop(2);
		}
		private function onPlayPauseDown(event:MouseEvent):void { 
			trace("----------------->OnPlayPauseDown!");
			if ( stoping ) {
				playthumb.visible=false;
				if ( stream.bytesTotal == 0 ) { stream.play(videoURL); }
				btn_playpause.gotoAndStop(1);
				stoping = false;
				stream.resume();
			} else {
				stopVideo();
			}
		}
		private function stopVideo():void {
			playthumb.visible=true;
			stoping = true;
			stream.pause();
			btn_playpause.gotoAndStop(2);
		}

		private function onBarMouseOut(event:MouseEvent):void { 
			trace("----------------->OnBarMouseOut!");

			bar_timer.start();
		}

		private function onBarMouseOver(event:MouseEvent):void { 
			trace("----------------->OnBarMouseOver");

			bar_timer.stop();
			//bar.visible = true;
			bar.alpha = BAR_ALPHA;
		}

		private function onBarTimer(event:TimerEvent):void {
			trace("----------------->OnBarTimer!");
			bar_timer.stop();
			//bar.visible=false;
			bar.alpha = 0;
		}

		private function onMetaData(data:Object):void { 
			trace("METADATA!");
			duration = data.duration; 
		} 
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			// ignore AsyncErrorEvent events.
		}

		public function onVolumeSeek(event:Event):void {
			trace("onVolumeSeek WARRING!");
			var a:Number = (vline.x_to_position(100)/100);
			soundtrans.volume = a;
			trace("volume="+a);
			stream.soundTransform = soundtrans;
		}
		public function onProgressSeek(event:Event):void {
			trace("onProgressSeek xpos="+pline.crawler_xpos);
			stream.pause(); 
			stream.seek(pline.x_to_position(duration));
			if ( !pline.dragging && !stoping) { stream.resume(); stoping=false; }

		}

		private function onEnterFrame(event:Event):void {
			if ( duration > 0 ) { 
				if ( !pline.dragging && !stoping ) {
					pline.seek_crawler(stream.time,duration);
				}
				if ( !pline.loaded ) {
					if ( stream.bytesTotal != 0 ) {
						if ( stream.bytesTotal == stream.bytesLoaded ) { pline.loaded = true; }
						trace("stream.bytesLoaded="+stream.bytesLoaded+" stream.bytesTotal="+stream.bytesTotal);
						pline.seek_loader(stream.bytesLoaded,stream.bytesTotal);
					}
				}
			}
		} 

	}//class VideoExample
} //pkg

import flash.display.*;
import flash.events.*;

internal class ProgressLine {
	private var track:Sprite;
	public  var crawler:Sprite;
	public  var loader:Sprite;
	public  var dragging:Boolean;
	private var dragX:Number;
	private var crawler_max:Number;
	public  var crawler_min:Number;
	private var crawler_width:Number;
	public  var crawler_range:Number = 0;
	public  var crawler_range_real:Number = 0;
	public 	var crawler_xpos:Number;
	private var upper_:Sprite;

	public 	static const ONSEEK:String = "onseek";
	public 	static const TIPOUT:String = "tipout";
	public 	static const TIPOVER:String = "tipover";

	public  var event_dispatcher:EventDispatcher;
	private var event_seek:Event;
	private var event_tipout:Event;
	private var event_tipover:Event;

	public 	var tip_x:Number;
	public 	var tip_y:Number;
	public 	var tip_xpos:Number;

	public  var loaded:Boolean=false;

	public function ProgressLine(upper:Sprite):void {

		event_dispatcher = new EventDispatcher();
		event_seek = new Event(ONSEEK);
		event_tipout = new Event(TIPOUT);
		event_tipover = new Event(TIPOVER);

		upper_ = upper;

		track = new Sprite();
		upper.addChild(track);
		loader = new Sprite();
		track.addChild(loader);
		crawler = new Sprite();
		upper.addChild(crawler);

		track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
		crawler.addEventListener(MouseEvent.MOUSE_DOWN, onCrawlerMouseDown); 

		track.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		track.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		track.addEventListener(MouseEvent.MOUSE_MOVE, onMouseOver);
		crawler.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		crawler.addEventListener(MouseEvent.MOUSE_OVER, onCrawlerMouseOver); 
		crawler.addEventListener(MouseEvent.MOUSE_MOVE, onCrawlerMouseOver); 

	}

	public function set_size(px:Number,py:Number,pwidth:Number,pheight:Number,cwidth:Number,cheight:Number):void {

		var old_range:Number;

		if ( crawler_range == 0 ) { old_range = pwidth; } else { old_range = crawler_range; }

		crawler_max = pwidth-cwidth+px;
		crawler_min = px;
		crawler_width = cwidth;
		crawler_range = pwidth;
		crawler_range_real = pwidth-cwidth;

		track.x = px;
		track.y = py;
		track.graphics.clear();
		track.graphics.beginFill(0x404040);
		track.graphics.drawRect(0, 0, pwidth, pheight); 
		track.graphics.endFill();

		seek_loader(loader.width,old_range);

		crawler.x = px;
		crawler.y = py;
		crawler.graphics.clear();
		crawler.graphics.beginFill(0xFFFFFF); 
		crawler.graphics.drawRect(0, 0, cwidth, cheight); 
		crawler.graphics.endFill();

	}

	public function x_to_position(alltime:Number):Number {
		return x_to_position_ext(alltime,crawler_xpos);
	}

	public function x_to_position_ext(alltime:Number,tmp_x:Number):Number {
		return Math.round(alltime * tmp_x / crawler_range_real );
	}

	public function shifted_x_to_position_ext(alltime:Number,tmp_x:Number):Number {

		tmp_x = ( tmp_x < ( crawler_width / 2 ) ) ? 0 : tmp_x - ( crawler_width / 2 );
		tmp_x = ( tmp_x > ( crawler_range - ( crawler_width ) ) ) ? crawler_range - ( crawler_width ) : tmp_x ;

		return Math.round(alltime * tmp_x / ( crawler_range - crawler_width ) );
	}

	public function toend_crawler():void {
		trace("toend_crawler crawler.x="+crawler.x+" crawler_max="+crawler_max);
		crawler.x = crawler_max;
		trace("toend_crawler crawler.x="+crawler.x+" crawler_max="+crawler_max);

	}

	public function seek_crawler(seektime:Number,alltime:Number):void {
		var a:Number = (seektime / alltime * crawler_range_real ) + crawler_min;
		crawler.x = a; // apply_range(a);
	}

	public function seek_loader(seektime:Number,alltime:Number):void {
		var a:Number = (seektime / alltime * crawler_range );
		var b:Number = Math.min(crawler_range, Math.max(0,a));
		loader.graphics.clear();
		loader.graphics.beginFill(0xffffff);
		loader.graphics.drawRect(0, 0, b, track.height); 
		loader.graphics.endFill();
	}

	public function reset_loader():void {
		loaded=false;
		seek_loader(0,1);
	}

	/***************************
	 * events
	 ****************************/

	private function onMouseOut(event:MouseEvent):void {

		event_dispatcher.dispatchEvent(event_tipout);
	}

	private function onCrawlerMouseOver(event:MouseEvent):void {
		tips_show(event,true)
	}

	private function onMouseOver(event:MouseEvent):void {
		tips_show(event,false)
	}

	private function tips_show(event:MouseEvent,c:Boolean):void {
		if ( dragging && c ) {
			var tmp_x:Number;
			tmp_x = event.stageX - event.localX + crawler_width/2;
			tip_x = tmp_x;
			tip_xpos=tmp_x - crawler_min;
		} 
		else { 
			tip_x=event.stageX; 
			tip_xpos=event.stageX-crawler_min;
		}

		tip_y=event.stageY-event.localY;
		event_dispatcher.dispatchEvent(event_tipover);
	}

	private function onTrackMouseDown(event:MouseEvent):void { 
		trace("onTrackMouseDown stage x="+event.stageX+" x="+event.localX);
		var tmp_x:Number = event.stageX - crawler_width/2;
		crawler.x = apply_range(tmp_x);
		startDragging(event.stageX);
	}
	private function onCrawlerMouseDown(event:MouseEvent):void { 
		trace("onCrawlerMouseDown");
		startDragging(event.stageX);
		onCrawlerMouseOver(event);
	}
	private function startDragging(tmp_x:Number):void {
		dragging = true;
		dragX = tmp_x - crawler.x;
		trace("startDragging dragX="+dragX);
		trace("startDragging event.stageX="+tmp_x+" crawler.x="+crawler.x);
		upper_.stage.addEventListener(MouseEvent.MOUSE_UP, onCrawlerMouseUp);
		upper_.stage.addEventListener(MouseEvent.MOUSE_MOVE, onCrawlerMouseMove);

	}
	internal function onCrawlerMouseUp(event:MouseEvent):void { 
		trace("onCrawlerMouseUp stage x="+event.stageX+" x="+event.localX);
		if (dragging) {
			stopDragging();
			crawler_xpos = crawler.x-crawler_min;
			event_dispatcher.dispatchEvent(event_seek);
			onCrawlerMouseOver(event);
		}
	}
	public function stopDragging():void {
		if (dragging) {
			dragging = false;
			upper_.stage.removeEventListener(MouseEvent.MOUSE_UP, onCrawlerMouseUp);
			upper_.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onCrawlerMouseMove);
		}
	}
	internal function onCrawlerMouseMove(event:MouseEvent):void { 
		trace("onCrawlerMouseMove");
		if (dragging) {
			var tmp_x:Number = event.stageX - dragX;
			crawler.x = apply_range(tmp_x);
			trace("onCrawlerMouseMove event.stageX="+event.stageX+" dragX="+dragX+" tmp_x="+tmp_x);
			trace("onCrawlerMouseMove crawler.x="+crawler.x);
			crawler_xpos = crawler.x-crawler_min;
			event_dispatcher.dispatchEvent(event_seek);
		} 
	}

	public function apply_range(tmp_x:Number):Number {
		return Math.min(crawler_max, Math.max(crawler_min,tmp_x));
	}

}//class ProgressLine
