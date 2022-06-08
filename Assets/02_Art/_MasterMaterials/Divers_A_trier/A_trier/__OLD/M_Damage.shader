// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Damage"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Float0("Float 0", Float) = 100
		_Float01("Float 01", Float) = 100

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			

			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _Float0;
			uniform float _Float01;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv07 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float pixelWidth3 =  1.0f / _Float0;
				float pixelHeight3 = 1.0f / _Float01;
				half2 pixelateduv3 = half2((int)(uv07.x / pixelWidth3) * pixelWidth3, (int)(uv07.y / pixelHeight3) * pixelHeight3);
				

				finalColor = tex2D( _MainTex, pixelateduv3 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17600
0;0;1920;1019;1023;371.5;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;5;-574,271.5;Inherit;False;Property;_Float0;Float 0;0;0;Create;True;0;0;False;0;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-595,354.5;Inherit;False;Property;_Float01;Float 01;1;0;Create;True;0;0;False;0;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-630,56.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCPixelate;3;-347,266.5;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;2;-115,147.5;Inherit;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;100,233.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;456,6;Float;False;True;-1;2;ASEMaterialInspector;0;2;M_Damage;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;3;0;7;0
WireConnection;3;1;5;0
WireConnection;3;2;6;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;0;0;4;0
ASEEND*/
//CHKSM=CA6CA21C2C618EA08CE5018EECDE933225859019