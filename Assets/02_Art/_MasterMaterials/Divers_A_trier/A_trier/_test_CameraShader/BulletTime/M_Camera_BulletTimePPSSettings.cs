// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( M_Camera_BulletTimePPSRenderer ), PostProcessEvent.AfterStack, "M_Camera_BulletTime", true )]
public sealed class M_Camera_BulletTimePPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Alpha Cutoff " )]
	public FloatParameter _AlphaCutoff = new FloatParameter { value = 0.5f };
	[Tooltip( "Emission Color" )]
	public ColorParameter _EmissionColor = new ColorParameter { value = new Color(1f,1f,1f,1f) };
}

public sealed class M_Camera_BulletTimePPSRenderer : PostProcessEffectRenderer<M_Camera_BulletTimePPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "M_Camera_BulletTime" ) );
		sheet.properties.SetFloat( "_AlphaCutoff", settings._AlphaCutoff );
		sheet.properties.SetColor( "_EmissionColor", settings._EmissionColor );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
