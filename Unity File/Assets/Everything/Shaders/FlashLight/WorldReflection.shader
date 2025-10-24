Shader "Unlit/WorldReflection_URP"
{
    Properties
    {
        // Base surface texture and color
        _BaseMap ("Base Map", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)

        // Reflection controls
        _EnvCube ("Reflection Cubemap", Cube) = "" {}
        _EnvIntensity ("Reflection Intensity", Range(0,2)) = 1.0
        _EnvBlend ("Reflection Blend", Range(0,1)) = 1.0
        _FresnelPow ("Fresnel Power", Range(0.1, 8)) = 5.0
        _FresnelBoost ("Fresnel Boost", Range(0, 2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 200

        Pass
        {
            Name "Unlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION; // Vertex position
                float3 normalOS   : NORMAL;   // Surface normal
                float2 uv0        : TEXCOORD0; // Texture coordinates
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Screen position
                float3 positionWS  : TEXCOORD0;   // World position
                float3 normalWS    : TEXCOORD1;   // World normal
                float2 uv          : TEXCOORD2;   // UV coordinates
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURECUBE(_EnvCube);
            SAMPLER(sampler_EnvCube);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
                float  _EnvIntensity;
                float  _EnvBlend;
                float  _FresnelPow;
                float  _FresnelBoost;
            CBUFFER_END

            // Vertex Shader
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 nrmWS = TransformObjectToWorldNormal(IN.normalOS);

                OUT.positionWS = posWS;
                OUT.normalWS = nrmWS;
                OUT.positionHCS = TransformWorldToHClip(posWS);
                OUT.uv = TRANSFORM_TEX(IN.uv0, _BaseMap);
                return OUT;
            }

            // Fragment Shader
            half4 frag (Varyings IN) : SV_Target
            {
                // --- Sample base texture ---
                half3 baseCol = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).rgb * _BaseColor.rgb;

                // --- Compute view direction ---
                float3 V = SafeNormalize(GetWorldSpaceViewDir(IN.positionWS));

                // --- Surface normal ---
                float3 N = SafeNormalize(IN.normalWS);

                // --- Reflection direction ---
                float3 R = reflect(-V, N);

                // --- Environment reflection sample ---
                half3 envCol = SAMPLE_TEXTURECUBE(_EnvCube, sampler_EnvCube, R).rgb * _EnvIntensity;

                // --- Fresnel effect for edge highlights ---
                float ndotv = saturate(dot(N, V));
                float fresnel = pow(1.0 - ndotv, _FresnelPow) * _FresnelBoost;
                envCol *= (1.0 + fresnel);

                // --- Blend between texture and reflection ---
                half3 finalCol = lerp(baseCol, envCol, _EnvBlend);

                return half4(finalCol, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
