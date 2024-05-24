Shader "Custom/Highlight"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _MaskTex("Mask Texture", 2D) = "white" {}
        _HighlightColor("Highlight Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        _HighlightIntensity("Highlight Intensity", Range(0, 1)) = 0.5
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5
        _Direction("Effect Direction", Vector) = (0,1,0,0)
    }

        SubShader
        {
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
            LOD 100

            Stencil
            {
                Ref 0
                Comp equal
                Pass Replace
            }

            Pass
            {
                Blend SrcAlpha OneMinusSrcAlpha
                Cull Off
                Lighting Off
                ZWrite Off

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
                sampler2D _MaskTex;
                float4 _MainTex_ST;
                float4 _HighlightColor;
                float4 _ShadowColor;
                float _HighlightIntensity;
                float _ShadowIntensity;
                float4 _Direction;

                v2f vert(appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 maskColor = tex2D(_MaskTex, i.uv);

                    if (maskColor.a == 0)
                    {
                        return float4(0, 0, 0, 0);
                    }

                    fixed4 texColor = tex2D(_MainTex, i.uv);

                    float2 direction = normalize(_Direction.xy);

                    float projection = dot(i.uv - 0.5, direction) + 0.5;

                    float highlightFactor = smoothstep(0.5, 1.0, projection) * _HighlightIntensity;
                    float shadowFactor = smoothstep(0.5, 0.0, projection) * _ShadowIntensity;

                    fixed4 highlightColor = lerp(texColor, _HighlightColor, highlightFactor);
                    fixed4 finalColor = lerp(highlightColor, _ShadowColor, shadowFactor);

                    finalColor.a = texColor.a;
                    return finalColor;
                }
                ENDCG
            }
        }
}
