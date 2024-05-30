Shader "Custom/EnhancedGlowEffectShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _GlowColor("Glow Color", Color) = (1,1,0,1)
        _GlowIntensity("Glow Intensity", Range(0, 1)) = 1
        _BlurAmount("Blur Amount", Range(0, 10)) = 1
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
    }
        SubShader
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue" = "Transparent"
                "ShaderGraphShader" = "true"
                "ShaderGraphTargetId" = "UniversalSpriteLitSubTarget"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ZTest Always

            Pass
            {
                Tags
                {
                    "LightMode" = "Universal2D"
                }

                Stencil
                {
                    Ref[_Stencil]
                    Comp[_StencilComp]
                    Pass[_StencilOp]
                    ReadMask[_StencilReadMask]
                    WriteMask[_StencilWriteMask]
                }
                ColorMask[_ColorMask]

                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _GlowColor;
                float _GlowIntensity;
                float _BlurAmount;

                v2f vert(appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 texcol = tex2D(_MainTex, i.uv);

                    // Calculate glow with more samples for better blur
                    float2 offsets[8] = {
                        float2(_BlurAmount / _ScreenParams.x, 0),
                        float2(-_BlurAmount / _ScreenParams.x, 0),
                        float2(0, _BlurAmount / _ScreenParams.y),
                        float2(0, -_BlurAmount / _ScreenParams.y),
                        float2(_BlurAmount / _ScreenParams.x, _BlurAmount / _ScreenParams.y),
                        float2(-_BlurAmount / _ScreenParams.x, -_BlurAmount / _ScreenParams.y),
                        float2(_BlurAmount / _ScreenParams.x, -_BlurAmount / _ScreenParams.y),
                        float2(-_BlurAmount / _ScreenParams.x, _BlurAmount / _ScreenParams.y)
                    };

                    float glow = 0;
                    for (int j = 0; j < 8; j++)
                    {
                        glow += tex2D(_MainTex, i.uv + offsets[j]).a;
                    }
                    glow /= 8.0;

                    fixed4 glowCol = _GlowColor * glow * _GlowIntensity;

                    return texcol + glowCol;
                }
                ENDCG
            }
        }
        FallBack "UI/Default"
}
