Shader "URP/FlatShadingURP_Pop"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _LightIntensity ("Light Intensity", Range(0, 3)) = 1.2
        _AmbientIntensity ("Ambient Intensity", Range(0, 2)) = 0.4
        _Contrast ("Contrast Boost", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 posWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _LightIntensity;
                float _AmbientIntensity;
                float _Contrast;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Compute face normal (flat shading)
                float3 edge1 = ddx(IN.posWS);
                float3 edge2 = ddy(IN.posWS);
                half3 faceNormalWS = normalize(cross(edge1, edge2));

                // Main directional light
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

                // Diffuse term
                half NdotL = saturate(dot(faceNormalWS, -lightDir));

                // Base diffuse color
                half3 litColor = _BaseColor.rgb * NdotL * _LightIntensity;

                // Add ambient term for visibility
                half3 ambient = _BaseColor.rgb * _AmbientIntensity;

                // Combine
                half3 color = litColor + ambient;

                // Optional contrast boost
                color = pow(color, 1.0 / _Contrast);

                return half4(color, _BaseColor.a);
            }

            ENDHLSL
        }
    }
}
