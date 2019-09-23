class RTEventListener extends X2EventListener config(ProgramFaction);

// Stolen from RealityMachina
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(RTContinueFactionHQReveal());

	return Templates;
}

static function X2EventListenerTemplate RTContinueFactionHQReveal()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'RT_FactionHQReveal');
	Template.RegisterInStrategy = true;
	Template.AddEvent('RevealHQ_Program', ResumeFactionHQReveal);

	return Template;
}

static protected function EventListenerReturn ResumeFactionHQReveal(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	`HQPRES.FactionRevealPlayClassIntroMovie();

	return ELR_NoInterrupt;
}

