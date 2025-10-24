Shader "URP/URP_RimLighting"
{
    Properties
    {
        // Base surface color
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        // Color of rim highlight
        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 1)

        // Controls edge falloff and width
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0

        // Controls rim brightness
        _RimIntensity ("Rim Intensity", Range(0.0, 10.0)) = 0
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION; // Vertex position
                float3 normalOS   : NORMAL;   // Normal direction
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Clip-space position
                float3 viewDirWS   : TEXCOORD0;   // View direction
                float3 normalWS    : TEXCOORD1;   // Normal direction
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _RimColor;
                float  _RimPower;
                float  _RimIntensity;
            CBUFFER_END

            // Vertex Shader
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPos);
                return OUT;
            }

            // Fragment Shader
            half4 frag (Varyings IN) : SV_Target
            {
                // --- Normalize inputs ---
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDirWS = normalize(IN.viewDirWS);

                // --- Rim lighting ---
                half rimFactor = 1.0 - saturate(dot(viewDirWS, normalWS));
                half rimLighting = pow(rimFactor, _RimPower);

                // --- Combine rim with base ---
                half3 finalColor = _BaseColor.rgb + (_RimColor.rgb * rimLighting) * _RimIntensity;

                return half4(finalColor, _BaseColor.a);
            }

            ENDHLSL
        }
    }
}
