Shader "Custom/Outline"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _OutlineStroke("Outline Stroke", Range(-1, 10.0)) = 1.0
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
    }

        SubShader
        {
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Cull Off
            ZWrite Off
            Blend One OneMinusSrcAlpha

            Pass
            {
                CGPROGRAM
                #pragma vertex vertexFunc
                #pragma fragment fragmentFunc
                #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _OutlineColor;
            float _OutlineStroke;

            v2f vertexFunc(appdata_base v) {
                v.vertex.xyz *= _OutlineStroke;
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 fragmentFunc(v2f IN) : COLOR
            {
                float2 scaledCoord = (IN.uv - 0.5) * _OutlineStroke + 0.5;
                half4 c = tex2D(_MainTex, scaledCoord);
                c.rgb *= c.a;
                half4 outlineC = _OutlineColor;

                half outlineWidth = _OutlineStroke - 1;

                fixed upAlpha = tex2D(_MainTex, IN.uv + fixed2(0, _MainTex_TexelSize.y * outlineWidth)).a;
                fixed downAlpha = tex2D(_MainTex, IN.uv - fixed2(0, _MainTex_TexelSize.y * outlineWidth)).a;
                fixed rightAlpha = tex2D(_MainTex, IN.uv + fixed2(_MainTex_TexelSize.x * outlineWidth, 0)).a;
                fixed leftAlpha = tex2D(_MainTex, IN.uv - fixed2(_MainTex_TexelSize.x * outlineWidth, 0)).a;

                fixed factor = outlineWidth * 1 / _OutlineStroke * 0.5;
                fixed outsideUV = 1;

                outsideUV *= step(IN.uv.x, 1 - factor);
                outsideUV *= step(factor, IN.uv.x);
                outsideUV *= step(IN.uv.y, 1 - factor);
                outsideUV *= step(factor, IN.uv.y);

                fixed totalAlpha = min(ceil(upAlpha + downAlpha + rightAlpha + leftAlpha), 1);
                outlineC *= totalAlpha;
                half4 finalColor = lerp(outlineC, c, ceil(totalAlpha * outsideUV * c.a));

                return finalColor;
            }

        ENDCG
        }
    }
}
