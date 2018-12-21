Shader "Cpz/Grass"
{
	Properties {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_WindTex ("风贴图", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HDR]_Color ("颜色", Color) = (0,1,0,1)
        _Height("高度",Float)=1
        _WindSpeed("风速",Float)=2
        _WindSize("风尺寸",Float)=10
		_StampTex ("脚印贴图", 2D) = "white" {}
        _StampVector("脚印中心",Vector)=(0,0,0,0)
    }
    SubShader {
        Tags {"Queue"="AlphaTest" "RenderType"="Opaque" "IgnoreProjector"="True"}
        LOD 200
        Cull Off

        CGPROGRAM
        #pragma multi_compile_instancing
        #pragma surface surf Standard Custom addshadow vertex:vert
        
        #pragma instancing_options procedural:setup
        #include "UnityPBSLighting.cginc"
        
        sampler2D _MainTex;
        sampler2D _WindTex;
        float _Height;
        float _WindSpeed;
        float _WindSize;
        float4 _StampVector;
        sampler2D _StampTex;
        
        half _Glossiness;
        half _Metallic;
        float4 _Color;
        struct Input {
            float2 uv_MainTex;
        };

        #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            StructuredBuffer<float4> positionBuffer;
        #endif

        void rotate2D(inout float2 v, float r)
        {
            float s, c;
            sincos(r, s, c);
            v = float2(v.x * c - v.y * s, v.x * s + v.y * c);
        }
        void setup()
        {
        #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            float4 data = positionBuffer[unity_InstanceID];
            float scale=_Height*data.w;

            unity_ObjectToWorld._11_21_31_41 = float4(scale, 0, 0, 0);
            unity_ObjectToWorld._12_22_32_42 = float4(0, scale, 0, 0);
            unity_ObjectToWorld._13_23_33_43 = float4(0, 0, scale, 0);
            unity_ObjectToWorld._14_24_34_44 = float4(data.xyz, 1);
            unity_WorldToObject = unity_ObjectToWorld;
            unity_WorldToObject._14_24_34 *= -1;
            unity_WorldToObject._11_22_33 = 1.0f / unity_WorldToObject._11_22_33;
        #endif
        }
        void RotateFixed(inout appdata_full v,float rote){
            float2 rv2=float2(v.vertex.x,v.vertex.z);
            rotate2D(rv2,rote);
            v.vertex.x=rv2.x;
            v.vertex.z=rv2.y;
        }
        float GetStamp(float2 position,float height){
            //_StampVector.xz   踩踏投影的水平坐标点
            //_StampVector.y    最低降低程度
            //_StampVector.w    踩踏投影尺寸
            //以物体减去踩踏投影中心点的的位置采样踩踏数据
            //超出范围不采样
            float2 stampUv=(position.xy-_StampVector.xz)/_StampVector.w+float2(0.5,.5);
            float4 stampP=float4(0,0,0,0);
            if(stampUv.x>0 && stampUv.x<1 && stampUv.y>0 && stampUv.y<1){
                stampP=tex2Dlod(_StampTex,float4(stampUv,0.0,0.0));
            }             
            float y=height*(1-stampP.a);
            return min(height,max(_StampVector.y,y));
        }  
        
        float GetWindWave(float2 position,float height){
            //以物体坐标点采样风的强度,
            //风按照时间*风速移动,以高度不同获得略微有差异的数据
            //移动值以高度不同进行减免,越低移动的越少.
            //根据y值获得不同的
            float4 p=tex2Dlod(_WindTex,float4(position/_WindSize+float2(_Time.x*_WindSpeed+height*.01,0),0.0,0.0)); 
            return (height*(p.r-.5));
        } 
        //自定义的顶点运算
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            float4 data = positionBuffer[unity_InstanceID];
            //对植物按照固态数据进行旋转 
            RotateFixed(v,(data.x+data.y+data.z+data.w*10000));
            //获取踩踏数据
            v.vertex.y=GetStamp(data.xz,v.vertex.y);
            //获取风流动数据
            float w=GetWindWave(data.xz,v.vertex.y);
            //水平推动草的位置
            v.vertex.x+=w;
            //压低草的高度            
            v.vertex.y+=w*.4;            
            #endif
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb*_Color;            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;    
            clip(c.a-0.6);            
        }
       
        ENDCG
    }
    //FallBack "Diffuse"
}
