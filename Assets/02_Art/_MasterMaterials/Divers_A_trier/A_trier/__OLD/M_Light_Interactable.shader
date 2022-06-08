// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Light_Interactable"
{
	Properties
	{
		_DIFFUSE_color("DIFFUSE_color", Color) = (1,1,1,0)
		_EMISSIVE_intensity("EMISSIVE_intensity", Float) = 1
		[Toggle(_ISPANNING_ON)] _IsPanning("IsPanning", Float) = 1
		_PANNING_color("PANNING_color", Color) = (1,1,1,0)
		_PANNING_texture("PANNING_texture", 2D) = "white" {}
		_PANNING_tile("PANNING_tile", Float) = 1
		_PANNING_speed_Y("PANNING_speed_Y", Float) = 1
		[Toggle(_ISFLICKERING_ON)] _IsFlickering("IsFlickering", Float) = 0
		_FLICKING_color("FLICKING_color", Color) = (1,1,1,0)
		_FLICKING_attenuation("FLICKING_attenuation", Float) = 2
		_FLICKING_speed("FLICKING_speed", Float) = 8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _ISFLICKERING_ON
		#pragma shader_feature_local _ISPANNING_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _DIFFUSE_color;
		uniform float4 _PANNING_color;
		uniform sampler2D _PANNING_texture;
		uniform float _PANNING_speed_Y;
		uniform float _PANNING_tile;
		uniform float _FLICKING_speed;
		uniform float _FLICKING_attenuation;
		uniform float4 _FLICKING_color;
		uniform float _EMISSIVE_intensity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _DIFFUSE_color.rgb;
			float4 temp_cast_1 = 1;
			float2 appendResult12 = (float2(0.0 , _PANNING_speed_Y));
			float2 temp_cast_2 = (_PANNING_tile).xx;
			float2 uv_TexCoord10 = i.uv_texcoord * temp_cast_2;
			float2 panner9 = ( 1.0 * _Time.y * appendResult12 + uv_TexCoord10);
			#ifdef _ISPANNING_ON
				float4 staticSwitch19 = tex2D( _PANNING_texture, panner9 );
			#else
				float4 staticSwitch19 = temp_cast_1;
			#endif
			float clampResult20 = clamp( (sin( ( _Time.w * _FLICKING_speed ) )*_FLICKING_attenuation + _FLICKING_attenuation) , -1.0 , 1.0 );
			#ifdef _ISFLICKERING_ON
				float4 staticSwitch37 = ( clampResult20 * _FLICKING_color );
			#else
				float4 staticSwitch37 = ( _PANNING_color * staticSwitch19 );
			#endif
			o.Emission = ( staticSwitch37 * _EMISSIVE_intensity ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17600
0;6;1920;1013;986.3611;273.2661;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;11;-2355.487,356.8029;Inherit;False;Property;_PANNING_speed_Y;PANNING_speed_Y;6;0;Create;True;0;0;False;0;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2667.188,158.8563;Inherit;False;Property;_PANNING_tile;PANNING_tile;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2108.952,744.2701;Inherit;False;Property;_FLICKING_speed;FLICKING_speed;10;0;Create;True;0;0;False;0;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;24;-2138.512,455.8885;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2448.763,140.8367;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;12;-2142.545,334.1313;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1841.579,528.5872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;9;-1995.634,141.8778;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;30;-1674.111,528.5349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1697.923,727.4808;Inherit;False;Property;_FLICKING_attenuation;FLICKING_attenuation;9;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;36;-1485.02,-14.25593;Inherit;False;Constant;_Int0;Int 0;5;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;31;-1277.027,530.7479;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1734.289,113.1567;Inherit;True;Property;_PANNING_texture;PANNING_texture;4;0;Create;True;0;0;False;0;-1;None;238e29caa7051c84baee19b629836dbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-1158.625,257.6933;Inherit;False;Property;_PANNING_color;PANNING_color;3;0;Create;True;0;0;False;0;1,1,1,0;0,1,0.03675985,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;40;-683.0052,799.3239;Inherit;False;Property;_FLICKING_color;FLICKING_color;8;0;Create;True;0;0;False;0;1,1,1,0;0,1,0.03675985,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;19;-1307.651,88.74939;Inherit;False;Property;_IsPanning;IsPanning;2;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;20;-966.7383,635.7374;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-832.382,71.28876;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-520.0886,638.1389;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-323.2093,289.6902;Inherit;False;Property;_EMISSIVE_intensity;EMISSIVE_intensity;1;0;Create;True;0;0;False;0;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;37;-413.8521,66.80206;Inherit;False;Property;_IsFlickering;IsFlickering;7;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;29.95481,1.595786;Inherit;False;Property;_DIFFUSE_color;DIFFUSE_color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;109.5124,268.5919;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;449.3024,13.53321;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;M_Light_Interactable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;38;0
WireConnection;12;1;11;0
WireConnection;28;0;24;4
WireConnection;28;1;21;0
WireConnection;9;0;10;0
WireConnection;9;2;12;0
WireConnection;30;0;28;0
WireConnection;31;0;30;0
WireConnection;31;1;25;0
WireConnection;31;2;25;0
WireConnection;14;1;9;0
WireConnection;19;1;36;0
WireConnection;19;0;14;0
WireConnection;20;0;31;0
WireConnection;13;0;5;0
WireConnection;13;1;19;0
WireConnection;39;0;20;0
WireConnection;39;1;40;0
WireConnection;37;1;13;0
WireConnection;37;0;39;0
WireConnection;7;0;37;0
WireConnection;7;1;6;0
WireConnection;0;0;8;0
WireConnection;0;2;7;0
ASEEND*/
//CHKSM=A301E7FAACDCB1B319FE51D0D024C7ECC083813D