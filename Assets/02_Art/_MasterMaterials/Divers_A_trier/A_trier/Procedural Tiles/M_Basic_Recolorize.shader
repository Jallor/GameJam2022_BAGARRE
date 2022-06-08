// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Test"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Texture1("Texture 0", 2D) = "white" {}
		_tiles("tiles", Float) = 1
		_X("X", Range( 0 , 0.5)) = 0
		_Y("Y", Range( -1.5 , -1)) = -1
		_1color_foregroundRchannel1("1-color_foreground (R channel)", Color) = (1,0.7490196,0.9764706,0)
		_1intensity_foregroundRchannel1("1-intensity_foreground (R channel)", Range( 0 , 20)) = 1
		_1color_backgroundGGchannel1("1-color_background G (G channel)", Color) = (0.5921569,0.5176471,0.7450981,0)
		_1intensity_backgroundGGchannel1("1-intensity_background  G (G channel)", Range( 0 , 20)) = 2
		_1color_emissiveBchannel1("1-color_emissive (B channel)", Color) = (1,0.4313726,0,0)
		_intensity_emissiveBBchannel2("1-intensity_emissive B (B channel)", Range( 0 , 30)) = 5.2

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Texture1;
			CBUFFER_START( UnityPerMaterial )
			float _tiles;
			float _X;
			float _Y;
			float _intensity_emissiveBBchannel2;
			float4 _1color_emissiveBchannel1;
			float4 _1color_foregroundRchannel1;
			float _1intensity_foregroundRchannel1;
			float4 _1color_backgroundGGchannel1;
			float _1intensity_backgroundGGchannel1;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 temp_cast_0 = (_tiles).xx;
				float2 appendResult19 = (float2(_X , _Y));
				float2 uv015 = IN.ase_texcoord3.xy * temp_cast_0 + appendResult19;
				float4 tex2DNode3_g412 = tex2D( _Texture1, uv015 );
				float B17_g412 = tex2DNode3_g412.b;
				float3 temp_cast_1 = (B17_g412).xxx;
				float3 saferPower14_g413 = max( temp_cast_1 , 0.0001 );
				float3 temp_cast_2 = (5.0).xxx;
				float3 temp_output_14_0_g413 = pow( saferPower14_g413 , temp_cast_2 );
				float R4_g412 = tex2DNode3_g412.r;
				float4 lerpResult43_g412 = lerp( float4( 0,0,0,0 ) , ( ( _1color_backgroundGGchannel1 * R4_g412 ) * _1intensity_backgroundGGchannel1 ) , 1.0);
				float G6_g412 = tex2DNode3_g412.g;
				float4 lerpResult20_g412 = lerp( ( ( R4_g412 * _1color_foregroundRchannel1 ) * _1intensity_foregroundRchannel1 ) , lerpResult43_g412 , G6_g412);
				
				float A27_g412 = tex2DNode3_g412.a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( float4( ( temp_output_14_0_g413 * _intensity_emissiveBBchannel2 ) , 0.0 ) * _1color_emissiveBchannel1 ) + lerpResult20_g412 ).rgb;
				float Alpha = A27_g412;
				float AlphaClipThreshold = 0.0;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Texture1;
			CBUFFER_START( UnityPerMaterial )
			float _tiles;
			float _X;
			float _Y;
			float _intensity_emissiveBBchannel2;
			float4 _1color_emissiveBchannel1;
			float4 _1color_foregroundRchannel1;
			float _1intensity_foregroundRchannel1;
			float4 _1color_backgroundGGchannel1;
			float _1intensity_backgroundGGchannel1;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 temp_cast_0 = (_tiles).xx;
				float2 appendResult19 = (float2(_X , _Y));
				float2 uv015 = IN.ase_texcoord2.xy * temp_cast_0 + appendResult19;
				float4 tex2DNode3_g412 = tex2D( _Texture1, uv015 );
				float A27_g412 = tex2DNode3_g412.a;
				
				float Alpha = A27_g412;
				float AlphaClipThreshold = 0.0;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18000
-1280;84;1280;659;3092.116;662.1953;1.422392;True;False
Node;AmplifyShaderEditor.RangedFloatNode;18;-2453.511,60.58549;Inherit;False;Property;_Y;Y;11;0;Create;True;0;0;False;0;-1;0;-1.5;-1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2428.025,-85.25128;Inherit;False;Property;_X;X;10;0;Create;True;0;0;False;0;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2270.598,44.09982;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2268.592,-153.4364;Inherit;False;Property;_tiles;tiles;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2002.806,-186.6742;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-2009.262,53.45517;Inherit;False;Property;_1color_backgroundGGchannel1;1-color_background G (G channel);14;0;Create;True;0;0;False;0;0.5921569,0.5176471,0.7450981,0;0.5909448,0.517647,0.7450981,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1682.606,81.55605;Inherit;False;Property;_1intensity_backgroundGGchannel1;1-intensity_background  G (G channel);15;0;Create;True;0;0;False;0;2;2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-2704.466,-58.67924;Inherit;True;Property;_Texture1;Texture 0;8;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;8;-1436.436,-142.9508;Inherit;False;Property;_1color_foregroundRchannel1;1-color_foreground (R channel);12;0;Create;True;0;0;False;0;1,0.7490196,0.9764706,0;1,0.75,0.9778225,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1463.342,-217.6064;Inherit;False;Property;_1intensity_foregroundRchannel1;1-intensity_foreground (R channel);13;0;Create;True;0;0;False;0;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1477.557,220.5504;Inherit;False;Property;_1color_emissiveBchannel1;1-color_emissive (B channel);16;0;Create;True;0;0;False;0;1,0.4313726,0,0;1,0.431647,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1503.729,395.4017;Inherit;False;Property;_intensity_emissiveBBchannel2;1-intensity_emissive B (B channel);17;0;Create;False;0;0;False;0;5.2;5.2;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;13;-917.6506,-94.11355;Inherit;False;MF_Colorize_RGB;0;;412;09864a89fc748b5448601e7177115326;0;9;44;FLOAT;1;False;36;SAMPLER2D;0;False;42;FLOAT2;0,0;False;33;COLOR;0,0,0,0;False;30;FLOAT;0;False;34;COLOR;0,0,0,0;False;31;FLOAT;0;False;35;COLOR;0,0,0,0;False;32;FLOAT;0;False;7;COLOR;28;FLOAT3;29;COLOR;0;FLOAT;37;FLOAT;38;FLOAT;39;FLOAT;40
Node;AmplifyShaderEditor.RangedFloatNode;14;-445.4045,259.6792;Inherit;False;Constant;_1;1;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-285.603,5.40985;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;-5.682479,-1.89416;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Test;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;15;0;16;0
WireConnection;15;1;19;0
WireConnection;13;36;11;0
WireConnection;13;42;15;0
WireConnection;13;33;8;0
WireConnection;13;30;10;0
WireConnection;13;34;9;0
WireConnection;13;31;5;0
WireConnection;13;35;7;0
WireConnection;13;32;6;0
WireConnection;12;0;13;0
WireConnection;12;1;13;28
WireConnection;1;2;12;0
WireConnection;1;3;13;40
WireConnection;1;4;14;0
ASEEND*/
//CHKSM=8D46D0ECEAB9C2429AF153C8CB211F12640DAFB3