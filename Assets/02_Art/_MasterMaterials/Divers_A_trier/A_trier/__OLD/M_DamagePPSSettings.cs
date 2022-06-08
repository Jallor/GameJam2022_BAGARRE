// Amplify Shader Editor - Visual Shader Editing Tool
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>
#if UNITY_POST_PROCESSING_STACK_V2
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess( typeof( M_DamagePPSRenderer ), PostProcessEvent.AfterStack, "M_Damage", true )]
public sealed class M_DamagePPSSettings : PostProcessEffectSettings
{
	[Tooltip( "Screen" )]
	public TextureParameter _MainTex = new TextureParameter {  };
	[Tooltip( "Float 0" )]
	public FloatParameter _Float0 = new FloatParameter { value = 0f };
	[Tooltip( "Float 01" )]
	public FloatParameter _Float01 = new FloatParameter { value = 0f };
}

public sealed class M_DamagePPSRenderer : PostProcessEffectRenderer<M_DamagePPSSettings>
{
	public override void Render( PostProcessRenderContext context )
	{
		var sheet = context.propertySheets.Get( Shader.Find( "M_Damage" ) );
		if(settings._MainTex.value != null) sheet.properties.SetTexture( "_MainTex", settings._MainTex );
		sheet.properties.SetFloat( "_Float0", settings._Float0 );
		sheet.properties.SetFloat( "_Float01", settings._Float01 );
		context.command.BlitFullscreenTriangle( context.source, context.destination, sheet, 0 );
	}
}
#endif
