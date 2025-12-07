
library FrameHeroScoreFrameOptions
	globals
		private boolean CreateOptionsInMenu = true
		private real OptionX = 0.1
		private real OptionY = 0.55
	endglobals
	
	private function ValueActionHeroScoreFrameOptionsSlider1 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			set HeroScoreFrame_TooltipScale = BlzGetTriggerFrameValue()
		endif
		call ExecuteFunc("HeroScoreFrameUpdateScale")
	endfunction
	private function WheelActionHeroScoreFrameOptionsSlider1 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			if BlzGetTriggerFrameValue() > 0 then
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) + .05)
			else
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) - .05)
			endif
		endif
	endfunction
	private function ValueActionHeroScoreFrameOptionsSlider2 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			set HeroScoreFrame_AllyScale = BlzGetTriggerFrameValue()
		endif
		call ExecuteFunc("HeroScoreFrameUpdateScale")
	endfunction
	private function WheelActionHeroScoreFrameOptionsSlider2 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			if BlzGetTriggerFrameValue() > 0 then
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) + .05)
			else
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) - .05)
			endif
		endif
	endfunction
	private function ValueActionHeroScoreFrameOptionsSlider3 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			set HeroScoreFrame_Scale = BlzGetTriggerFrameValue()    
		endif
		call ExecuteFunc("HeroScoreFrameUpdateScale")
	endfunction
	private function WheelActionHeroScoreFrameOptionsSlider3 takes nothing returns nothing
		if GetLocalPlayer() == GetTriggerPlayer() then
			if BlzGetTriggerFrameValue() > 0 then
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) + .05)
			else
				call BlzFrameSetValue(BlzGetTriggerFrame(), BlzFrameGetValue(BlzGetTriggerFrame()) - .05)
			endif
		endif
	endfunction
	private function ActionHeroScoreFrameOptionsCheckBox4 takes nothing returns nothing
		local boolean checked = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED
		if GetLocalPlayer() == GetTriggerPlayer() then
			set HeroScoreFrame_HideText = checked
		endif
	endfunction
	private function ActionHeroScoreFrameOptionsCheckBox5 takes nothing returns nothing
		local boolean checked = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED
		if GetLocalPlayer() == GetTriggerPlayer() then
			set HeroScoreFrame_HideTextPack = checked
		endif
	endfunction
	
	public function Create takes integer index returns nothing
		local trigger trig
		if CreateOptionsInMenu then
			call BlzCreateFrame("HeroScoreFrameOptions", BlzGetFrameByName("InsideMainPanel", 0), 0, 0)
		else
			call BlzCreateFrame("HeroScoreFrameOptions", BlzGetFrameByName("HeroScoreFrameParent", 0), 0, 0)
		endif
		call BlzFrameSetAbsPoint(BlzGetFrameByName("HeroScoreFrameOptions", 0), FRAMEPOINT_TOPLEFT, OptionX, OptionY)
	
		call BlzFrameSetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider1", index), HeroScoreFrame_TooltipScale)
		call BlzFrameSetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider2", index), HeroScoreFrame_AllyScale)
		call BlzFrameSetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider3", index), HeroScoreFrame_Scale)
	
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider1", index), FRAMEEVENT_SLIDER_VALUE_CHANGED)
		call TriggerAddAction(trig, function ValueActionHeroScoreFrameOptionsSlider1)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider1", index), FRAMEEVENT_MOUSE_WHEEL)
		call TriggerAddAction(trig, function WheelActionHeroScoreFrameOptionsSlider1)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider2", index), FRAMEEVENT_SLIDER_VALUE_CHANGED)
		call TriggerAddAction(trig, function ValueActionHeroScoreFrameOptionsSlider2)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider2", index), FRAMEEVENT_MOUSE_WHEEL)
		call TriggerAddAction(trig, function WheelActionHeroScoreFrameOptionsSlider2)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider3", index), FRAMEEVENT_SLIDER_VALUE_CHANGED)
		call TriggerAddAction(trig, function ValueActionHeroScoreFrameOptionsSlider3)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsSlider3", index), FRAMEEVENT_MOUSE_WHEEL)
		call TriggerAddAction(trig, function WheelActionHeroScoreFrameOptionsSlider3)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsCheckBox4", index), FRAMEEVENT_CHECKBOX_CHECKED)
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsCheckBox4", index), FRAMEEVENT_CHECKBOX_UNCHECKED)
		call TriggerAddAction(trig, function ActionHeroScoreFrameOptionsCheckBox4)
		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsCheckBox5", index), FRAMEEVENT_CHECKBOX_CHECKED)
		call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameOptionsCheckBox5", index), FRAMEEVENT_CHECKBOX_UNCHECKED)
		call TriggerAddAction(trig, function ActionHeroScoreFrameOptionsCheckBox5)
	endfunction
endlibrary