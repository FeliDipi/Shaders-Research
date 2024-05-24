Shader "Mobile/Mask"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }

        SubShader
    {
        Tags { "Queue" = "Transparent-1" }
        ColorMask 0
        ZWrite Off

        Pass
        {
            Stencil
            {
                Ref 1
                Pass replace
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

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 texColor = tex2D(_MainTex, i.uv);
                clip(texColor.a - 0.01);
                return float4(1.0, 1.0, 1.0, 1.0);
            }
            ENDCG
        }
    }
}
