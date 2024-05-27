Shader "Custom/HighlightDynamic"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _HighlightColor("Highlight Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        _HighlightStrength("Highlight Strength", Range(0,1)) = 0.5
        _HighlightIntensity("Highlight Intensity", Range(0, 1)) = 0.5
        _ShadowStrength("Shadow Strength", Range(0,1)) = 0.5
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.5
        _Direction("Effect Direction", Vector) = (0,1,0,0)
    }

        SubShader
        {
            Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" "PreviewType" = "Plane" }
            LOD 100

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
                float4 _MainTex_ST;
                float4 _HighlightColor;
                float4 _ShadowColor;
                float _HighlightStrength;
                float _HighlightIntensity;
                float _ShadowStrength;
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
                    fixed4 texColor = tex2D(_MainTex, i.uv);

                    if (texColor.a < 0.1)
                    {
                        discard;
                    }

                    float2 direction = normalize(_Direction.xy);
                    float projection = dot(i.uv - 0.5, direction) + 0.5;

                    float highlightFactor = smoothstep(_HighlightStrength, 1.0, projection) * _HighlightIntensity;
                    float shadowFactor = smoothstep(_ShadowStrength, 0.0, projection) * _ShadowIntensity;

                    fixed4 highlightColor = lerp(texColor, _HighlightColor, highlightFactor);
                    fixed4 finalColor = lerp(highlightColor, _ShadowColor, shadowFactor);

                    finalColor.a *= texColor.a;
                    finalColor.rgb = lerp(texColor.rgb, finalColor.rgb, finalColor.a);

                    return finalColor;
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
