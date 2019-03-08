RTUIScreenListerner_ProgramFactionScreen extends UIScreenListener;

var UIButton b;

event OnInit(UIScreen Screen)
{
	
	if(UIStrategyMap(Screen) != none) {
		ShowProgramFactionScreenButton();
	}
}

event OnRemoved(UIScreen Screen) {
	if(UIStrategyMap(Screen) != none) {

		ManualGC();
	}
}

simulated function ShowProgramFactionScreenButton() {
	
}

simulated function ManualGC() {
	if(b != none) {
		b.Remove();
	}
	b = none;
}