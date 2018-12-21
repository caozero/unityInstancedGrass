// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Cpz/water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)		
		_Extent("波纹幅度",Float)=0.01
		_UvOffset("纹理偏移",Vector)=(1,1,1,1)
		_UvOffset2("纹理偏移",Vector)=(0,0,0,0)
		_MixRate("混合比率", Range(0,1))=0.5
		_Scale("缩放",Float)=1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent+1000" "Queue" = "Geometry"}
		LOD 100
        GrabPass
        {
            "_GrabTexture"
        }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				//float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 grabPos : TEXCOORD0;
				float4 screenPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;			
            fixed4 _Color;
            float _Extent;
			sampler2D _GrabTexture;
			float4 _UvOffset;
			float4 _UvOffset2;
			float _MixRate;
			float _Scale;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.screenPos = ComputeScreenPos(o.vertex+_UvOffset2);			

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			fixed4 GetUnderwater(float4 uv){
			    half4 col = tex2Dproj(_GrabTexture, uv);
			    return col;
			}
			fixed4 GetReflection(float4 uv){
			    half4 col = tex2D(_GrabTexture, uv);
			    return col;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 wave = tex2D(_MainTex, i.grabPos.xy*float2(.2,.2)+float2(0,-_Time.x*2));
				float4 uv=i.grabPos+wave*_Extent;
				fixed4 uwCol=GetUnderwater(uv);
				float4 rfUv=i.screenPos+_UvOffset;
				rfUv.y=1+rfUv.y;
				fixed4 rfCol=tex2Dproj(_GrabTexture, uv+_UvOffset);
				fixed4 col=lerp(uwCol,rfCol,_MixRate)*_Color;				
				UNITY_APPLY_FOG(i.fogCoord, rfCol);
				return rfCol;
			}
			ENDCG
		}
	}
}
