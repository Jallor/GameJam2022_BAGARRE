// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Rage"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_MainTex("Base_Texture", 2D) = "white" {}
		_GoToRage("GoToRage", Float) = 0
		[Toggle(_FIRSTCLIENT_ON)] _FirstClient("FirstClient", Float) = 0

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature_local _FIRSTCLIENT_ON


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float _GoToRage;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float4 _Color1 = float4(0,0,0,1);
				float2 uv02 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode1 = tex2D( _MainTex, uv02 );
				float4 appendResult61 = (float4(_Color1.r , _Color1.g , _Color1.b , tex2DNode1.a));
				float4 lerpResult69 = lerp( appendResult61 , tex2DNode1 , float4( 0.1886792,0.1886792,0.1886792,1 ));
				float4 color3 = IsGammaSpace() ? float4(1,0,0,0) : float4(1,0,0,0);
				float4 appendResult60 = (float4(color3.r , color3.g , color3.b , tex2DNode1.a));
				float GoToRage45 = _GoToRage;
				float lerpResult54 = lerp( 1.0 , 10.0 , GoToRage45);
				float lerpResult48 = lerp( 5.0 , 0.5 , GoToRage45);
				float clampResult26 = clamp( (sin( ( _Time.w * lerpResult54 ) )*lerpResult48 + lerpResult48) , -1.0 , 1.0 );
				float4 lerpResult29 = lerp( appendResult60 , tex2DNode1 , saturate( clampResult26 ));
				float4 lerpResult30 = lerp( tex2DNode1 , lerpResult29 , (( GoToRage45 > 0.025 ) ? 1.0 :  0.0 ));
				#ifdef _FIRSTCLIENT_ON
				float4 staticSwitch71 = lerpResult30;
				#else
				float4 staticSwitch71 = lerpResult69;
				#endif
				
				fixed4 c = staticSwitch71;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17600
427;30;1449;989;107.3434;446.9785;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;8;-1626.162,-347.7938;Inherit;False;Property;_GoToRage;GoToRage;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1353.053,-349.1208;Inherit;False;GoToRage;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2121.55,664.4645;Inherit;False;45;GoToRage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1805.876,635.7811;Inherit;False;Constant;_Speed_MAX;Speed_MAX;5;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1801.238,553.5942;Inherit;False;Constant;_Speed_MIN;Speed_MIN;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-1584.248,625.5917;Inherit;False;3;0;FLOAT;5;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;41;-1835.436,347.3996;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1394.847,618.9918;Inherit;False;Constant;_Attenuation_MIN;Attenuation_MIN;2;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1396.832,697.4841;Inherit;False;Constant;_Attenuation_MAX;Attenuation_MAX;2;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1466.67,787.6327;Inherit;False;45;GoToRage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1538.503,420.0982;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-1145.5,743.8478;Inherit;False;3;0;FLOAT;5;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;43;-1371.035,420.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-866.071,701.9368;Inherit;False;Constant;_Max;Max;6;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-973.9515,422.259;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-623.8563,196.5425;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-865.0705,626.2484;Inherit;False;Constant;_Min;Min;5;0;Create;True;0;0;False;0;-1;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;26;-663.6624,527.2484;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-387.3856,-194.9677;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-360.6988,167.7136;Inherit;True;Property;_MainTex;Base_Texture;0;0;Create;False;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;60;1.340284,-171.7427;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;62;-307.9457,-430.6394;Inherit;False;Constant;_Color1;Color 1;2;0;Create;False;0;0;False;0;0,0,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;46;-277.9443,746.6387;Inherit;False;45;GoToRage;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;25;-214.8985,531.0613;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;36;43.46708,753.1962;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0.025;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;221.1721,-15.23122;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;91.7088,-439.9402;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;69;384.6351,-212.9214;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.1886792,0.1886792,0.1886792,1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;30;479.8645,150.7129;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;71;731.6566,42.02155;Inherit;False;Property;_FirstClient;FirstClient;2;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCCompareLower;55;63.56324,600.0666;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;0.025;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;58;1048.147,144.1705;Float;False;True;-1;2;ASEMaterialInspector;0;6;M_Rage;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;45;0;8;0
WireConnection;54;0;51;0
WireConnection;54;1;52;0
WireConnection;54;2;53;0
WireConnection;42;0;41;4
WireConnection;42;1;54;0
WireConnection;48;0;39;0
WireConnection;48;1;50;0
WireConnection;48;2;47;0
WireConnection;43;0;42;0
WireConnection;38;0;43;0
WireConnection;38;1;48;0
WireConnection;38;2;48;0
WireConnection;26;0;38;0
WireConnection;26;1;27;0
WireConnection;26;2;28;0
WireConnection;1;1;2;0
WireConnection;60;0;3;1
WireConnection;60;1;3;2
WireConnection;60;2;3;3
WireConnection;60;3;1;4
WireConnection;25;0;26;0
WireConnection;36;0;46;0
WireConnection;29;0;60;0
WireConnection;29;1;1;0
WireConnection;29;2;25;0
WireConnection;61;0;62;1
WireConnection;61;1;62;2
WireConnection;61;2;62;3
WireConnection;61;3;1;4
WireConnection;69;0;61;0
WireConnection;69;1;1;0
WireConnection;30;0;1;0
WireConnection;30;1;29;0
WireConnection;30;2;36;0
WireConnection;71;1;69;0
WireConnection;71;0;30;0
WireConnection;55;0;46;0
WireConnection;58;0;71;0
ASEEND*/
//CHKSM=A232BFCE23F20431C0746F02AF7E3E23C713F428