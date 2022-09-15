class RTUIImageButton extends UIPanel;

var UIImage Button;
var UIPanel BG;
var UIImage ControllerIcon;
var string ControllerButtonIconPath;

var float ButtonWidth;
var float ButtonHeight;

var delegate<OnClickedCallback> OnClickedDelegate;
delegate OnClickedCallback(UIImage Image);

defaultproperties
{
    ControllerButtonIconPath = "";
    ButtonWidth = 80;
    ButtonHeight = 80;
	bIsNavigable = false;
	bProcessesMouseEvents = true;
}

simulated function InitImageButton(name ButtonName, string ImagePath, delegate<OnClickedCallback> OnClickDel)
{
	InitPanel(ButtonName);
    `RTLOG("InitImageButton for " $ ButtonName);

    self.OnClickedDelegate = OnClickDel;

    if(ControllerButtonIconPath == "") {
        ControllerButtonIconPath = class'UIUtilities_Input'.const.ICON_Y_TRIANGLE;
    }

	BG = Spawn(class'UIPanel', self);
	BG.InitPanel('BG', 'X2MenuBG');
	BG.SetSize(115, 115);
	BG.SetPosition(-5, -5);
	BG.SetAlpha(80);

	Button = Screen.Spawn(class'UIImage', self);
	Button.InitImage('Button', "img:///RisingTidesContentPackage.UIImages.vhs_program_icon_v2_border_grey", OnConfirmButtonInited);
	Button.SetSize(ButtonWidth, ButtonHeight);
	Button.SetPosition(10, 10);
    Button.AnchorTopLeft();
	
	if (`ISCONTROLLERACTIVE)
	{
		ControllerIcon = Spawn(class'UIImage', self);
		ControllerIcon.InitImage('ControllerIcon', "img:///gfxGamepadIcons." $ class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ ControllerButtonIconPath);
		ControllerIcon.AnchorTopLeft();
		ControllerIcon.SetSize(40, 40);
		ControllerIcon.SetPosition(64, 64);
	}
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	
	Update();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	Update();
}

simulated function Update() {
	if(bIsFocused) {
        SetFocused();
    } else {
        SetUnfocused();
    }
}

simulated function SetFocused() {
    Button.SetSize(ButtonWidth * 1.1, ButtonHeight * 1.1);
    Button.SetPosition(Button.X * 0.5, Button.Y * 0.5);
}

simulated function SetUnfocused() {
    Button.SetSize(ButtonWidth, ButtonHeight);
    Button.SetPosition(10, 10);
}

function OnConfirmButtonInited(UIImage Panel) {
    SetUnfocused();
    OnClickedDelegate(Panel);
}