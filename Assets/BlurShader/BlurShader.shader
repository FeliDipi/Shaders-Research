Shader "Custom/Blur"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BlurSize("Blur Size", Range(0.0,15.0)) = 0.0
        _BlurDirection("Blur Direction", Vector) = (1,0,0,0)
    }
        SubShader
        {
            Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
            LOD 100

            Blend SrcAlpha OneMinusSrcAlpha

            Pass
            {
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
                float _BlurSize;
                float4 _BlurDirection;

                v2f vert(appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 uv = i.uv;
                    float2 direction = _BlurDirection.xy;
                    float4 color = float4(0, 0, 0, 0);

                    //custom blur values
                    float weights[5] = {
                        0.2270270270,
                        0.1945945946,
                        0.1216216216,
                        0.0540540541,
                        0.0162162162
                    };

                    float2 offset = float2(_BlurSize / _ScreenParams.x * direction.x, _BlurSize / _ScreenParams.y * direction.y);

                    color += tex2D(_MainTex, uv) * weights[0];
                    for (int j = 1; j < 5; j++)
                    {
                        color += tex2D(_MainTex, uv + offset * j) * weights[j];
                        color += tex2D(_MainTex, uv - offset * j) * weights[j];
                    }

                    return color;
                }
                ENDCG
            }
        }
}
