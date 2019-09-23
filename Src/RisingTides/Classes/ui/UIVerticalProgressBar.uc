class UIVerticalProgressBar extends UIProgressBar;


simulated function UIPanel SetSize(float NewWidth, float NewHeight)
{
    if (Width != NewWidth || Height != NewHeight)
    {
        Width = NewWidth;
        Height = NewHeight;

        BGBar.SetSize(Width, Height);

        // changed to width from height
        FillBar.SetWidth(Width);
        SetPercent(Percent); 
    }
    return self; 
}

// Percent as value 0.0 to 1.0 
simulated function SetPercent(float DisplayPercent)
{
    if (DisplayPercent <= 0.01)
    {
        FillBar.Hide();
        FillBar.SetHeight(1); // NEVER set size to zero, or scaleform freaks out. 
    }
    else if( DisplayPercent > 1.0 && DisplayPercent <= 100.0 )
    {
        `log("Warning: You're not sending the percent bar a value between 0.0 and 1.0. (Your value, '" $ DisplayPercent $"', is between 0 and 100.) We'll auto convert for now, but you should fix this.");
        Fillbar.SetHeight(DisplayPercent * Height * 0.01);
        FillBar.Show();
    }
    else if (DisplayPercent > 100.0)
    {
        `log("Warning: You're not sending the percent bar a value between 0.0 and 1.0. Your value, '" $ DisplayPercent $"', is over 100.0, so extra incorrect. Capping you at 1.0, but you should fix this.");
        Fillbar.SetHeight(1.0 * Height);
        FillBar.Show();
    }
    else
    {
        Fillbar.SetHeight(DisplayPercent * Height);
        FillBar.Show();
    }
}