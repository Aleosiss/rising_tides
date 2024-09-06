// author: Iridar
class UIDelegateHolder extends UIPanel;

var delegate<OriginalOnClickedDelegate> OriginalDelegate;

delegate OriginalOnClickedDelegate(UIButton Button);

simulated function CallDelegate(UIButton Button) {
    OriginalDelegate(Button);
    Remove();
}