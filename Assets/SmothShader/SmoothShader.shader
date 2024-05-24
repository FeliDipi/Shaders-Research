Shader "Custom/Antialising"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _OutlineWidth("Outline Width", Range(0.0, 0.05)) = 0.01
        _AntialiasingStrength("Antialiasing Strength", Range(0.0, 1.0)) = 0.75
    }
        SubShader
        {
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata
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
                float _OutlineWidth;
                float _AntialiasingStrength;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                half4 frag(v2f i) : SV_Target
                {
                    float2 texelSize = 1.0 / _ScreenParams.xy;
                    half4 color = tex2D(_MainTex, i.uv);

                    float alphaEdge = tex2D(_MainTex, i.uv + float2(texelSize.x, 0)).a +
                                      tex2D(_MainTex, i.uv + float2(-texelSize.x, 0)).a +
                                      tex2D(_MainTex, i.uv + float2(0, texelSize.y)).a +
                                      tex2D(_MainTex, i.uv + float2(0, -texelSize.y)).a;
                    alphaEdge *= 0.25;

                    float edgeFactor = saturate((_OutlineWidth * _ScreenParams.x) / fwidth(alphaEdge));
                    edgeFactor = pow(edgeFactor, _AntialiasingStrength); // Apply antialiasing strength

                    float antialiasedAlpha = lerp(color.a, alphaEdge, edgeFactor);
                    return float4(color.rgb, antialiasedAlpha);
                }
                ENDCG
            }
        }
}
