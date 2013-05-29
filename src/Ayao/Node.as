// ActionScript file
package Ayao
{
	import flash.display.Bitmap;
	import flash.display.BitmapData ;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	public class Node extends Sprite
	{
		public static const NODE_LENGTH:int = 45 ; 
	
		public var m_X:int = 0 ;
		public var m_Y:int = 0 ;
		public var m_Type:int = 0 ;
		private var m_bSelected:Boolean = false ;
		
		private var m_Button:SimpleButton ;
		private var m_SelectedBitmap:Bitmap ;
		private var m_HintBitmap:Bitmap ;
		
		// 设置NODE的选中状态
		public function SetPushedState(b:Boolean):void
		{
			trace("x=" + m_X + ",y=" + m_Y + " type=" + m_Type + " clicked") ;
			if (b == m_bSelected) return ;
			
			if (b) // 由未选中变为选中
			{
				addChild(m_SelectedBitmap) ;				
			}else
			{
				removeChild(m_SelectedBitmap) ;
			}
			
			width = height = NODE_LENGTH ;
			m_bSelected = b ;
			
			if (b)
				LianLianKan2.m_CurScene.NodeClicked(this) ;
		}
		
		public function SetHintState(b:Boolean):void
		{
			if (b && !contains(m_HintBitmap))
			{
				addChild(m_HintBitmap) ;
				width = height = NODE_LENGTH ;
			}
			
			if (!b && contains(m_HintBitmap))
			{
				removeChild(m_HintBitmap) ;
				width = height = NODE_LENGTH ;
			}			
		}
		
		public function Node(type:int):void
		{
			m_Type = type ;
			
			m_Button = new SimpleButton() ;
			m_Button.upState = m_Button.overState = m_Button.downState = 
				m_Button.hitTestState = new Bitmap(LianLianKan2.m_BitmapAry[type].bitmapData) ;
			m_Button.addEventListener(MouseEvent.CLICK, OnClick) ;
			m_Button.width = m_Button.height = NODE_LENGTH ;		
			
			addChild(m_Button) ;
			width = height = NODE_LENGTH ;
			
			m_SelectedBitmap = new Bitmap(LianLianKan2.m_BitmapAry[0].bitmapData) ;
			m_SelectedBitmap.width = m_SelectedBitmap.height = NODE_LENGTH ;
			
			m_HintBitmap = new Bitmap(LianLianKan2.m_BitmapAry[0].bitmapData) ;
			m_HintBitmap.width = m_HintBitmap.height = NODE_LENGTH ;

		}
		
		public function OnClick(e:MouseEvent):void
		{
			SetPushedState(true) ;
			
		}
		
		public function SetPos(xx:int, yy:int):void
		{
			m_X = xx ;
			m_Y = yy ;
			
			x = NODE_LENGTH * xx ;
			y = NODE_LENGTH * yy ;
		}
	}
	
}