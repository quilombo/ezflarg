package com.quilombo
{
	import com.quilombo.ConfigLoaderBase;
	import com.quilombo.IConfigLoader;
	import com.quilombo.IMode;
	import com.quilombo.MarkerSequenceMode;
	import com.quilombo.DefaultMarkerMode;

	public class ModeLoaderXML 	extends ConfigLoaderBase
					implements IConfigLoader
	{
		/**
			if the mode xml file defines the sequence mode a MarkerSequenceMode object gets returned
			else null gets returned currently
		*/
		public function load(value:Object):Object
		{
			super.loadXML(value);
			var mode:IMode = null;
			
			if( super._xml.OrderedSequence )
			{ 	
				trace("ModeLoaderXML::load() sequence in xml file detected.");
				mode = loadSequence( new MarkerSequenceMode() )
			}
			else
			{
				trace("ModeLoaderXML::load() no sequence in xml file detected");
			}
			
			if( mode != null )
			{
				mode = loadDetectionAction(mode);
			}
			return mode;
		}
		

		/**	expects the following xml content
	
			<DetectMarker label="marker001">
				<OnMouseClick> <!-- optional -->
					<TextElement> <!-- optional -->
						<Type>url</Type>
						<Content>file:///home/quatsch/sandbox/flex/actionscript/bin/resources/models/marker001.html</Content>
					</TextElement>
					<MediaElement> <!-- optional -->
						<Media>audio.mp3</Media>
					</MediaElement>
				<OnMouseClick>
			</DetectMarker>
		*/
		protected function loadDetectionAction(mode:IMode):IMode
		{
			/*
			var detectMarkerList:XMLList = super._xml.DetectMarker;
			
			for each (var detectMarker:XML in detectMarkerList) 
			{
				var detectMarkerEvent:DetectMarkerEvent = new DetectMarkerEvent();
				detectMarkerEvent.markerLabel = detectMarker.label.text();				
				detectMarkerEvent.action = detectMarker.OnMouseClick.text();

				var textElementList:XMLList = super._xml.DetectMarker.OnMouseClick.TextElement;
				for each (var textElement:XML in textElementList) 
				{				
					detectMarkerEvent.addTextAction( textElement.Type.text(), textElement.Content.text() );
				}
	
				var mediaElementList:XMLList = super._xml.DetectMarker.OnMouseClick.MediaElement;
				for each (var mediaElement:XML in mediaElementList) 
				{				
					detectMarkerEvent.addMediaAction( mediaElement.Media.text() );
				}

				mode.addDetectionEvent(detectMarkerEvent);
			}			
			*/
			return mode;
		}
		
		/**	expects the following xml elements

			<OrderedSequence>
				<Detect>
					<Item>marker001</Item>
					<Item>marker002</Item>
					<Item>marker003</Item>
					<Item>marker004</Item>
					<Item>marker005</Item>
					<Item>marker006</Item>
					<Item>marker007</Item>
					<Item>marker008</Item>
				</Detect>
				<Error>
					<AlreadyDetected>
						<Message>Dieser Marker wurde schon erkannt!</Message>
					</AlreadyDetected>
					<PreviouslyDetected>
						<Message>Dieser Marker wurde schon erkannt!</Message>
					</PreviouslyDetected>
					<WrongOrder>
						<Message>Du hast Marker ausgelassen! Finde die anderen zuerst.</Message>
					</WrongOrder>			
				</Error>
			</OrderedSequence>
		*/
		protected function loadSequence(mode:MarkerSequenceMode):MarkerSequenceMode
		{
			// start a new sequence of markers that are going to be detected in the given order
			mode.newSequence();
			
			/** FIXME: 	this is a fast hack to prevent the initialisation of the sequence mode.
					shall be check through xml apckage instead of using a counter! 

			*/
			var hasSequence:int=0;
			var itemList:XMLList = super._xml.OrderedSequence.Detect.Item;
			trace("ModelLoaderXML::loadSequence\n" + itemList);
			for each (var item:XML in itemList) 
			{	
				hasSequence++;
				mode.nextInSequence(item.text());
			}

			if( hasSequence > 0 )
			{
				mode.messagePreviouslyDetected		( super._xml.OrderedSequence.Error.PreviouslyDetected.Message.text() );
				mode.messageAlreadyDetected		( super._xml.OrderedSequence.Error.AlreadyDetected.Message.text() );
				mode.messageNotNextInSequence		( super._xml.OrderedSequence.Error.WrongOrder.Message.text() );			
			}
			else
			{
				trace("ModelLoaderXML::loadSequence() no sequence elements available. turn off sequence mode.");
				mode = null;
			}
			return mode;
		}
	}
}
