//---------------------------------------------------------------------------------------
//  FILE:    RTEffect_TimeStopTag.uc
//  AUTHOR:  Aleosiss
//  DATE:    8 August 2016
//  PURPOSE: Tracks damage preview/calcualtion for TimeStop
//  NOTES: There is absolutely no reason this shouldn't just be a part of TimeStopMaster... except for no discernable reason, the effect will not work when attached there.
//			EDIT: Took me 8 months, but I figured out why it wouldn't work; unfortunately, i'm lazy as fuck and am not going to refactor.
//---------------------------------------------------------------------------------------
//	Time Stop tag effect
//---------------------------------------------------------------------------------------
class RTEffect_TimeStopTag extends X2Effect_Persistent config(RTMarksman);

DefaultProperties
{
	EffectName="TimeStopTagEffect";
}
