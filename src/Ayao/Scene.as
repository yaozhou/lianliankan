// ActionScript file
package Ayao
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Scene extends Sprite
	{
		public static const TIMER_INTERVAL:Number = 300 ; 
		
		
		private var m_xWidth:int = 0 ; 
		private var m_yWidth:int = 0 ;
		public var m_CurLevel:int = 0 ;
		private var m_HoleAry:Array ; 
		
		private var m_NodeAry:Array = new Array() ;
		
		private var m_NodeMap:Array ;
		private var m_LastClickedNode:Node ;		
		private var m_LeftTime:Number = 0 ;
		private var m_TotalTime:Number = 0 ;
		private var m_LeftHintNum:int = HINT_NUM ;
		private var m_LeftShuffleNum:int = SHUFFLE_NUM ;
		
		// 上一次消掉格子的时间，用来判断连击
		private var m_LastScoreDate:Date ;
		private var m_CurContinueHitNum:int = 0 ;
		
		// 默认提示数量和重排数量
		public static const HINT_NUM:int = 3 ;
		public static const SHUFFLE_NUM:int = 3 ; 
		
		private var m_Timer:Timer = new Timer(TIMER_INTERVAL, 0) ;
		private var m_ShowPathTimer:Timer = new Timer(100, 1) ;
		private var m_AlarmTimer:Timer = new Timer(1000, 0) ;
		
		
		// holeAry：这个关卡中可以摆放NODE的格子数组     nodeNumAry:不同种类的NODE的数量
		public function Scene(holeAry:Array, nodeNumAry:Array, xWidth:int, yWidth:int, timeLimit:int, level:int)
		{
			//holeAry = [0,1,2,3,100,101] ;
			//nodeNumAry = [2,2,2] ;
			//xWidth = 4 ;
			//yWidth = 2 ; 
			
			m_xWidth = xWidth ;
			m_yWidth = yWidth ;
			m_CurLevel = level ;
			m_HoleAry = holeAry ;
			
			m_TotalTime = m_LeftTime = timeLimit ;
			
			m_NodeMap = new Array() ;
			for(var i:int=0; i<xWidth; ++i)
			{
				m_NodeMap[i] = new Array() ;
			}
			
			// 预先分配好所有的NODE
			var nodeAry:Array = new Array() ;
			for(i=0; i<nodeNumAry.length; ++i)
			{
				// 每一种分配N个
				for(var j:int=0; j<nodeNumAry[i]; ++j)
				{
					nodeAry.push(new Ayao.Node(i+1)) ;
				}
			}
			
			Shuffle(nodeAry, holeAry) ;
			m_Timer.addEventListener(TimerEvent.TIMER, TimerHandler) ;
			m_Timer.start() ;
			
			m_ShowPathTimer.addEventListener(TimerEvent.TIMER, PathTimerHandler) ;
			m_AlarmTimer.addEventListener(TimerEvent.TIMER, AlarmTimerHandler) ;
		}
		
		public function FlushLevelInfo2UI():void
		{
			LianLianKan2.m_App.m_GameMainWindow.FlushLevelInfo2UI(m_LeftHintNum, 
						m_LeftShuffleNum, m_CurLevel, m_LeftTime, m_TotalTime, 
						LianLianKan2.m_App.m_SoundVol, LianLianKan2.m_App.m_MusicVol) ;
			

		}
		
		public function TimerHandler(event:TimerEvent):void
		{
			AddLeftTime(-TIMER_INTERVAL/1000) ;
			
			if (m_LeftTime == 0)
			{
				LevelFailed() ;
			}
		}
		
		public function LevelFailed():void
		{
			// 失败
			m_Timer.stop() ;
			m_AlarmTimer.stop() ;
			LianLianKan2.m_App.ShowFailedWindow() ;
			LianLianKan2.m_App.StopBkMusic() ;
			//LianLianKan2.m_App.PlaySound("Sound/shibai.mp3") ;
			LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundShiBai) ;
			
			LianLianKan2.m_App.m_GameMainWindow.m_UC.visible = false ;
		}
		
		public function AddLeftTime(t:Number):void
		{
			var preTime:Number = m_LeftTime ;
			
			m_LeftTime += t ;
			if (m_LeftTime > m_TotalTime) m_LeftTime = m_TotalTime ;
			if (m_LeftTime < 0) m_LeftTime = 0 ;
			
			if (preTime <= LianLianKan2.ALARM_TIME && !m_AlarmTimer.running)
			{
				m_AlarmTimer.start() ;
			}
			
			if (preTime > LianLianKan2.ALARM_TIME && m_AlarmTimer.running)
			{
				m_AlarmTimer.stop() ;
			}
			
			LianLianKan2.m_App.m_GameMainWindow.FlushLeftTime(m_LeftTime, m_TotalTime) ;
			
			//trace("addTime " + t) ;
			//m_Timer.stop() ;
			//m_Timer = new Timer(
		}
	
		public function ArrangeNode(node:Ayao.Node, x:int, y:int):void
		{
			addChild(node) ;
			node.SetPos(x, y) ;
			m_NodeAry.push(node) ;
			m_NodeMap[x][y] = node ;
		}
		
		public function ExistXLineBetween(x1:int, x2:int, y:int, includeP1:Boolean, includeP2:Boolean):Boolean
		{
			if (x1 == x2) return false ;
			
			// 确保X1小于X2
			if (x1 > x2)
			{
				var t:int = x1 ;
				x1 = x2 ;
				x2 = t ;
				
				var b:Boolean = includeP1 ;
				includeP1 = includeP2 ;
				includeP2 = b ;
			}
			
			if (!includeP1) ++x1 ;
			if (!includeP2) --x2 ;
			
			for(var i:int=x1; i<=x2; ++i)
			{
				if (i >= 0 && i < m_xWidth && y >= 0 && y < m_yWidth && m_NodeMap[i][y] != null) return false ;
			}
			
			return true ;
		}
		
		public function ExistYLineBetween(y1:int, y2:int, x:int, includeP1:Boolean, includeP2:Boolean):Boolean
		{
			if (y1 == y2) return false ;
			//if (x < 0 || x >= m_xWidth) return true ;
			
			// 确保Y1小于Y2
			if (y1 > y2)
			{
				var t:int = y1 ;
				y1 = y2 ;
				y2 = t ;
				
				var b:Boolean = includeP1 ;
				includeP1 = includeP2 ;
				includeP2 = b ;
			}
			
			if (!includeP1) ++y1 ;
			if (!includeP2) --y2 ;
			
			for(var i:int=y1; i<=y2; ++i)
			{
				if (x >= 0 && x < m_xWidth && y >= 0 && y < m_yWidth && m_NodeMap[x][i] != null) return false ;
			}
			
			return true ;
		}
			
		
		public function ExistLineBetween(x1:int, y1:int, x2:int, y2:int, includeP1:Boolean, includeP2:Boolean, path:Array):Boolean
		{
			if (x1==x2 && y1==y2) return false ;
			
			if (x1 == x2) // 处于同一条竖直的线上
			{
				if (ExistYLineBetween(y1, y2, x1, false, false)) 
				{
					path.push(x1,y1,x2,y2) ;
					return true ;
				}
			}
			
			if (y1 == y2) // 处于同一条横线上
			{
				if (ExistXLineBetween(x1, x2, y1, false, false)) 
				{
					path.push(x1,y1,x2,y2) ;
					return true ;
				}
			}
			
			// 处于同一条直线上的时候不考虑两步连法
			if (x1 != x2 && y1 != y2)
			{
				// 尝试先走X轴，再走Y轴，是否可以两步连上
				if (ExistXLineBetween(x1, x2, y1, false, true) &&
					ExistYLineBetween(y1, y2, x2, true, false) )
				{
					path.push(x1,y1,x2,y1,x2,y2) ;
					return true ;
				}
				
				// 尝试先走Y轴，再走X轴，是否可以两步连上
				if (ExistYLineBetween(y1, y2, x1, false, true) &&
					ExistXLineBetween(x1, x2, y2, true, false))
				{
					path.push(x1,y1,x1,y2,x2,y2) ;
					return true ;
				}
			}			
			
			// 尝试中间线段为水平线的三段连法
			for(var i:int=-1; i<=m_yWidth; ++i)
			{
				if(i!=y1 && i!=y2 && 
					ExistXLineBetween(x1, x2, i, true, true) &&
					ExistYLineBetween(y1, i, x1, false, true) &&
					ExistYLineBetween(y2, i, x2, false, true))
				{
					path.push(x1,y1,x1,i,x2,i,x2,y2) ;
					return true ;				
				}
			}
			
			// 尝试中间线段为竖直线的三段连法
			for(i=-1; i<=m_xWidth; ++i) 
			{
				if(i!=x1 && i!=x2 &&
					ExistYLineBetween(y1, y2, i, true, true) &&
					ExistXLineBetween(x1, i, y1, false, true) &&
					ExistXLineBetween(x2, i, y2, false, true))
				{
					path.push(x1,y1,i,y1,i,y2,x2,y2) ;
					return true ;
				}
				
			}
			
			return false ;
		}
		
		public function RemoveANode(node:Node):void
		{
			var idx:int = m_NodeAry.indexOf(node) ;
			
			m_NodeMap[node.m_X][node.m_Y] = null ;
			m_NodeAry.splice(idx, 1) ;
			removeChild(node) ;
			
		}
		
		private function Shuffle(nodeAry:Array, holeAry:Array):void
		{
			// 清空NODE记录
			m_NodeAry = new Array() ;
			m_NodeMap = new Array() ;
			for(var i:int=0; i<m_xWidth; ++i)
			{
				m_NodeMap[i] = new Array() ;
			}
			
			// 拷贝一份，用于防止死锁
			var nodeAry2:Array = nodeAry.slice() ;
			
			for(i=0; i<holeAry.length; ++i)
			{
				// AS中整除应该这样实现？会有浮点数精度问题么？
				var yIdx:int = Math.floor(holeAry[i] / 100) ;
				var xIdx:int = holeAry[i] % 100 ;
				
				var randIdx:int = Math.floor(Math.random() * nodeAry.length) ;
				trace("arrange node x=" + xIdx + ", y=" + yIdx) ;
				ArrangeNode(nodeAry[randIdx], xIdx, yIdx) ;
				nodeAry.splice(randIdx, 1) ;
			}
			
			// 防止什么也点不了
			if (IsInDeadLock())
			{
				Shuffle(nodeAry2, holeAry) ;
			}
		}
		
		public function ScoreTwoNodes(node1:Node, node2:Node):void
		{
			RemoveANode(node1) ;
			RemoveANode(node2) ;
			
			//LianLianKan2.m_App.PlaySound("Sound/xiaoshi.mp3") ;
			LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundXiaoShi) ;
			
			if (m_LastScoreDate == null)
			{
				m_LastScoreDate = new Date() ;
				m_CurContinueHitNum = 1 ;
				return ;
			}
			
			
			var curDate:Date = new Date() ;			
			var preT:Number = m_LastScoreDate.valueOf() ;
			var curT:Number = curDate.valueOf() ;
			
			// 设置新时间
			m_LastScoreDate = curDate ;
			
			if (curT - preT < LianLianKan2.CONTINUE_HIT_INTERVAL)
			{
				++m_CurContinueHitNum ;
				if (m_CurContinueHitNum > 1 && m_CurContinueHitNum <= LianLianKan2.MAX_CONTINUE_HIT)
				{
					AddLeftTime(LianLianKan2.m_ContinueHitBonus[m_CurContinueHitNum]) ;
				}
			}else
			{
				m_CurContinueHitNum = 1 ;
				trace("continueHit clear to 1") ;
			}
		}
		
		// NODE点击事件
		public function NodeClicked(node:Node):void
		{
			if (m_LastClickedNode == null)	// 第一次点击
			{
				//LianLianKan2.m_App.PlaySound("Sound/dianji.mp3") ;
				LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundDianJi) ;
				m_LastClickedNode = node ;
				return ;
			}
			
			var path:Array = new Array() ;
			if (CheckLine(m_LastClickedNode, node, path))
			{
				ScoreTwoNodes(m_LastClickedNode, node) ;
				ShowPath(path) ;
				
				// 防止剩下的无法消掉
				while(IsInDeadLock())
				{
					ReShuffle(true) ;
				}					
				
				m_LastClickedNode = null ;
				trace("left " + m_NodeAry.length + " node") ;
				if (m_NodeAry.length == 0)
					LevelCleared() ;
			}else
			{
				m_LastClickedNode.SetPushedState(false) ;
				m_LastClickedNode = node ;
				
				//LianLianKan2.m_App.PlaySound("Sound/dianji.mp3") ;
				LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundDianJi) ;
			}
		}
		
		public function LevelCleared():void
		{
			m_Timer.stop() ;
			m_AlarmTimer.stop() ;
			
			if (m_CurLevel == LianLianKan2.LEVEL_NUM)
				LianLianKan2.m_App.ShowSuccessWindow() ;
			else
				LianLianKan2.m_App.ShowNextLevelWindow(m_CurLevel+1) ;
			
			LianLianKan2.m_App.StopBkMusic() ;
			//LianLianKan2.m_App.PlaySound("Sound/guoguan.mp3") ;
			LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundGuoGuan) ;
		}
		
		// 检查是否可以消掉两块
		public function CheckLine(node1:Node, node2:Node, path:Array):Boolean
		{
			if (node1.m_Type != node2.m_Type) return false ;
 
			return ExistLineBetween(node1.m_X, node1.m_Y, node2.m_X, node2.m_Y, false, false, path) ;
		}
		
		private function PathTimerHandler(event:TimerEvent):void
		{
			graphics.clear() ;
		}
		
		private function AlarmTimerHandler(event:TimerEvent):void
		{
			//LianLianKan2.m_App.PlaySound("Sound/baojing.mp3") ;
			LianLianKan2.m_App.PlaySound(LianLianKan2.m_App.m_SoundBaoJing) ;
			//trace("alarm timer") ;
		}
		
		// 检测idx号(m_NodeAry中的索引)NODE是否可以和另一个NODE连上消掉
		public function GetLegalPeer(idx:int):int
		{
			for(var i:int=0; i<m_NodeAry.length; ++i)
			{
				var path:Array = new Array() ;
				if (idx != i && CheckLine(m_NodeAry[idx], m_NodeAry[i], path))
					return i ;
			}
			return -1 ;
		}
		
		public function Hint():void
		{
			if (m_LeftHintNum == 0) return ;
			if (m_NodeAry.length == 0) return ; 
			
			// 取消已经被选中的格子的选中状态
			if (m_LastClickedNode != null)
			{
				m_LastClickedNode.SetPushedState(false) ;
				m_LastClickedNode = null ;	
			}
			 
			for(var i:int=0; i<m_NodeAry.length; ++i)
			{
				var peerIdx:int = GetLegalPeer(i) ;
				if (peerIdx != -1)	// 有的连
				{
					m_NodeAry[i].SetHintState(true) ;
					m_NodeAry[peerIdx].SetHintState(true) ;
					--m_LeftHintNum ;
					FlushLevelInfo2UI() ;
					return ;
				}			
			}			
		}
		
		public function Close():void
		{
			m_Timer.stop() ;
			m_AlarmTimer.stop() ;
			m_ShowPathTimer.stop() ;
		}
		
		private function ShowPath(path:Array):void
		{
			if (path.length < 1) return ;
			
			graphics.lineStyle(3, 0xff0000, 0.3) ; 
			
			for(var i:int=0; i<path.length; i+=2)
			{
				if (i == 0) 
					graphics.moveTo(path[i] * Node.NODE_LENGTH + Node.NODE_LENGTH / 2, 
						path[i+1] * Node.NODE_LENGTH + Node.NODE_LENGTH / 2) ;
				else
					graphics.lineTo(path[i] * Node.NODE_LENGTH + Node.NODE_LENGTH / 2, 
						path[i+1] * Node.NODE_LENGTH + Node.NODE_LENGTH / 2) ;
			}
			
			m_ShowPathTimer.start() ;			
		}
		
		public function IsInDeadLock():Boolean
		{
			if (m_NodeAry.length == 0) return false ;
			for(var i:int=0; i<m_NodeAry.length; ++i)
			{
				if (GetLegalPeer(i) != -1) return false ;
			}
			return true ;
		}
		
		// bSystem 是否是系统的重排（为了防止死锁)
		public function ReShuffle(bSystem:Boolean):void
		{
			if (!bSystem && m_LeftShuffleNum == 0) return ;
			if (m_NodeAry.length == 0) return ;
			
			var curHoleAry:Array = new Array() ;
			
			for(var i:int=0; i<m_NodeAry.length; ++i)
			{
				curHoleAry.push(m_NodeAry[i].m_Y * 100 + m_NodeAry[i].m_X) ;
			}
			
			var tmpNodeAry:Array = m_NodeAry.slice() ;
			Shuffle(tmpNodeAry, curHoleAry) ;
			
			if (!bSystem)
			{
				--m_LeftShuffleNum ;
				FlushLevelInfo2UI() ;
			}			
			
			// 取消已经被选中的格子的选中状态
			if (m_LastClickedNode != null)
			{
				m_LastClickedNode.SetPushedState(false) ;
				m_LastClickedNode = null ;	
			}
		}
		
		
		
		
		
	}
	
	
}