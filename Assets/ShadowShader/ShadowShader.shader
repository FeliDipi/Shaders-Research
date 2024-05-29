Shader "Custom/OutBoundsWithShadowUI"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ShadowOffset("Shadow Offset", Vector) = (0.05, -0.05, 0, 0)
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        _ExpandFactor("Expand Factor", Float) = 2.0
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
                Name "Sprite Lit"
                Tags
                {
                    "LightMode" = "Universal2D"
                }

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
                float4 _ShadowOffset;
                float4 _ShadowColor;
                float _ExpandFactor;

                v2f vert(appdata_t v)
                {
                    v.vertex.xyz *= _ExpandFactor;
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 scaledCoord = (i.uv - 0.5) * _ExpandFactor + 0.5;
                    float2 shadowCoord = scaledCoord + _ShadowOffset.xy;

                    // Check if the main texture coordinates are out of bounds
                    bool isMainCoordValid = scaledCoord.x >= 0 && scaledCoord.x <= 1 && scaledCoord.y >= 0 && scaledCoord.y <= 1;
                    bool isShadowCoordValid = shadowCoord.x >= 0 && shadowCoord.x <= 1 && shadowCoord.y >= 0 && shadowCoord.y <= 1;

                    half4 mainColor = half4(0, 0, 0, 0);
                    if (isMainCoordValid)
                    {
                        mainColor = tex2D(_MainTex, scaledCoord);
                        mainColor.rgb *= mainColor.a;
                    }

                    half4 shadowColor = half4(0, 0, 0, 0);
                    if (isShadowCoordValid)
                    {
                        shadowColor = tex2D(_MainTex, shadowCoord) * _ShadowColor;
                        shadowColor.rgb *= shadowColor.a;
                    }

                    // Only apply the shadow where the main texture is transparent and the mask allows
                    half4 finalColor = mainColor + shadowColor * (1.0 - mainColor.a);

                    return finalColor;
                }
                ENDCG
            }
        }
            FallBack "UI/Default"
}
