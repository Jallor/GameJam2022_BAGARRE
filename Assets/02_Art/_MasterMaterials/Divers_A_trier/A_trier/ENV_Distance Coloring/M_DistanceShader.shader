// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_DistanceShader"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("_MainTex", 2D) = "white" {}
		_0MinDist("0- MinDist", Int) = 750
		_0MaxDist("0- MaxDist", Int) = 900
		_1Color_Front("1- Color_Front", Color) = (0.5686275,0.3294118,0.5921569,1)
		_1Colorint("1- Color int", Range( 0 , 10)) = 1
		_1Detailsopacity("1- Details opacity", Range( 0 , 1)) = 1
		_2Color_Back("2- Color_Back", Color) = (1,0.8352942,0.6078432,1)
		_3Coloremissive("3- Color emissive", Color) = (1,0.444982,0,0)
		_3Emissive_int_Back("3- Emissive_int_Back", Float) = 15
		_3Emissive_intFront("3- Emissive_int Front", Float) = 15
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero , One Zero
			ZWrite On
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

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _1Color_Front;
			float4 _2Color_Back;
			int _0MinDist;
			int _0MaxDist;
			float _1Colorint;
			float _1Detailsopacity;
			float _3Emissive_int_Back;
			float _3Emissive_intFront;
			float4 _3Coloremissive;
			float4 _MainTex_ST;
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
				float2 uv0101 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode3_g1 = tex2D( _MainTex, uv0101 );
				float R4_g1 = tex2DNode3_g1.r;
				float4 transform8 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float Distance105 = (0.0 + (distance( transform8.z , _WorldSpaceCameraPos.z ) - (float)_0MinDist) * (1.0 - 0.0) / ((float)_0MaxDist - (float)_0MinDist));
				float4 lerpResult104 = lerp( _1Color_Front , _2Color_Back , Distance105);
				float G6_g1 = tex2DNode3_g1.g;
				float4 lerpResult43_g1 = lerp( float4( 0,0,0,0 ) , ( ( float4( 0,0,0,0 ) * G6_g1 ) * 0.0 ) , 1.0);
				float4 lerpResult20_g1 = lerp( ( ( R4_g1 * lerpResult104 ) * _1Colorint ) , lerpResult43_g1 , R4_g1);
				float4 lerpResult110 = lerp( _1Color_Front , lerpResult20_g1 , _1Detailsopacity);
				float4 lerpResult11 = lerp( lerpResult110 , _2Color_Back , Distance105);
				float B17_g1 = tex2DNode3_g1.b;
				float3 temp_cast_2 = (B17_g1).xxx;
				float3 saferPower14_g262 = max( temp_cast_2 , 0.0001 );
				float3 temp_cast_3 = (50.0).xxx;
				float3 temp_output_14_0_g262 = pow( saferPower14_g262 , temp_cast_3 );
				float lerpResult102 = lerp( _3Emissive_int_Back , _3Emissive_intFront , Distance105);
				
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float A27_g1 = tex2D( _MainTex, uv_MainTex ).a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult11 + ( float4( ( temp_output_14_0_g262 * lerpResult102 ) , 0.0 ) * _3Coloremissive ) ).rgb;
				float Alpha = A27_g1;
				float AlphaClipThreshold = 0.35;

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

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _1Color_Front;
			float4 _2Color_Back;
			int _0MinDist;
			int _0MaxDist;
			float _1Colorint;
			float _1Detailsopacity;
			float _3Emissive_int_Back;
			float _3Emissive_intFront;
			float4 _3Coloremissive;
			float4 _MainTex_ST;
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float A27_g1 = tex2D( _MainTex, uv_MainTex ).a;
				
				float Alpha = A27_g1;
				float AlphaClipThreshold = 0.35;

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
-1280;90;1280;653;2051.517;237.594;2.110884;True;False
Node;AmplifyShaderEditor.CommentaryNode;109;-2810.29,131.841;Inherit;False;1182.682;499.7196;;7;8;7;6;21;20;10;105;VAR - distance;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;8;-2705.842,181.841;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;7;-2760.29,364.9297;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;20;-2373.732,515.5608;Inherit;False;Property;_0MaxDist;0- MaxDist;10;0;Create;True;0;0;False;0;900;0;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;21;-2372.678,431.4406;Inherit;False;Property;_0MinDist;0- MinDist;9;0;Create;True;0;0;False;0;750;0;0;1;INT;0
Node;AmplifyShaderEditor.DistanceOpNode;6;-2318.131,254.641;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;10;-2082.527,412.6728;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1000;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-1851.609,409.1617;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-814.7407,1151.445;Inherit;False;Property;_3Emissive_int_Back;3- Emissive_int_Back;16;0;Create;True;0;0;False;0;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-1287.036,180.8017;Inherit;False;Property;_2Color_Back;2- Color_Back;14;0;Create;True;0;0;False;0;1,0.8352942,0.6078432,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-1401.361,672.7375;Inherit;False;Property;_1Color_Front;1- Color_Front;11;0;Create;True;0;0;False;0;0.5686275,0.3294118,0.5921569,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;108;-553.6261,1202.5;Inherit;False;105;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1021.55,1177.539;Inherit;False;Property;_3Emissive_intFront;3- Emissive_int Front;17;0;Create;True;0;0;False;0;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-892.3824,718.9529;Inherit;False;105;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;94;-983.5489,772.9158;Inherit;False;Property;_3Coloremissive;3- Color emissive;15;0;Create;True;0;0;False;0;1,0.444982,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;93;-1646.765,629.1007;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;False;0;0;True;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;104;-572.1338,674.8872;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;102;-259.5734,1158.575;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-1178.123,650.3455;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;97;-562.4266,577.5366;Inherit;False;Property;_1Colorint;1- Color int;12;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-844.0748,387.0731;Inherit;False;Property;_1Detailsopacity;1- Details opacity;13;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;110;161.2504,337.1885;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;11;372.7492,166.3811;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;763.4915,169.4219;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;100;-89.81443,604.5421;Inherit;False;MF_Colorize_RGB;1;;1;09864a89fc748b5448601e7177115326;0;9;44;FLOAT;1;False;36;SAMPLER2D;0;False;42;FLOAT2;0,0;False;33;COLOR;0,0,0,0;False;30;FLOAT;0;False;34;COLOR;0,0,0,0;False;31;FLOAT;0;False;35;COLOR;0,0,0,0;False;32;FLOAT;0;False;7;COLOR;28;FLOAT3;29;COLOR;0;FLOAT;37;FLOAT;38;FLOAT;39;FLOAT;40
Node;AmplifyShaderEditor.GetLocalVarNode;106;-215.9235,207.3653;Inherit;False;105;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;945.2231,216.7702;Inherit;False;Constant;_alphatreshold;alpha treshold;9;0;Create;True;0;0;False;0;0.35;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;45;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;1571.994,164.592;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_DistanceShader;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;44;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;41;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;6;0;8;3
WireConnection;6;1;7;3
WireConnection;10;0;6;0
WireConnection;10;1;21;0
WireConnection;10;2;20;0
WireConnection;105;0;10;0
WireConnection;104;0;5;0
WireConnection;104;1;12;0
WireConnection;104;2;107;0
WireConnection;102;0;95;0
WireConnection;102;1;103;0
WireConnection;102;2;108;0
WireConnection;110;0;5;0
WireConnection;110;1;100;28
WireConnection;110;2;111;0
WireConnection;11;0;110;0
WireConnection;11;1;12;0
WireConnection;11;2;106;0
WireConnection;98;0;11;0
WireConnection;98;1;100;0
WireConnection;100;36;93;0
WireConnection;100;42;101;0
WireConnection;100;33;104;0
WireConnection;100;30;97;0
WireConnection;100;35;94;0
WireConnection;100;32;102;0
WireConnection;42;2;98;0
WireConnection;42;3;100;40
WireConnection;42;4;34;0
ASEEND*/
//CHKSM=3049ABF16BC88BEDC243B375BDF0192A07AFF641